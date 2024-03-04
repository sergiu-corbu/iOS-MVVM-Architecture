//
//  PreviewProductCartView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.12.2023.
//

import SwiftUI

struct PreviewProductCartView: View {

    @ObservedObject var viewModel: BaseProductCheckoutViewModel
    let onDismiss: () -> Void
    let onCheckout: (DiscountContext) -> Void
    
    //Internal
    @State private var error: Error?
    
    var body: some View {
        VStack(spacing: 8) {
            NavigationBar(inlineTitle: Strings.Payment.yourBag.capitalized, onDismiss: onDismiss) {
                Buttons.CloseButton(onClose: onDismiss)
            }
            .backButtonHidden(true)
            scrollableContentView
            if let checkoutCart = viewModel.productCart {
                CheckoutSummaryView(
                    total: checkoutCart.subTotal,
                    discount: checkoutCart.discountTotal,
                    shippingMethodSelectionState: .calculatedAtNextStep,
                    footerContent: {
                        Buttons.FilledRoundedButton(
                            title: Strings.Buttons.checkout,
                            isEnabled: !viewModel.isCheckoutButtonDisabled
                        ) {
                            onCheckout(viewModel.discountContext)
                        }
                    }
                )
            }
        }
        .primaryBackground()
        .errorToast(error: $error)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private var scrollableContentView: some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                checkoutProductsListView
                DiscountCodeInputField(viewModel: viewModel)
                DividerView()
            }
            .padding(.vertical, 16)
        }
        .scrollDismissesKeyboard(.immediately)
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
                            self.error = error
                        }
                    }
                )
            })
    }
}

#if DEBUG
#Preview {
    PreviewProductCartView(viewModel: .previewVM, onDismiss: {}, onCheckout: {_ in})
}
#endif
