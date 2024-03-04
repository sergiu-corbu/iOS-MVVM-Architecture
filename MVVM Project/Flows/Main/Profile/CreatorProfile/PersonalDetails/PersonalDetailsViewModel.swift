//
//  PersonalDetailsViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.11.2022.
//

import Foundation
import Combine

class PersonalDetailsViewModel: ObservableObject {
    
    @Published var fullName: String {
        willSet {
            if fullnameError != nil {
                fullnameError = nil
            }
        }
    }
    @Published var username: String {
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
    
    let userEmail: String
    let userRepository: UserRepository
    let authenticationService: AuthenticationServiceProtocol
    let userSession: UserSession
    
    private var usernameAvailabilityTask: Task<Void, Never>?
    
    let onFinishedInteraction = PassthroughSubject<Void, Never>()
    private let initialUser: User
    
    init(user: User, userRepository: UserRepository, userSession: UserSession, authenticationService: AuthenticationServiceProtocol) {
        self.initialUser = user
        self.userEmail = user.email
        self.fullName = user.fullName ?? ""
        self.username = user.username ?? ""
        self.userRepository = userRepository
        self.userSession = userSession
        self.authenticationService = authenticationService
    }
    
    var saveButtonEnabled: Bool {
        let noErrors = fullnameError == nil && (usernameFieldState == .success ||  usernameFieldState == .idle)
        let inputChanged = fullName != initialUser.fullName || username != initialUser.username
        return !fullName.isEmpty && !username.isEmpty && noErrors && inputChanged
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
    func savePersonalDetails() {
        guard saveButtonEnabled else {
            return
        }
        isLoading = true
        Task(priority: .userInitiated) {
            do {
                try await userRepository.updateUser(values: [.username: username, .fullName: fullName])
                onFinishedInteraction.send()
            } catch {
                backendError = error
            }
            isLoading = false
        }
    }
}
