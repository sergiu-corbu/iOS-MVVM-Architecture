//
//  GuestUserRepository.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.11.2023.
//

import Foundation

class GuestUserRepository {
    
    private let userSession: UserSession
    private let authenticationService: AuthenticationServiceProtocol
    
    init(userSession: UserSession, authenticationService: AuthenticationServiceProtocol) {
        self.userSession = userSession
        self.authenticationService = authenticationService
    }
    
    //TODO: handle changed fcm token - research
    func registerGuestUser(fcmToken: String) {
        if userSession.isValid || userSession.guestUserID != nil {
            return
        }
        
        Task.detached(priority: .background) { [weak self] in
            do {
                guard let self else { return }
                let guestUser = try await self.authenticationService.registerGuestUser(fcmToken: fcmToken)
                self.userSession.saveGuestUserID(guestUser.id)
            } catch {
                ErrorService.trackEvent(message: error.localizedDescription)
                print(error.localizedDescription)
            }
        }
    }
}
