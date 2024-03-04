//
//  ClearCheckoutWarningView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 20.10.2023.
//

import SwiftUI

extension View {
    
    func clearCheckoutCartWarningSheet(isPresented: Binding<Bool>, onAddProduct: @escaping () -> Void) -> some View {
        sheet(isPresented: isPresented) {
            ClearCheckoutWarningView(onCancel: {
                isPresented.wrappedValue = false
            }, onAddProduct: {
                isPresented.wrappedValue = false
                onAddProduct()
            })
        }
    }
}

struct ClearCheckoutWarningView: View {
    
    let onCancel: () -> Void
    let onAddProduct: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            contentView
            actionButtonsStackView
        }
        .background(Color.cultured)
    }
    
    private var contentView: some View {
        VStack(spacing: 12) {
            Image(.shoppingBagDeleted)
            Text(Strings.Payment.cartDeletionWarningTitle)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundStyle(Color.jet)
            Text(Strings.Payment.cartDeletionWarningMessage)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundStyle(Color.ebony)
        }
        .frame(maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)
    }
    
    private var actionButtonsStackView: some View {
        HStack(spacing: 0) {
            Buttons.BorderedActionButton(title: Strings.Buttons.cancel, tint: .battleshipGray, height: 56, action: onCancel)
                .padding([.leading, .bottom], 16)
            Buttons.FilledRoundedButton(title: Strings.Buttons.addProduct, action: onAddProduct)
        }
    }
}

#if DEBUG
#Preview {
    Color.clear
        .clearCheckoutCartWarningSheet(isPresented: .constant(true), onAddProduct: {})
}
#endif
