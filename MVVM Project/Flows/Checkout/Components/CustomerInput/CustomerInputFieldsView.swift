//
//  CustomerInputFieldsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.12.2023.
//

import SwiftUI

struct CustomerInputFieldsView: View {
    
    @ObservedObject var viewModel: CustomerInputFieldsViewModel
    @FocusState private var selectedInputField: InputFieldType?
    
    var body: some View {
        CheckoutSectionView(title: Strings.Payment.contactInfo) {
            VStack(alignment: .leading, spacing: 12, content: {
                if viewModel.customerRole == nil {
                    guestCustomerInputFields
                }
                InputField(
                    inputText: viewModel.inputFieldBinding(for: .phoneNumber), scope: nil,
                    placeholder: Strings.Placeholders.phoneNumber.appending(" (Optional)"),
                    submitLabel: .done, onSubmit: {
                        selectedInputField = nil
                    }
                )
                .defaultFieldStyle(keyboardType: .phonePad, contentType: .telephoneNumber)
                .focused($selectedInputField, equals: .phoneNumber)
            })
        }
    }
    
    @ViewBuilder private var guestCustomerInputFields: some View {
        InputField(
            inputText: viewModel.inputFieldBinding(for: .email), scope: nil,
            placeholder: Strings.Placeholders.email,
            submitLabel: .next, onSubmit: {
                selectedInputField = .firstName
            })
        .emailFieldStyle(error: viewModel.inputFieldError(for: .email))
        .focused($selectedInputField, equals: .email)
        
        HStack(alignment: .top, spacing: -16) {
            InputField(
                inputText: viewModel.inputFieldBinding(for: .firstName), scope: nil,
                placeholder: Strings.Placeholders.firstName,
                submitLabel: .next, onSubmit: {
                    selectedInputField = .lastName
                })
            .defaultFieldStyle(error: viewModel.inputFieldErrors[.firstName], contentType: .givenName)
            .focused($selectedInputField, equals: .firstName)
            InputField(
                inputText: viewModel.inputFieldBinding(for: .lastName), scope: nil,
                placeholder: Strings.Placeholders.lastName,
                submitLabel: .next, onSubmit: {
                    selectedInputField = .phoneNumber
                })
            .defaultFieldStyle(error: viewModel.inputFieldErrors[.lastName], contentType: .familyName)
            .focused($selectedInputField, equals: .lastName)
        }
    }
}

#if DEBUG
#Preview {
    CustomerInputFieldsView(viewModel: .init(customerRole: .shopper))
}
#Preview {
    CustomerInputFieldsView(viewModel: .init(customerRole: nil))
}
#endif
