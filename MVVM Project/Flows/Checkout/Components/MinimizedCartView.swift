//
//  MinimizedCartView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.10.2023.
//

import SwiftUI

extension View {
    
    func minimizedCartViewOverlay(
        alignment: Alignment = .bottomTrailing,
        cartManager: CheckoutCartManager,
        onPresentCart: (() -> Void)?
    ) -> some View {
        
        overlay(alignment: alignment) {
            MinimizedCartView(cartManager: cartManager, onPresentCart: {
                onPresentCart?()
            })
            .padding([.bottom, .trailing], 8)
        }
    }
}

struct MinimizedCartView: View {
    
    @ObservedObject var cartManager: CheckoutCartManager
    let onPresentCart: () -> Void
    
    var body: some View {
        if cartManager.shouldDisplayMinimizedCartView { 
            Button(action: onPresentCart, label: cartViewLabel)
                .buttonStyle(.scaled)
                .transition(.move(edge: .trailing))
        }
    }
    
    private func cartViewLabel() -> some View {
        ZStack {
            Circle()
                .fill(Color.darkGreen)
                .frame(width: 56, height: 56)
            Image(.shoppingBagHeavy)
                .renderingMode(.template)
                .foregroundStyle(Color.paleSilver)
        }
        .overlay(alignment: .topTrailing) {
            cartItemsCountLabelView
        }
    }
    
    private var cartItemsCountLabelView: some View {
        ZStack {
            Circle()
                .fill(Color.orangish)
            Text("\(cartManager.cartItemsCount)")
                .font(kernedFont: .Secondary.p4BoldKerned)
                .foregroundStyle(Color.cultured)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(width: 16, height: 16)
    }
}

#if DEBUG
#Preview {
    MinimizedCartView(cartManager: CheckoutCartManager.mocked, onPresentCart: {})
        .padding()
}
#endif
