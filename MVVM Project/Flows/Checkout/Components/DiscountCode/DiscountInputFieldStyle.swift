//
//  DiscountInputFieldStyle.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.08.2023.
//

import SwiftUI

enum DiscountFieldState {
    case idle
    case success(String)
    case error(String)
}

struct DiscountInputFieldStyle: ViewModifier {
    @FocusState private var isFocused: Bool
    var state: DiscountFieldState = .idle
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
    }
    
    @ViewBuilder
    private var footerSection: some View {
        switch state {
        case .idle:
            EmptyView()
        case .error(let string):
            Text(string)
                .foregroundColor(.firebrick)
                .font(kernedFont: .Secondary.p3MediumKerned)
                .lineLimit(2)
        case .success(let string):
            HStack {
                Image(.successIcon)
                Text(string)
                    .foregroundColor(.forrestGreen)
                    .font(kernedFont: .Secondary.p3MediumKerned)
                    .lineLimit(2)
            }
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
        if case .error = state {
            return .firebrick
        }
        return isFocused ? .midGrey : .clear
    }
    
    private var backgroundColor: Color {
        if case .error = state {
            return .firebrick.opacity(0.05)
        }
        return isFocused ? .cultured : .beige
    }
}
