//
//  ProductCheckoutViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.08.2023.
//

import Foundation
import Combine
import Stripe

class ProductCheckoutViewModel: BaseProductCheckoutViewModel {
    
    //MARK: - Properties
    @Published private(set) var progressStates: [ProgressState] = [.progress(1), .idle, .idle]
    @Published private(set) var currentCheckoutSection: CheckoutProgressSection = .customerInfoAndShipping
    @Published private(set) var isLoading = false
    @Published var useShippingAddressAsBilling = true
    @Published var error: Error?
    
    weak var stpAuthenticationContext: STPAuthenticationContext!
    private var loadingTask: VoidTask?
    
    //MARK: - Services
    private let userRepository: UserRepository
    private var applePayPaymentHandler: ApplePayPaymentHandler?
    private let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    //MARK: - ViewModels
    lazy var shippingAddressViewModel = AddressInputViewModel(addressScope: .shipping, showAddressCheckbox: isLoggedInUser)
    let billingAddressViewModel = AddressInputViewModel(addressScope: .billing)
    let creditCardInputViewModel = CreditCartInputViewModel()
    let customerInputViewModel: CustomerInputFieldsViewModel
    let shippingMethodsViewModel: ShippingMethodsViewModel
    
    //MARK: - Actions
    let checkoutResultActionHandler: (CheckoutActionType) -> Void
    var onEditCheckout: ((CheckoutSectionType) -> Void)?
    
    //MARK: - Computed
    var isLoggedInUser: Bool {
        return userRepository.currentUser?.role != nil
    }
    override var isCheckoutButtonDisabled: Bool {
        super.isCheckoutButtonDisabled || isLoading ||
            shippingMethodsViewModel.shippingMethodSelectionState.isCalculatingShipping
    }
    
    var checkoutButtonLabelString: String {
        if case .orderReview = currentCheckoutSection {
            return Strings.Buttons.placeOrder
        }
        return Strings.Buttons.continue
    }
    var shippingAddress: ShippingAddress {
        var address = shippingAddressViewModel.computeAddress()
        address.phoneNumber = customerInputViewModel.value(for: .phoneNumber)
        return address
    }
    var billingAddress: BillingAddress? {
        if useShippingAddressAsBilling {
            var address = shippingAddress
            address.firstName = customerInputViewModel.value(for: .firstName)
            address.lastName = customerInputViewModel.value(for: .lastName)
            return address
        } else {
            return billingAddressViewModel.computeAddress()
        }
    }
    
    init(checkoutCartManager: CheckoutCartManager, userRepository: UserRepository,
         discountContext: DiscountContext?, checkoutResultActionHandler: @escaping (CheckoutActionType) -> Void) {

        self.userRepository = userRepository
        self.checkoutResultActionHandler = checkoutResultActionHandler
        self.customerInputViewModel = CustomerInputFieldsViewModel(customerRole: userRepository.currentUser?.role)
        self.shippingMethodsViewModel = ShippingMethodsViewModel(checkoutService: checkoutCartManager.checkoutService)
        super.init(checkoutCartManager: checkoutCartManager)
        
        setupBindings()
        if let discountContext {
            super.discountState = discountContext.discountState
            super.discountCodeString = discountContext.discountCode
        }
    }
    
    deinit {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    //MARK: - Setup
    private func setupBindings() {
        shippingAddressViewModel.requiredInputCompletedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fieldsCompleted in
                if fieldsCompleted {
                    self?.updateShippingAddressAndShippingMethod()
                } else {
                    self?.shippingMethodsViewModel.resetShippingMethods()
                }
            }
            .store(in: &cancellables)
        shippingMethodsViewModel.$selectedShippingMethod
            .compactMap { $0 }
            .dropFirst()
            .sink { [weak self] shippingMethod in
                self?.loadingTask = Task(priority: .utility, { @MainActor [weak self] in
                    let updatedCart = try await self?.shippingMethodsViewModel.updateShippingMethod(
                        cart: self?.productCart,
                        selectedShippingMethodID: shippingMethod.shippingMethodId
                    )
                    if let updatedCart {
                        self?.checkoutCartManager.replaceCart(updatedCart)
                    }
                }, catch: { [weak self] error in
                    self?.error = error
                })
            }
            .store(in: &cancellables)
        shippingMethodsViewModel.$shippingMethodSelectionState.dropFirst()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        $currentCheckoutSection.sink { [weak self] in
            self?.trackCheckoutProgressEvent($0)
        }
        .store(in: &cancellables)
        
        prefillCustomerAndShippingAddress()
    }
    
