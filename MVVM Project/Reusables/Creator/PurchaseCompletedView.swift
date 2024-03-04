//
//  PurchaseCompletedView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.02.2023.
//

import SwiftUI

struct PurchaseCompletedView: View {
    
    let orderNumber: Int
    let brandName: String
    let onContinueShopping: () -> Void
    
    var body: some View {
        LogoContainerView(buttonTitle: Strings.Payment.continueShopping, contentView: {
            confirmedOrderView
        }, action: {
            onContinueShopping()
        })
    }
    
    private var confirmedOrderView: some View {
        VStack(spacing: 0) {
            Text(Strings.Payment.thankYouForOrder)
                .font(kernedFont: .Main.h1RegularKerned)
                .foregroundColor(.cultured)
            VStack(spacing: 12) {
                Image(.outlinedBag)
                    .frame(maxHeight: .infinity)
                Text(Strings.Payment.orderNumberMessage(orderNumber))
                    .font(kernedFont: .Secondary.p1BoldKerned)
                    .lineSpacing(4)
                    .foregroundColor(.cultured)
                Text(Strings.Payment.orderConfirmationMessage.appending(" ") + brandName)
                    .font(kernedFont: .Secondary.p4MediumKerned)
                    .foregroundColor(.paleSilver)
                Spacer()
            }
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, 32)
    }
}

#if DEBUG
struct PurchaseCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseCompletedView(orderNumber: 1234, brandName: "Nike", onContinueShopping: {})
    }
}
#endif
