//
//  DiscountCodeInputField.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 30.12.2023.
//

import SwiftUI

struct DiscountCodeInputField: View {
    
    @ObservedObject var viewModel: BaseProductCheckoutViewModel
    
    //Internal
    var discountCodeError: Error? {
        if case let .error(error) = viewModel.discountState {
            return error
        }
        return nil
    }
    var discountCodeBorderColor: Color {
        switch viewModel.discountState {
        case .idle, .loading: return .paleSilver
        case .invalidCode, .error: return .firebrick
        case .validCode: return .forrestGreen
        }
    }
    
    var body: some View {
        CheckoutLabeledSectionContainer(image: .percentIcon, title: Strings.Payment.discountCode) {
            InputField(
                inputText: $viewModel.discountCodeString, scope: nil,
                placeholder: Strings.Placeholders.discountCode,
                submitLabel: .done,
                isInputDisabled: viewModel.isDiscountFieldDisabled, leadingView: {},
                trailingView: { discountFieldButton.buttonStyle(.plain) },
                onSubmit: viewModel.applyCartDiscount
            ).modifier(DiscountInputFieldStyle(state: viewModel.discountState.fieldState, focusDelay: nil))
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder private var discountFieldButton: some View {
        switch viewModel.discountState {
        case .idle:
            Button(action: viewModel.applyCartDiscount, label: {
                discountFieldButtonText(text: Strings.Buttons.apply, isError: false)
            })
            .disabled(viewModel.discountCodeString.isEmpty)
            .opacity(viewModel.discountCodeString.isEmpty ? 0.4 : 1)
        case .error:
            Button(action: viewModel.applyCartDiscount, label: {
                discountFieldButtonText(text: Strings.Buttons.apply, isError: true)
            })
            .disabled(viewModel.discountCodeString.isEmpty)
            .opacity(viewModel.discountCodeString.isEmpty ? 0.4 : 1)
        case .loading:
            loadingIndicator(true, scale: 0.9)
        case .validCode:
            Button(action: viewModel.clearCartDiscount, label: {
                discountFieldButtonText(text: Strings.Buttons.clear, isError: false)
            })
        case .invalidCode:
            Button(action: viewModel.clearCartDiscount, label: {
                discountFieldButtonText(text: Strings.Buttons.clear, isError: true)
            })
        }
    }
    
    private func discountFieldButtonText(text: String, isError: Bool) -> some View {
        Text(text)
            .font(.Secondary.regular(14))
            .foregroundColor(.jet)
            .padding(.horizontal, 16)
            .frame(height: 32)
            .roundedBorder(isError ? Color.firebrick : Color.midGrey, cornerRadius: 5)
    }
}

#if DEBUG
#Preview {
    DiscountCodeInputField(viewModel: .previewVM)
}
#endif