    /// Note: - `shippingAddress` from Cart has priority over the one saved on User model
    private func prefillCustomerAndShippingAddress() {
        let currentUser = userRepository.currentUser
        
        //Shipping
        if let shippingAddress = productCart?.shippingAddress {
            shippingAddressViewModel.updateInputFields(with: shippingAddress)
        } else if let savedUserAddress = currentUser?.addresses.first, isLoggedInUser {
            shippingAddressViewModel.updateInputFields(with: savedUserAddress)
        }
        
        //Customer
        if let currentUser {
            customerInputViewModel.applyExistingCustomer(currentUser)
        } else if let shippingAddress = productCart?.shippingAddress {
            customerInputViewModel.applyExistingCustomer(shippingAddress: shippingAddress)
        }
    }
    
    //MARK: - Functionality
    func handleCheckoutButtonAction() {
        switch currentCheckoutSection {
        case .customerInfoAndShipping:
            let shippingFieldsCompleted = shippingAddressViewModel.validateFieldsCompletion(silentCheck: true)
            if !shippingFieldsCompleted {
                shippingMethodsViewModel.resetShippingMethods()
                return
            }
            if customerInputViewModel.validateCustomerFields() && 
                shippingMethodsViewModel.validateShippingMethodSelected() && shippingFieldsCompleted {
                updateProgressSection(.paymentAndBilling)
            }
        case .paymentAndBilling:
            var paymentAndBillingCompleted = creditCardInputViewModel.validateCreditCardParameters()
            if !useShippingAddressAsBilling {
                paymentAndBillingCompleted = paymentAndBillingCompleted && billingAddressViewModel.validateFieldsCompletion()
            }
            if paymentAndBillingCompleted {
                updateBillingAddress(billingAddress)
            }
        case .orderReview:
            isLoading = true
            loadingTask = Task(priority: .userInitiated) { @MainActor [weak self] in
                try? await self?.submitOrder()
                self?.isLoading = false
            }
        }
    }
    
    func handleBackAction() {
        switch currentCheckoutSection {
        case .customerInfoAndShipping:
            return
        case .paymentAndBilling:
            updateProgressSection(.customerInfoAndShipping)
        case .orderReview:
            updateProgressSection(.paymentAndBilling)
        }
    }
    
    func navigateToShippingDetails() {
        progressStates = [.progress(1), .idle, .idle]
        currentCheckoutSection = .customerInfoAndShipping
    }
    
    private func updateProgressSection(_ section: CheckoutProgressSection) {
        if section.rawValue > currentCheckoutSection.rawValue {
            progressStates[section.rawValue] = .progress(1)
        } else {
            progressStates[currentCheckoutSection.rawValue] = .idle
        }
        currentCheckoutSection = section
    }
}

//MARK: - Buy / SubmitCart
extension ProductCheckoutViewModel {
    
    func buyWithApplePayAction() {
        guard let checkoutCart = productCart else {
            return
        }
        let paymentHandler = ApplePayPaymentHandler(
            checkoutCart: checkoutCart,
            purchasedBrandName: checkoutCart.products.first!.brandName,
            checkoutService: checkoutCartManager.checkoutService,
            callback: { [weak self] result in
                self?.analyticsService.toggleUXOcclusion(false)
                switch result {
                case .failure(let error):
                    if let error {
                        self?.checkoutResultActionHandler(.error(error))
                    }
                case .success(let cart):
                    self?.checkoutResultActionHandler(.success(cart))
                case .orderSubmitted(let cart):
                    self?.checkoutResultActionHandler(.orderSubmitted(cart))
                case .cancelled:
                    break
                }
            }
        )
        
        analyticsService.toggleUXOcclusion(true)
        paymentHandler.showApplePay()
        self.applePayPaymentHandler = paymentHandler
        analyticsService.trackActionEvent(.action_tap, properties: [.name: AnalyticsService.EventProperty.buy_with_apple_pay.rawValue])
    }
    
