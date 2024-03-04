//
//  ApplePayButton.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 21.02.2023.
//

import Foundation
import UIKit
import SwiftUI
import PassKit

extension View {
    
    func applePayButtonStyle() -> some View {
        return self
            .frame(height: 42)
            .padding([.horizontal, .bottom], 16)
    }
}

struct ApplePayButton: UIViewRepresentable {
    
    var isEnabled: Bool = false
    let action: () -> Void
    
    private var currentAlpha: CGFloat {
        return isEnabled ? 1 : 0.25
    }
    
    func makeUIView(context: Context) -> PKPaymentButton {
        let paymentButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        paymentButton.cornerRadius = 5
        paymentButton.isUserInteractionEnabled = isEnabled
        paymentButton.alpha = currentAlpha
        paymentButton.addTarget(
            context.coordinator,
            action: #selector(context.coordinator.performAction),
            for: .touchUpInside
        )
        return paymentButton
    }
    
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {
        uiView.isUserInteractionEnabled = isEnabled
        UIView.animate(withDuration: 0.3, delay: .zero, options: .curveLinear, animations: {
            uiView.alpha = currentAlpha
        })
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator {
        
        private let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func performAction() {
            action()
        }
    }
}
