//
//  ProductCheckoutView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.08.2023.
//

import Foundation
import SwiftUI

struct ProductCheckoutView: View {
    
    @ObservedObject var viewModel: ProductCheckoutViewModel
    
    //Internal
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    var body: some View {
        VStack(spacing: 8) {
            NavigationBar(inlineTitle: Strings.Payment.checkout, onDismiss: viewModel.handleBackAction, trailingView: {
                Buttons.CloseButton(onClose: {
                    viewModel.checkoutResultActionHandler(.dismiss)
                })
            })
            .backButtonHidden(viewModel.currentCheckoutSection == .customerInfoAndShipping)
            StepProgressView(currentIndex: viewModel.currentCheckoutSection.rawValue, progressStates: viewModel.progressStates)
            checkoutContentView
            if !keyboardResponder.isKeyboardVisible {
                checkoutFooterContent
            }
        }
        .background(Color.cultured)
        .errorToast(error: $viewModel.error)
    }
    
    private var checkoutContentView: some View {
        ScrollView(.vertical) {
            switch viewModel.currentCheckoutSection {
            case .customerInfoAndShipping:
                CustomerInfoAndShippingView(
                    customerInputViewModel: viewModel.customerInputViewModel,
                    shippingInputViewModel: viewModel.shippingAddressViewModel,
                    shippingMethodsViewModel: viewModel.shippingMethodsViewModel,
                    onBuyWithApplePay: viewModel.buyWithApplePayAction
                )
                .disabled(viewModel.isLoading)
            case .paymentAndBilling:
                PaymentAndBillingView(
                    creditCardInputViewModel: viewModel.creditCardInputViewModel,
                    billingInputViewModel: viewModel.billingAddressViewModel,
                    useShippingAddressAsBilling: $viewModel.useShippingAddressAsBilling
                )
            case .orderReview:
                ChekcoutOrderReview(productCheckoutViewModel: viewModel)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
 
    @ViewBuilder private var checkoutFooterContent: some View {
        if let checkoutCart = viewModel.productCart {
            CheckoutSummaryView(
                total: checkoutCart.total ?? checkoutCart.subTotal,
                discount: checkoutCart.discountTotal,
                shippingMethodSelectionState: viewModel.shippingMethodsViewModel.shippingMethodSelectionState,
                footerContent: {
                    Buttons.FilledRoundedButton(
                        title: viewModel.checkoutButtonLabelString,
                        isEnabled: !viewModel.isCheckoutButtonDisabled,
                        isLoading: viewModel.isLoading,
                        action: viewModel.handleCheckoutButtonAction
                    )
                }
            )
        }
    }
    
    private var checkoutProductsListView: some View {
        let products = viewModel.productCart?.products
        return CheckoutProductsCartListView(
            products: products ?? [],
            productCellContent: { checkoutProduct, scrollProxy in
                FeaturedProductDetailView(
                    productDisplayable: checkoutProduct,
                    isInDelete: viewModel.removingProductSKUID == checkoutProduct.sku.id,
                    onDeleteAction: {
                        Task {
                            try await viewModel.removeProductFromCart(productSKUId: checkoutProduct.sku.id)
                            scrollProxy?.scrollTo(products?.first?.sku.id, anchor: .leading, animation: .smooth)
                        } catch: { error in
                            viewModel.checkoutResultActionHandler(.error(error))
                        }
                    }
                )
            })
    }
}

#if DEBUG
#Preview("Shipping Checkout") {
    ViewModelPreviewWrapper(ProductCheckoutViewModel.mocked) { vm in
        ProductCheckoutView(viewModel: vm)
    }
}

#Preview("Payment Checkout") {
    ViewModelPreviewWrapper(ProductCheckoutViewModel.sectionMocked(section: .paymentAndBilling)) { vm in
        ProductCheckoutView(viewModel: vm)
    }
}
#Preview("Order Review") {
    ViewModelPreviewWrapper(ProductCheckoutViewModel.sectionMocked(section: .orderReview)) { vm in
        ProductCheckoutView(viewModel: vm)
    }
}
#endif
