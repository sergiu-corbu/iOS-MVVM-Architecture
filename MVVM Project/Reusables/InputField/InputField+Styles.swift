//
//  InputField + Styles.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 04.11.2022.
//

import SwiftUI

enum InputFieldType: String, Hashable, Equatable {
    
    case username
    case fullName, firstName, lastName
    case email, creditCard
    case socialPlatform, socialHandle
    case country, city, address, secondaryAddress, postalCode, phoneNumber, state
}

enum InputFieldState {
    
    case success
    case idle
    case typing
    case error(Error)
    
    var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
}

extension InputFieldState: Equatable {

    static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success):
            return true
        case (.idle, .idle):
            return true
        case (.typing, .typing):
            return true
        case (.error(let lhsError as NSError), .error(let rhsError as NSError)):
            return lhsError.code == rhsError.code
        default:
            return false
        }
    }
}

struct ValidationInputFieldStyle: ViewModifier {

    @FocusState private var isFocused: Bool
    let error: Error?
    let hint: String?
    let focusDelay: TimeInterval?
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content
                .focused($isFocused)
                .autocorrectionDisabled()
                .lineLimit(1)
                .frame(height: 56)
                .padding(.horizontal, 16)
                .background(backgroundColor.cornerRadius(5))
                .roundedBorder(borderColor)
                .animation(.linear(duration: 0.3), value: isFocused)
                .task {
                    await setupFocusIfNeeded()
                }
            footerSection
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var footerSection: some View {
        if let error {
            Text(error.localizedDescription)
                .foregroundColor(.firebrick)
                .supplementaryTextStyle()
        } else if isFocused, let hint {
            Text(hint)
                .foregroundColor(.ebony)
                .supplementaryTextStyle()
        }
    }
    
    private func setupFocusIfNeeded() async {
        guard let focusDelay else {
            return
        }
        await Task.sleep(seconds: focusDelay)
        isFocused = true
    }
    
    private var borderColor: Color {
        guard error == nil else {
            return .firebrick
        }
        return isFocused ? .midGrey : .clear
    }
    
    private var backgroundColor: Color {
        guard error == nil else {
            return .firebrick.opacity(0.05)
        }
        return isFocused ? .cultured : .beige
    }
}

struct DefaultInputFieldStyle: ViewModifier {

    @FocusState private var isFocused: Bool
    let hint: String?
    let focusDelay: TimeInterval?
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content
                .focused($isFocused)
                .autocorrectionDisabled()
                .lineLimit(1)
                .frame(height: 56)
                .padding(.horizontal, 16)
                .background((isFocused ? Color.cultured : .beige).cornerRadius(5))
                .roundedBorder(isFocused ? Color.midGrey : .clear)
                .animation(.linear(duration: 0.3), value: isFocused)
                .task {
                    await setupFocusIfNeeded()
                }
            hintView
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var hintView: some View {
        if let hint, isFocused {
            Text(hint)
                .foregroundColor(.ebony)
                .supplementaryTextStyle()
        }
    }
    
    private func setupFocusIfNeeded() async {
        guard let focusDelay else {
            return
        }
        await Task.sleep(seconds: focusDelay)
        isFocused = true
    }
}

extension InputField {
    
    func defaultFieldStyle(
        hint: String?,
        keyboardType: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        focusDelay: TimeInterval? = nil
    ) -> some View {
        self
            .modifier(
                DefaultInputFieldStyle(hint: hint, focusDelay: focusDelay)
            )
            .keyboardType(keyboardType)
            .textContentType(contentType)
    }
    
    func defaultFieldStyle(
        error: Error? = nil,
        hint: String? = nil,
        keyboardType: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        focusDelay: TimeInterval? = nil
    ) -> some View {
        let styleModifier = ValidationInputFieldStyle(
            error: error, hint: hint,
            focusDelay: focusDelay
        )
        return self
            .modifier(styleModifier)
            .keyboardType(keyboardType)
            .textContentType(contentType)
    }
    
    func defaultFieldStyle(
        successMessage: String? = nil,
        error: Error? = nil,
        hint: String? = nil,
        keyboardType: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        focusDelay: TimeInterval? = nil
    ) -> some View {
        let styleModifier = ValidationInputFieldStyle(
            error: error, hint: hint,
            focusDelay: focusDelay
        )
        return self
            .modifier(styleModifier)
            .keyboardType(keyboardType)
            .textContentType(contentType)
    }
    
    func emailFieldStyle(
        error: Error?,
        focusDelay: TimeInterval? = nil
    ) -> some View {
        let styleModifier = ValidationInputFieldStyle(
            error: error, hint: nil,
            focusDelay: focusDelay
        )
        return self
            .modifier(styleModifier)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
    }
}

fileprivate extension Text {
    
    func supplementaryTextStyle() -> some View {
        self
            .font(kernedFont: .Secondary.p3MediumKerned)
            .lineLimit(2)
            .transition(.asymmetric(insertion: .opacity.animation(.linear(duration: 0.2).delay(0.3)), removal: .identity))
    }
}
