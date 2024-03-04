//
//  STPPaymentCardInputView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.12.2023.
//

import SwiftUI
import UIKit
import StripePaymentsUI

struct STPPaymentCardInputView: UIViewRepresentable {
    
    @Binding var paymentMethodParams: STPPaymentMethodParams?

    /// Initialize a SwiftUI representation of an STPPaymentCardTextField.
    /// - Parameter paymentMethodParams: A binding to the payment card text field's contents.
    /// The STPPaymentMethodParams will be `nil` if the payment card text field's contents are invalid.
    public init(paymentMethodParams: Binding<STPPaymentMethodParams?>) {
        _paymentMethodParams = paymentMethodParams
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    public func makeUIView(context: Context) -> STPPaymentCardTextField {
        let paymentCardField = STPPaymentCardTextField()
        paymentCardField.postalCodeEntryEnabled = false
        paymentCardField.backgroundColor = .beige
        paymentCardField.font = .Secondary.regular(13)
        paymentCardField.borderColor = nil
        paymentCardField.tintColor = .jet
        paymentCardField.textErrorColor = UIColor(Color.firebrick)
        paymentCardField.textColor = .jet
        paymentCardField.placeholderColor = .middleGrey
        paymentCardField.numberPlaceholder = Strings.Placeholders.cardNumber
        context.coordinator.paymentCardTextField = paymentCardField
        if let paymentMethodParams = paymentMethodParams {
            paymentCardField.paymentMethodParams = paymentMethodParams
        }
        paymentCardField.delegate = context.coordinator
        paymentCardField.setContentHuggingPriority(.required, for: .vertical)
       
        paymentCardField.inputAccessoryView = createToolbar(context: context)
        return paymentCardField
    }

    public func updateUIView(_ paymentCardField: STPPaymentCardTextField, context: Context) {
        if let paymentMethodParams = paymentMethodParams {
            paymentCardField.paymentMethodParams = paymentMethodParams
        }
    }
    
    private func createToolbar(context: Context) -> UIToolbar {
        let toolbar = UIToolbar(
            frame: CGRect(x: 0, y: 0,
                width: UIApplication.shared.keyWindow?.screen.bounds.width ?? 300, height: 50
            )
        )
        toolbar.barStyle = .default
        let flexibleSpaceBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(
            title: Strings.Buttons.done, style: .done,
            target: context.coordinator, action: #selector(context.coordinator.dismissKeyboard)
        )
        toolbar.items = [flexibleSpaceBarButton, doneBarButton]
        toolbar.sizeToFit()

        return toolbar
    }

    public class Coordinator: NSObject, STPPaymentCardTextFieldDelegate {
       
        var parent: STPPaymentCardInputView
        var paymentCardTextField: STPPaymentCardTextField?
        
        init(parent: STPPaymentCardInputView) {
            self.parent = parent
        }
        
        public func paymentCardTextFieldDidChange(_ cardField: STPPaymentCardTextField) {
            let paymentMethodParams = cardField.paymentMethodParams
            if !cardField.isValid {
                parent.paymentMethodParams = nil
                return
            }
            parent.paymentMethodParams = paymentMethodParams
        }
        
        @objc func dismissKeyboard() {
            paymentCardTextField?.resignFirstResponder()
        }
    }
}


#Preview {
    STPPaymentCardInputView(paymentMethodParams: .constant(nil))
        .padding(.horizontal)
}
