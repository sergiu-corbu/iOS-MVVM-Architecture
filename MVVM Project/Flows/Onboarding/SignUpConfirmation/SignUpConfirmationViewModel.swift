//
//  SignUpConfirmationViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 10.01.2023.
//

import Foundation

class SignUpConfirmationViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var error: Error?
    let authenticationCode: String
    
    //MARK: - Actions
    let onCancel: () -> Void
    let onFinishedValidation: (User) -> Void
    
    //MARK: - Services
    let userSession: UserSession
    let authenticationService: AuthenticationServiceProtocol
    
    init(authenticationCode: String,
         authenticationService: AuthenticationServiceProtocol,
         userSession: UserSession,
         onCancel: @escaping () -> Void,
         onFinishedValidation: @escaping (User) -> Void
    ) {
        self.authenticationCode = authenticationCode
        self.authenticationService = authenticationService
        self.userSession = userSession
        self.onCancel = onCancel
        self.onFinishedValidation = onFinishedValidation
    }
    
    func validateAuthenticationCode() {
        Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                let signInResponse = try await self.authenticationService.signIn(
                    authenticationCode: self.authenticationCode,
                    guestUserID: self.userSession.guestUserID
                )
                let user = signInResponse.user
                await self.userSession.save(
                    user: user,
                    accessToken: signInResponse.accessToken,
                    refreshToken: signInResponse.refreshToken
                )
                await Task.sleep(seconds: 2)
                self.onFinishedValidation(user)
            } catch {
                self.error = error
                await Task.sleep(seconds: 2)
                self.onCancel()
            }
        }
    }
}
