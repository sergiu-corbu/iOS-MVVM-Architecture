//
//  ProductsDetailFooterView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 24.10.2023.
//

import SwiftUI

struct ProductsDetailFooterView: View {
    
    @ObservedObject var viewModel: ProductDetailsViewModel

    var body: some View {
        if viewModel.productsContext.isRequestingGiftProduct {
            requestProductButtonView
        } else if viewModel.isAffiliateProduct {
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.buyOnSenseWebsite,
                action: viewModel.openAffiliateProductWebPage
            )
        } else {
            HStack(spacing: 0) {
                purchaseButtonView
                MinimizedCartView(cartManager: viewModel.checkoutCartManager, onPresentCart: viewModel.presentCheckoutCart)
                    .padding([.bottom, .trailing], 16)
                    .transaction { cartView in
                        cartView.animation = cartView.animation?.delay(0.1)
                    }
                    .disabled(viewModel.isProcessingCheckout)
            }
            .animation(.smooth, value: viewModel.checkoutCartManager.shouldDisplayMinimizedCartView)
        }
    }
    
    private var requestProductButtonView: some View {
        let buttonTitle: String = {
            if viewModel.isRequestedProductAvailable {
                return Strings.Buttons.requestProduct
            } else {
                return Strings.Buttons.outOfStock
            }
        }()
        return Buttons.FilledRoundedButton(
            title: buttonTitle,
            isEnabled: viewModel.isPrimaryButtonEnabled,
            action: viewModel.selectProductAction
        )
    }
    
    @ViewBuilder private var purchaseButtonView: some View {
        if viewModel.variantsSelectionViewModel.didSelectAllVariants {
            if viewModel.isRequestedProductAvailable {
                Buttons.FilledRoundedButton(
                    title: Strings.Buttons.addToBag,
                    isEnabled: viewModel.isPrimaryButtonEnabled,
                    isLoading: viewModel.isProcessingCheckout,
                    action: { viewModel.addToCartAction() }
                )
            } else {
                Buttons.FilledRoundedButton(
                    title: Strings.Buttons.outOfStock,
                    isEnabled: viewModel.isPrimaryButtonEnabled,
                    action: { viewModel.addToCartAction() }
                )
            }
        } else {
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.addToBag,
                action: { viewModel.addToCartAction() }
            )
        }
    }
}

#if DEBUG
#Preview {
    ProductsDetailFooterView(viewModel: .mockedProductsDetailVM())
}
#endif
