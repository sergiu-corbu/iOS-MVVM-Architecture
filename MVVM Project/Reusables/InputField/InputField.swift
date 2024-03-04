//
//  InputField.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 04.11.2022.
//

import SwiftUI

struct InputField<LeadingView: View, TrailingView: View>: View {
    
    @Binding var inputText: String
    let scope: String?
    var placeholder: String?
    var tint: Color = .jet
    var submitLabel: SubmitLabel = .return
    var isInputDisabled = false
    let onSubmit: () -> Void
    
    @ViewBuilder var leadingView: LeadingView
    @ViewBuilder var trailingView: TrailingView
    
    @FocusState private var isFocused: Bool
    private let fieldKey = "input_field_key"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if isFocused || !inputText.isEmpty {
                scopeView
            }
            HStack(spacing: 8) {
                leadingView
                inputField
                trailingView
                    .transition(.opacity.animation(.linear(duration: 0.2)))
            }
        }
    }
    
    private var inputField: some View {
        TextField(
            fieldKey,
            text: $inputText,
            prompt: Text(placeholder ?? "").foregroundColor(.middleGrey)
        )
        .focused($isFocused)
        .submitLabel(submitLabel)
        .kerning(0.3)
        .onSubmit(of: .text, onSubmit)
        .accentColor(tint)
        .font(.Secondary.p1Regular)
        .disabled(isInputDisabled)
    }
    
    @ViewBuilder
    private var scopeView: some View {
        if let scope {
            Text(scope)
                .font(kernedFont: .Secondary.p1MediumKerned)
                .foregroundColor(.orangish)
                .transition(.moveBottomAndFade)
        }
    }
}

extension InputField where LeadingView == EmptyView, TrailingView == EmptyView {
    
    init(inputText: Binding<String>, scope: String?, placeholder: String?, tint: Color = .jet, submitLabel: SubmitLabel = .return, onSubmit: @escaping () -> Void) {
        self._inputText = inputText
        self.scope = scope
        self.placeholder = placeholder
        self.tint = tint
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
        self.leadingView = EmptyView()
        self.trailingView = EmptyView()
    }
}

extension InputField where LeadingView == EmptyView {

    init(inputText: Binding<String>, scope: String?, placeholder: String?, tint: Color = .jet, submitLabel: SubmitLabel = .return, @ViewBuilder trailingView: @escaping () -> TrailingView, onSubmit: @escaping () -> Void) {
        self._inputText = inputText
        self.scope = scope
        self.placeholder = placeholder
        self.tint = tint
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
        self.leadingView = EmptyView()
        self.trailingView = trailingView()
    }
}

extension InputField where TrailingView == EmptyView {

    init(inputText: Binding<String>, scope: String?, placeholder: String?, tint: Color = .jet, submitLabel: SubmitLabel = .return, @ViewBuilder leadingView: @escaping () -> LeadingView, onSubmit: @escaping () -> Void) {
        self._inputText = inputText
        self.scope = scope
        self.placeholder = placeholder
        self.tint = tint
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
        self.leadingView = leadingView()
        self.trailingView = EmptyView()
    }
}

extension InputField {

    /// standard email field configuration
    init(inputText: Binding<String>, scope: String?, placeholder: String?, submitLabel: SubmitLabel = .send, isInputDisabled: Bool = false, @ViewBuilder leadingView: @escaping () -> LeadingView, @ViewBuilder trailingView: @escaping () -> TrailingView, onSubmit: @escaping () -> Void) {
        self._inputText = inputText
        self.scope = scope
        self.placeholder = placeholder
        self.tint = .jet
        self.submitLabel = submitLabel
        self.isInputDisabled = isInputDisabled
        self.onSubmit = onSubmit
        self.leadingView = leadingView()
        self.trailingView = trailingView()
    }
}
