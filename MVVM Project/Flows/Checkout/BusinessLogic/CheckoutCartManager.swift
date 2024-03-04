//
//  CheckoutCartManager.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.10.2023.
//

import Foundation
import Combine
import Stripe

class CheckoutCartManager: ObservableObject {
    
    //MARK: - Properties
    @Published private(set) var checkoutCart: CheckoutCart?
    @Published private(set) var showCartResetAlert = false
    @UserDefault(key: StorageKeys.storedCartID, defaultValue: nil)
    private var storedCartID: UInt?
    
    let onCartDeletedPublisher = PassthroughSubject<Void, Never>()
    
    //MARK: - Getters
    var cartItemsCount: Int {
        return checkoutCart?.products.count ?? 0
    }
    var shouldDisplayMinimizedCartView: Bool {
        return checkoutCart != nil && cartItemsCount > 0
    }
    private var cartID: UInt? {
        return checkoutCart?.violetCartId ?? storedCartID
    }
    
    //MARK: - Tasks
    private var cancellable: AnyCancellable?
    private var getCartTask: VoidTask?
    
    //MARK: - Services
    let checkoutService: CheckoutServiceProtocol
    let analyticsService: AnalyticsServiceProtocol
    
    init(checkoutService: CheckoutServiceProtocol,
         analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
         sessionPublisher: AnyPublisher<Bool, Never>) {
        
        self.checkoutService = checkoutService
        self.analyticsService = analyticsService
        setup(sessionPublisher: sessionPublisher)
    }
    
    deinit {
        cancellable?.cancel()
        getCartTask?.cancel()
        clearCart()
    }
    
