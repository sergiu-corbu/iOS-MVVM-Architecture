//
//  OrderCompletedView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 11.11.2022.
//

import SwiftUI

struct OrderCompletedView: View {
    
    let confirmationNumber: String
    let brand: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        LogoContainerView(buttonTitle: title) {
            content
        } action: {
            action()
        }
    }
    
    private var content: some View {
        VStack {
            Text(Strings.Others.orderGratitude)
                .font(kernedFont: .Main.h1RegularKerned)
                .foregroundColor(.cultured)
                .fixedSize()
            Spacer()
            
            VStack(spacing: 50) {
                Image(.outlinedBag)
                
                VStack(spacing: 20) {
                    Text(Strings.Others.orderConfirmationNumber(confirmationNumber: confirmationNumber))
                        .foregroundColor(.cultured)
                        .fixedSize()
                    Text(Strings.Others.shippingConfirmation(brand: brand))
                        .foregroundColor(.paleSilver)
                        .fixedSize()
                }
            }
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.top, 32)
    }
}

struct OrderCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        OrderCompletedView(
            confirmationNumber: "#25",
            brand: "Nike",
            title: "",
            action: {}
        )
    }
}
