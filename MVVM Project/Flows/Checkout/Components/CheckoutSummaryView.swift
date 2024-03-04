//
//  CheckoutSummaryView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.09.2023.
//

import SwiftUI

struct CheckoutSummaryView<FooterContent: View>: View {
    
    let total: Double
    var discount: Double?
    let shippingMethodSelectionState: ShippingMethodSelectionState
    @ViewBuilder let footerContent: FooterContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DividerView(tint: .silver.opacity(0.6))
            Text(Strings.Orders.orderSummary.uppercased())
                .font(kernedFont: .Main.p1MediumKerned)
                .foregroundColor(.jet)
                .padding(.horizontal, 16)
            summaryContentView
            footerContent
        }
        .background(Color.timberwolf)
    }
    
    private var summaryContentView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                Text(Strings.Orders.totalPrice)
                    .font(kernedFont: .Main.p1RegularKerned)
                Spacer()
                Text(total.currencyFormatted(isValueInCents: true) ?? "N/A")
                    .font(kernedFont: .Main.p1RegularKerned)
            }
            .foregroundColor(.jet)
            
            if let discount, discount > 0 {
                HStack(spacing: 0) {
                    Text(Strings.Payment.discount)
                        .font(kernedFont: .Secondary.p2RegularKerned)
                    Spacer()
                    Text("- " + (discount.currencyFormatted(isValueInCents: true) ?? "N/A"))
                        .font(kernedFont: .Secondary.p2RegularKerned)
                }
                .foregroundColor(.middleGrey)
                .transition(.opacity)
            }
            
            HStack(spacing: 0) {
                Text(Strings.Payment.taxAndShipping)
                    .font(kernedFont: .Secondary.p2RegularKerned)
                Spacer()
                Text(shippingMethodSelectionState.description)
                    .font(kernedFont: .Secondary.p2RegularKerned)
            }
            .foregroundColor(.middleGrey)
        }
        .padding([.horizontal, .bottom], 16)
    }
}

extension CheckoutSummaryView where FooterContent == EmptyView {
    
    init(total: Double, shippingMethodSelectionState: ShippingMethodSelectionState, discount: Double? = nil) {
        self.total = total
        self.discount = discount
        self.shippingMethodSelectionState = shippingMethodSelectionState
        self.footerContent = EmptyView()
    }
}

#if DEBUG
struct CheckoutSummaryView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(spacing: 50) {
            CheckoutSummaryView(total: 94000.9, shippingMethodSelectionState: .enterShippingAddress) {
                Rectangle().frame(height: 50)
                    .padding(.horizontal, 16)
            }
            CheckoutSummaryView(total: 94000.9, discount: 5000.99, shippingMethodSelectionState: .calculating) {
                Rectangle().frame(height: 50)
            }
        }
    }
}
#endif