    //MARK: - Setup
    private func setup(sessionPublisher: AnyPublisher<Bool, Never>) {
        StripeAPI.defaultPublishableKey = Constants.ApplePay.STRIPE_KEY
        self.getCurrentCart()
        
        cancellable = sessionPublisher.receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isSessionActive in
                if isSessionActive {
                    self?.getCurrentCart()
                } else {
                    self?.clearCart()
                }
            }

    }
    
    //MARK: - Cart functionality
    func getCurrentCart() {
        getCartTask?.cancel()
        getCartTask = Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                self.checkoutCart = try await self.checkoutService.getCurrentCart(cartID: self.cartID)
            } catch {
                ErrorService.trackEvent(message: error.localizedDescription)
                print(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    @discardableResult
    func createCart(productSKUId: UInt,
                    creatorId: String?,
                    showId: String?,
                    deletePreviousCart: Bool = false) async throws -> CheckoutCart {
        
        if deletePreviousCart, let cartID = checkoutCart?.violetCartId {
            try? await checkoutService.deleteCart(cartId: cartID)
            analyticsService.trackActionEvent(.cart_deleted, properties: nil)
            productEvent(.cart_deleted, productSKUID: productSKUId)
        }
        
        let cart = try await checkoutService.createCart(
            creatorId: creatorId,
            showId: showId, skuId: productSKUId
        )
        productEvent(.cart_created, productSKUID: productSKUId)
        
        self.storedCartID = cart.violetCartId
        self.checkoutCart = cart
        return cart
    }
    
    //MARK: - Add Product
    @MainActor
    @discardableResult 
    func addProductToCart(productSKUId: UInt,
                          creatorId: String? = nil,
                          showId: String? = nil) async throws -> CheckoutCart {
        
        if let checkoutCart = checkoutCart {
            let cart = try await checkoutService.addProductToCart(cartId: checkoutCart.violetCartId, skuId: productSKUId)
            productEvent(.add_product_to_cart, productSKUID: productSKUId)
            self.checkoutCart = cart
            return cart
        } else {
            return try await createCart(productSKUId: productSKUId, creatorId: creatorId, showId: showId)
        }
    }
    
    //MARK: - Remove Product
    @MainActor func removeProductFromCart(productSKUId: UInt) async throws {
        guard let checkoutCart = checkoutCart else {
            return
        }
        if checkoutCart.products.count > 1 {
            self.checkoutCart = try await checkoutService.removeProductFromCart(
                cartId: checkoutCart.violetCartId,
                skuId: productSKUId
            )
            productEvent(.remove_product_from_cart, productSKUID: productSKUId)
        } else {
            try await checkoutService.deleteCart(cartId: checkoutCart.violetCartId)
            analyticsService.trackActionEvent(.cart_deleted, properties: nil)
            onCartDeletedPublisher.send()
            clearCart()
        }
    }
    
    /// - Note: This method does not delete the cart associated to the current user
    func clearCart() {
        checkoutCart = nil
        storedCartID = nil
    }
    
    func replaceCart(_ newCart: CheckoutCart) {
        checkoutCart = newCart
    }
    
    @discardableResult
    @MainActor func updateCartDetails(shippingAddress: ShippingAddress? = nil,
                                      saveShippingAddress: Bool?,
                                      billingAddress: BillingAddress? = nil,
                                      customer: Customer? = nil) async throws -> CheckoutCart {
        
        guard let cartID = checkoutCart?.violetCartId else {
            throw CheckoutError.missingCart
        }
        let cart = try await checkoutService.updateCartDetails(
            cartId: cartID,
            shippingAddress: shippingAddress, saveShippingAddress: saveShippingAddress, billingAddress: billingAddress,
            customer: customer
        )
        self.checkoutCart = cart
        return cart
    }
    
    //MARK: - PaymentIntent & Submit
    @discardableResult
    @MainActor func createPaymentIntent() async throws -> CheckoutCart {
        guard let cartID else {
            throw CheckoutError.missingCart
        }
        let cart = try await checkoutService.createPaymentIntent(cartId: cartID, shippingAddress: nil).productCart
        self.checkoutCart = cart
        return cart
    }

    @discardableResult
    @MainActor func submit() async throws -> CheckoutCart {
        guard let cartID else {
            throw CheckoutError.missingCart
        }
        let cart = try await checkoutService.submitCart(
            cartID, shippingAddress: nil, billingAddress: nil, customer: nil //already set
        )
        self.checkoutCart = cart
        return cart
    }
    
    //MARK: - Discount Codes
    @MainActor func applyDiscountCode(_ discountCode: String) async throws {
        guard let checkoutCart else {
            return
        }
        self.checkoutCart = try await checkoutService.applyDiscount(
            cartId: checkoutCart.violetCartId,
            code: discountCode,
            merchantId: checkoutCart.merchantID
        )
        analyticsService.trackActionEvent(.discount_applied, properties: [.name: discountCode])
    }
    
    @MainActor func removeDiscount() async throws {
        guard let checkoutCart, let discount = checkoutCart.discount else {
            return
        }
        self.checkoutCart = try await checkoutService.removeDiscount(
            cartId: checkoutCart.violetCartId,
            discountId: discount.id
        )
        analyticsService.trackActionEvent(.discount_removed, properties: [.name: discount.code])
    }
}

//MARK: - Analytics
private extension CheckoutCartManager {
    
    func productEvent(_ eventType: AnalyticsService.ActionEvent, productSKUID : UInt) {
        guard let product = checkoutCart?.products.first(where: { $0.sku.id == productSKUID }) else {
            return
        }
        analyticsService.trackActionEvent(eventType, properties: product.baseAnalyticsProperties)
    }
}

#if DEBUG
extension CheckoutCartManager {
    static let mocked = CheckoutCartManager(
        checkoutService: MockCheckoutService(),
        sessionPublisher: CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
    )
    static let guestMocked = CheckoutCartManager(
        checkoutService: MockCheckoutService(),
        sessionPublisher: CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    )
}
#endif

extension NetworkError.ErrorCode {    
    static let differentMerchant = "DifferentMerchant"
}

extension CheckoutCartManager {
    struct StorageKeys {
        static let storedCartID = "storedCartID"
    }
}
