//
//  CreatorEnterEmailViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.11.2022.
//

import Foundation
import Combine

class CreatorEnterEmailViewModel: ObservableObject {
    
    @Published var email: String = "" {
        willSet {
            if newValue != email {
                emailFieldState = .typing
            }
        }
    }
    @Published private(set) var emailFieldState: InputFieldState = .idle {
        willSet {
            if newValue != emailFieldState, newValue != .typing {
                progressStates[0] = .progress(newValue == .success ? 1 : 0.05)
            }
        }
    }
    @Published private(set) var isLoading = false
    
    @Published private(set) var progressStates: [ProgressState]
    
    let authenticationService: AuthenticationServiceProtocol
    
    let onBack = PassthroughSubject<Void, Never>()
    let onContinue = PassthroughSubject<String, Never>()
        
    init(authenticationService: AuthenticationServiceProtocol) {
        self.authenticationService = authenticationService
        self.progressStates = ProgressState.createStaticStates(currentIndex: 0)
    }
    
    var continueButtonEnabled: Bool {
        emailFieldState == .success && !email.isEmpty
    }
    
    func validateEmail() {
        guard !email.isEmpty else {
            return
        }
        do {
            try email.isValidEmail()
            emailFieldState = .success
        } catch {
            emailFieldState = .error(error)
        }
    }
    
    func requestSignInEmail() {
        guard continueButtonEnabled else {
            return
        }
        isLoading = true
        Task(priority: .userInitiated) { @MainActor in
            do {
                try email.isValidEmail()
                try await authenticationService.requestSignInEmail(email)
                onContinue.send(email)
            } catch {
                emailFieldState = .error(error)
            }
            isLoading = false
        }
    }
}
