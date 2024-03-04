//
//  EnterEmailViewModel.swift
//  Bond
//
//  Created by Sergiu Corbu on 04.11.2022.
//

import Foundation
import Combine

class EnterEmailViewModel: ObservableObject {
    
    @Published var email: String = "" {
        willSet {
            if newValue != email {
                emailFieldState = .typing
            }
        }
    }
    @Published private(set) var emailFieldState: InputFieldState = .idle
    @Published private(set) var isLoading = false
    
    let authenticationService: AuthenticationServiceProtocol
    
    let onBack = PassthroughSubject<Void, Never>()
    let onContinue = PassthroughSubject<String, Never>()
    
    let onboardingType: OnboardingType
    
    init(onboardingType: OnboardingType, authenticationService: AuthenticationServiceProtocol) {
        self.onboardingType = onboardingType
        self.authenticationService = authenticationService
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
