//
//  ExpressCheckoutView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 24.12.2023.
//

import SwiftUI

struct ExpressCheckoutView: View {
    
    let onBuyWithApplePay: () -> Void
    
    var body: some View {
        CheckoutSectionView(title: Strings.Payment.expressCheckout) {
            ApplePayButton(isEnabled: true, action: onBuyWithApplePay).applePayButtonStyle()
        }
    }
}

#Preview {
    ExpressCheckoutView(onBuyWithApplePay: {})
}
