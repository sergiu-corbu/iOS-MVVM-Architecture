//
//  CreatorProfileSetupViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.11.2022.
//

import Foundation
import Combine
import SwiftUI

class CreatorProfileSetupViewModel: ObservableObject {
    
    @Published var fullName: String = "" {
        willSet {
            if fullnameError != nil {
                fullnameError = nil
            }
        }
    }
    @Published var username: String = "" {
        willSet {
            if newValue != username {
                usernameFieldState = .typing
            }
        }
    }
    
    @Published var fullnameError: Error?
    @Published var usernameFieldState: InputFieldState = .idle {
        willSet {
            if newValue != usernameFieldState, newValue != .typing {
                progressStates[2] = .progress(newValue == .success ? 1 : 0.05)
            }
        }
    }
    @Published var isLoading = false
    @Published var isValidatingUsername = false
    
    @Published private(set) var progressStates: [ProgressState]
    
    @Published var backendError: Error?
    
    let userRepository: UserRepository
    let authenticationService: AuthenticationServiceProtocol
    
    let onBack = PassthroughSubject<Void, Never>()
    let onProfileCompleted = PassthroughSubject<Void, Never>()
    var usernameAvailabilityTask: Task<Void, Never>?
    
    init(authenticationService: AuthenticationServiceProtocol, userRepository: UserRepository) {
        self.userRepository = userRepository
        self.authenticationService = authenticationService
        self.progressStates = ProgressState.createStaticStates(currentIndex: 2)
    }
    
    var continueButtonEnabled: Bool {
        let noErrors = fullnameError == nil && usernameFieldState == .success
        return !fullName.isEmpty && !username.isEmpty && noErrors
    }
    
    func checkUsernameAvailability() {
        guard !username.isEmpty, usernameFieldState == .typing else {
            return
        }
        isValidatingUsername = true
        usernameAvailabilityTask?.cancel()
        usernameAvailabilityTask = Task(priority: .userInitiated) { @MainActor in
            do {
                try username.isValidUsername()
                try await authenticationService.checkUsernameAvailability(username)
                usernameFieldState = .success
            } catch {
                usernameFieldState = .error(error)
            }
            isValidatingUsername = false
        }
    }
    
    func continueAction() {
        guard continueButtonEnabled else {
            return
        }
        isLoading = true
        Task(priority: .userInitiated) { @MainActor in
            do {
                let updateValues: [User.UpdateKey: String] = [.username: username, .fullName: fullName]
                try await userRepository.updateUser(values: updateValues)
                onProfileCompleted.send()
            } catch {
                backendError = error
            }
            isLoading = false
        }
    }
}

