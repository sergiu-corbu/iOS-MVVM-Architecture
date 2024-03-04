//
//  ProductCheckout+CheckoutStatesView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 05.01.2024.
//

import SwiftUI
import Stripe

struct CustomerInfoAndShippingView: View {
    
    let customerInputViewModel: CustomerInputFieldsViewModel
    let shippingInputViewModel: AddressInputViewModel
    let shippingMethodsViewModel: ShippingMethodsViewModel
    let onBuyWithApplePay: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CheckoutSectionHeaderView(title: Strings.Payment.checkout)
            VStack(alignment: .leading, spacing: 16) {
                ExpressCheckoutView(onBuyWithApplePay: onBuyWithApplePay)
                customDividerView
            }
            CustomerInputFieldsView(viewModel: customerInputViewModel)
            AddressInputView(viewModel: shippingInputViewModel)
            ShippingMethodsView(viewModel: shippingMethodsViewModel)
        }
        .padding(.vertical, 16)
    }
    
    private var customDividerView: some View {
        HStack(spacing: 4) {
            DividerView()
            Text("OR")
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundStyle(Color.middleGrey)
            DividerView()
        }
        .padding(.horizontal, 16)
    }
}

struct PaymentAndBillingView: View {
    
    let creditCardInputViewModel: CreditCartInputViewModel
    let billingInputViewModel: AddressInputViewModel
    @Binding var useShippingAddressAsBilling: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            CheckoutSectionHeaderView(checkoutSection: .paymentDetails)
            CreditCartInputView(viewModel: creditCardInputViewModel)
            CheckoutSectionView(title: Strings.Payment.billingInformation) {
                CheckboxSelectableView(isSelected: $useShippingAddressAsBilling, message: Strings.Payment.sameBillingAddress)
            }
            if !useShippingAddressAsBilling {
                AddressInputView(viewModel: billingInputViewModel)
            }
        }
        .padding(.vertical, 16)
    }
}

struct ChekcoutOrderReview: View {
    
    @ObservedObject var productCheckoutViewModel: ProductCheckoutViewModel
    @State private var isShippingDetailPresented = false
    
    private var productCart: CheckoutCart? {
        productCheckoutViewModel.productCart
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CheckoutSectionHeaderView(title: Strings.Payment.orderReview)
            checkoutItemsView
            DiscountCodeInputField(viewModel: productCheckoutViewModel)
            DividerView()
            shippingAddressView
            DividerView()
            paymentMethodView
            DividerView()
            billingAddressView
            DividerView()
            ShippingInformationView(
                isShippingDetailPresented: $isShippingDetailPresented,
                onOpenEmail: { productCheckoutViewModel.checkoutResultActionHandler(.openEmail) }
            )
        }
        .padding(.vertical, 16)
    }
    
    private var checkoutItemsView: some View {
        CheckoutLabeledSectionContainer(image: .shoppingBagHeavy, title: Strings.Orders.items) {
            let products = productCart?.products
            CheckoutProductsCartListView(
                products: products ?? [],
                productCellContent: { checkoutProduct, _ in
                    FeaturedProductDetailView(productDisplayable: checkoutProduct)
                })
        }
        .padding(.horizontal, 16)
    }
    
    private var shippingAddressView: some View {
        CheckoutLabeledSectionContainer(
            image: .houseIcon,
            title: Strings.Payment.shippingAddress,
            onEdit: {
                productCheckoutViewModel.navigateToShippingDetails()
            }) {
                CustomerCheckoutAddressView(address:  productCheckoutViewModel.shippingAddressViewModel.computeAddress())
        }
        .padding(.horizontal, 16)
    }
    
    private var billingAddressView: some View {
        CheckoutLabeledSectionContainer(
            image: .houseIcon,
            title: Strings.Payment.billingAddress,
            onEdit: {
                productCheckoutViewModel.onEditCheckout?(.billingAddress)
            }) {
            if let billingAddress = productCheckoutViewModel.billingAddress {
                CustomerCheckoutAddressView(address: billingAddress)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var paymentMethodView: some View {
        CheckoutLabeledSectionContainer(
            image: .walletIcon,
            title: Strings.Orders.paymentMethod,
            onEdit: {
                productCheckoutViewModel.onEditCheckout?(.paymentDetails)
            }) {
            if let creditCard = productCheckoutViewModel.creditCardInputViewModel.creditCardParameters?.card {
                RestrictedCreditCardPreview(stpCreditCard: creditCard)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct RestrictedCreditCardPreview: View {
    
    let cardLabel: String
    let last4Digits: String
    let expiryDate: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(cardLabel.uppercased() + " •••• " + last4Digits)
                .font(kernedFont: .Secondary.p2MediumKerned())
            Spacer()
            Text(Strings.Payment.cardExpiration.uppercased() + " " + expiryDate)
                .font(kernedFont: .Secondary.p2MediumKerned())
        }
        .foregroundStyle(Color.ebony)
        .padding(EdgeInsets(top: 20, leading: 12, bottom: 20, trailing: 12))
        .roundedBorder(Color.paleSilver, cornerRadius: 4)
    }
}

extension RestrictedCreditCardPreview {
    
    init(stpCreditCard: STPPaymentMethodCardParams) {
        self.cardLabel = stpCreditCard.label
        self.last4Digits = stpCreditCard.last4 ?? "4242"
        self.expiryDate = String(stpCreditCard.expMonth?.intValue ?? 1) + "/" + String( stpCreditCard.expYear?.intValue ?? 2024)
    }
}

struct CustomerCheckoutAddressView: View {
    
    let address: CustomerAddress
    
    var body: some View {
        VStack(alignment: .leading) {
            if let customerName = address.fullName {
                Text(customerName)
                    .font(kernedFont: .Secondary.p1RegularKerned)
            }
            Text(address.checkouShippingAddress)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .lineLimit(2)
        }
        .foregroundStyle(Color.ebony)
        .multilineTextAlignment(.leading)
    }
}

#if DEBUG
#Preview("Order Review") {
    ChekcoutOrderReview(productCheckoutViewModel: .mocked)
}
#endif
