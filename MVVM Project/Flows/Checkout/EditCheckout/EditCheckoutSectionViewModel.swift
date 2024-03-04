//
//  EditCheckoutSectionViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 30.12.2023.
//

import Foundation

class EditCheckoutSectionViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published private(set) var isLoading = false
    let checkoutSectionType: CheckoutSectionType
    private weak var productCheckoutViewModel: ProductCheckoutViewModel?
    private var loadingTask: VoidTask?
    
    //MARK: - ViewModels
    var editableCreditCartViewModel: CreditCartInputViewModel!
    var editableAddressInputViewModel: AddressInputViewModel!
//    var editableCustomerInputViewModel: CustomerInputFieldsViewModel!
//    var shippingMethodsViewModel: ShippingMethodsViewModel!
    
    //MARK: - Actions
    let onDismiss: () -> Void
    
    init(checkoutSectionType: CheckoutSectionType, productCheckoutViewModel: ProductCheckoutViewModel?, onDismiss: @escaping () -> Void) {
        self.checkoutSectionType = checkoutSectionType
        self.productCheckoutViewModel = productCheckoutViewModel
        self.onDismiss = onDismiss
        
        setupEditableViewModels()
    }
    
    deinit {
        loadingTask?.cancel()
    }
    
    //MARK: - Setup
    private func setupEditableViewModels() {
        switch checkoutSectionType {
        case .shippingAddress:
            break
//            editableAddressInputViewModel = AddressInputViewModel(
//                addressScope: .shipping,
//                inputFields: productCheckoutViewModel?.shippingAddressViewModel.inputFields,
//                saveAddressCheckbox: productCheckoutViewModel?.shippingAddressViewModel.saveAddressCheckbox
//            )
//            shippingMethodsViewModel = productCheckoutViewModel?.shippingMethodsViewModel
        case .billingAddress:
            editableAddressInputViewModel = AddressInputViewModel(
                addressScope: .billing,
                inputFields: productCheckoutViewModel?.billingAddressInputFields,
                saveAddressCheckbox: nil
            )
        case .paymentDetails:
            editableCreditCartViewModel = CreditCartInputViewModel(
                creditCardParameters: productCheckoutViewModel?.creditCardInputViewModel.creditCardParameters
            )
        }
    }
    
    func saveChangesAction() {
        switch checkoutSectionType {
        case .shippingAddress:
            break //Edit Shipping address is handled different
        case .billingAddress:
            if editableAddressInputViewModel.validateFieldsCompletion() {
                isLoading = true
                let address = editableAddressInputViewModel.computeAddress()
                loadingTask = Task(priority: .utility) { @MainActor [weak self] in
                    do {
                        try await self?.productCheckoutViewModel?.checkoutCartManager.updateCartDetails(
                            saveShippingAddress: nil, billingAddress: address
                        )
                        self?.productCheckoutViewModel?.billingAddressViewModel.applyFields(
                            self?.editableAddressInputViewModel.inputFields ?? [:]
                        )
                        self?.productCheckoutViewModel?.useShippingAddressAsBilling = false
                        self?.redrawMainViewAndDismiss()
                    } catch {
                        ToastDisplay.showErrorToast(error: error)
                    }
                    self?.isLoading = false
                }
            }
        case .paymentDetails:
            if editableCreditCartViewModel.validateCreditCardParameters() {
                productCheckoutViewModel?.creditCardInputViewModel.update(
                    with: editableCreditCartViewModel.creditCardParameters
                )
                redrawMainViewAndDismiss()
            }
        }
    }
    
    private func redrawMainViewAndDismiss() {
        productCheckoutViewModel?.objectWillChange.send()
        onDismiss()
    }
}

#if DEBUG
extension EditCheckoutSectionViewModel {
    
    static func previewVM(sectionType: CheckoutSectionType) -> EditCheckoutSectionViewModel {
        EditCheckoutSectionViewModel(checkoutSectionType: sectionType, productCheckoutViewModel: .mocked, onDismiss: {})
    }
}
#endif
