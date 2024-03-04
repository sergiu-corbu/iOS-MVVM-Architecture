//
//  ManageAccountViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.11.2022.
//

import Combine

class ManageAccountViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var isLoading = false
    @Published var backendError: Error?
    
    private var currentUser: User?
    
    lazy var currentUserProperties: AnalyticsProperties? = {
        var properties = AnalyticsProperties()
        properties[.account_name] = currentUser?.fullName
        properties[.username] = currentUser?.formattedUsername
        properties[.context] = [AnalyticsService.EventProperty.account_id.rawValue: currentUser?.id ?? ""]
        return properties
    }()
    
    //MARK: - Actions
    let onBack = PassthroughSubject<Void, Never>()
    let onDeleteAccount = PassthroughSubject<Void, Never>()
    let onPresentLogOutAlert = PassthroughSubject<Void, Never>()
    
    //MARK: - Services
    let authenticationService: AuthenticationServiceProtocol
    let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    let userSession: UserSession
    
    init(userSession: UserSession, authenticationService: AuthenticationServiceProtocol) {
        self.userSession = userSession
        self.authenticationService = authenticationService
        
        Task(priority: .utility) {
            currentUser = await userSession.userProvider?.getCurrentUser(loadFromCache: true)
        }
    }
    
    @MainActor
    func logout() {
        guard let refreshToken = userSession.refreshToken else {
            userSession.close()
            return
        }
        
        isLoading = true
        Task(priority: .userInitiated) {
            do {
                try await authenticationService.logOut(refreshToken: refreshToken, fcmToken: PushNotificationsManager.fcmToken)
                trackSignOutEvent()
            } catch {
                backendError = error
            }
            userSession.close()
            isLoading = false
        }
    }
    
    //MARK: - Analytics
    func trackSignOutEvent() {
        analyticsService.trackActionEvent(.signed_out, properties: currentUserProperties)
    }
    
    func trackDeleteAccountEvent() {
        analyticsService.trackActionEvent(.account_deleted, properties: currentUserProperties)
    }
}
