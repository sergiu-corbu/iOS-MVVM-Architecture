//
//  ProductRequestSuccessView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.07.2023.
//

import SwiftUI
import UIKit

struct ProductRequestSuccessView: View {
    
    let onFinishedInteraction: () -> Void
    
    var body: some View {
        LogoContainerView(buttonTitle: Strings.Buttons.done, contentView: {
            contentView
        }, action: onFinishedInteraction)
    }
    
    private var contentView: some View {
        VStack {
            Text(Strings.ContentCreation.productRequestSuccessMessage)
                .font(kernedFont: .Main.h1RegularKerned)
                .foregroundColor(.cultured)
            Image(.outlinedBag)
                .padding(EdgeInsets(top: 80, leading: 0, bottom: 40, trailing: 0))
            VStack(spacing: 12) {
                Text(Strings.ContentCreation.brandConfirmationMessage)
                    .font(kernedFont: .Secondary.p1BoldKerned)
                    .foregroundColor(.cultured)
                Text(Strings.ContentCreation.orderAndShippingConfirmation)
                    .font(kernedFont: .Secondary.p4MediumKerned)
                    .foregroundColor(.paleSilver)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)
    }
}

#if DEBUG
struct ProductRequestSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        ProductRequestSuccessView(onFinishedInteraction: {})
            .previewDevice(.iPhoneSE_3rd)
    }
}
#endif
