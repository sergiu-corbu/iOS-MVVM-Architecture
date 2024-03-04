//
//  ProfileSetupViewModel.swift
//  Bond
//
//  Created by Sergiu Corbu on 05.11.2022.
//

import Foundation
import Combine
import SwiftUI

class ProfileSetupViewModel: ObservableObject {
    
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
    @Published var usernameFieldState: InputFieldState = .idle
    @Published var isLoading = false
    @Published var isValidatingUsername = false
    
    @Published var backendError: Error?
    
    let userRepository: UserRepository
    let userSession: UserSession
    let authenticationService: AuthenticationServiceProtocol
    
    let onBack = PassthroughSubject<Void, Never>()
    let onProfileCompleted = PassthroughSubject<Void, Never>()
    var usernameAvailabilityTask: Task<Void, Never>?
    
    init(userRepository: UserRepository, userSession: UserSession, authenticationService: AuthenticationServiceProtocol) {
        self.userRepository = userRepository
        self.userSession = userSession
        self.authenticationService = authenticationService
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
    
    @MainActor
    func continueAction() {
        guard continueButtonEnabled else {
            return
        }
        isLoading = true
        Task(priority: .userInitiated) {
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
