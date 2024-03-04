//
//  Keyboard+Utils.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.01.2024.
//

import Foundation
import UIKit
import Combine
import SwiftUI

final class KeyboardResponder: ObservableObject {
    
    //Properties
    @Published private(set) var keyboardHeight: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()
    
    var isKeyboardVisible: Bool {
        return keyboardHeight > 0
    }
    
    //Publishers
    private let keyboardWillShowNotification = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
    private let keyboardWillHideNotification = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)

    init() {
        setupObservers()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    private func setupObservers() {
        keyboardWillShowNotification.map { notification in
            CGFloat((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0)
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] value in
            self?.keyboardHeight = value
        })
        .store(in: &cancellables)
        keyboardWillHideNotification.map { notification in
            CGFloat(0)
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] value in
            self?.keyboardHeight = value
        })
        .store(in: &cancellables)
    }
}

struct KeyboardAdaptiveViewModifier: ViewModifier {
    
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardResponder.keyboardHeight)
            .animation(.easeOut(duration: 0.16), value: keyboardResponder.keyboardHeight)
    }
}

extension View {
    
    func keyboardAdaptive() -> some View {
        self.modifier(KeyboardAdaptiveViewModifier())
    }
}