    func submitOrder() async throws {
        do {
            try await checkoutCartManager.createPaymentIntent()
            let paymentStatus = try await processPayment()
            switch paymentStatus {
            case .succeeded:
                let cart = try await checkoutCartManager.submit()
                analyticsService.trackActionEvent(.action_tap, properties: [.name: AnalyticsService.EventProperty.buy_with_credit_card.rawValue])
                await MainActor.run {
                    checkoutResultActionHandler(.success(cart))
                }
                
            case .canceled:
                break
            case .failed:
                throw CheckoutError.submitOrderFailed
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
            throw error
        }
    }
    
    private func processPayment() async throws -> STPPaymentHandlerActionStatus {
        guard let paymentIntentClientSecret = productCart?.paymentIntentClientSecret,
            let stripeKey = productCart?.stripeKey else {
            throw CheckoutError.invalidClientSecret
        }
        
        STPAPIClient.shared.publishableKey = stripeKey
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
        paymentIntentParams.paymentMethodParams = creditCardInputViewModel.creditCardParameters
        let paymentHandler = STPPaymentHandler.shared()
        
        return try await withCheckedThrowingContinuation { continuation in
            paymentHandler.confirmPayment(paymentIntentParams, with: stpAuthenticationContext) { status, _, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: status)
            }
        }
    }
}

extension ProductCheckoutViewModel {
    
    //MARK: - Shipping
    private func updateShippingAddressAndShippingMethod() {
        guard let cartID = productCart?.violetCartId else {
            return
        }
        isLoading = true
        loadingTask = Task(priority: .userInitiated, { @MainActor [weak self] in
            try await self?.checkoutCartManager.updateCartDetails(
                shippingAddress: self?.shippingAddress,
                saveShippingAddress: self?.shippingAddressViewModel.saveAddressCheckbox,
                customer: self?.customerInputViewModel.computeCustomer()
            )
            try await self?.shippingMethodsViewModel.getShippingMethods(
                cartID: cartID, preselectedShippingMethodID: self?.productCart?.selectedShippingMethodID
            )
            self?.isLoading = false
        }, catch: { [weak self] error in
            self?.error = error
            self?.isLoading = false
        })
    }
    
    private func getAvailableShippingMethods() {
        loadingTask = Task(priority: .utility, { [weak self] in
            guard let cartID = self?.productCart?.violetCartId else { return }
            try await self?.shippingMethodsViewModel.getShippingMethods(
                cartID: cartID, preselectedShippingMethodID: self?.productCart?.selectedShippingMethodID
            )
        }, catch: { [weak self] error in
            self?.error = error
        })
    }
    
    //MARK: - Updating Billing Address
    private func updateBillingAddress(_ address: CustomerAddress?) {
        isLoading = true
        loadingTask = Task(priority: .userInitiated, { @MainActor [weak self] in
            try await self?.checkoutCartManager.updateCartDetails(saveShippingAddress: nil, billingAddress: address)
            self?.isLoading = false
            self?.updateProgressSection(.orderReview)
        }, catch: { [weak self] error in
            self?.error = error
            self?.isLoading = false
        })
    }
    
    var billingAddressInputFields: [InputFieldType:String] {
        (useShippingAddressAsBilling ? shippingAddressViewModel : billingAddressViewModel).inputFields
    }
    
    private func trackCheckoutProgressEvent(_ checkoutSection: CheckoutProgressSection) {
        analyticsService.trackActionEvent(
            .creditCardCheckoutProgress,
            properties: [.checkout_step: "Checkout Step \(checkoutSection.rawValue + 1)"]
        )
    }
}

#if DEBUG
extension ProductCheckoutViewModel {
    
    static let mocked = ProductCheckoutViewModel(
        checkoutCartManager: .mocked, userRepository: MockUserRepository(), discountContext: nil, checkoutResultActionHandler: { _ in }
    )
    
    static func sectionMocked(section: CheckoutProgressSection) -> ProductCheckoutViewModel {
        let vm = ProductCheckoutViewModel(
            checkoutCartManager: .mocked, userRepository: MockUserRepository(), discountContext: nil, checkoutResultActionHandler: { _ in }
        )
        vm.currentCheckoutSection = section
        return vm
    }
}
#endif
