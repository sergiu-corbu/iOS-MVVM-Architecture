//
//  UserSession.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import Foundation
import Combine
import StoreKit

class UserSession {
    
    //MARK: - Keychain
    @Keychain(key: StorageKeys.accessToken)
    private(set) var accessToken: String?
    
    @Keychain(key: StorageKeys.refreshToken)
    private(set) var refreshToken: String?
    
    //MARK: - User Default
    @UserDefault(key: StorageKeys.didShowGuestOnboarding, defaultValue: false)
    var didShowGuestOnboarding: Bool
    
    @UserDefault(key: StorageKeys.guestUserID, defaultValue: nil)
    private(set) var guestUserID: String?
    
    @UserDefault(key: StorageKeys.didPresentPushNotificationsPermission, defaultValue: false)
    var didPresentPushNotificationsPermission: Bool
    
    @UserDefault(key: StorageKeys.installDate, defaultValue: nil)
    var installDate: Date?
    
    //MARK: - Properties
    var userProvider: UserProvider?
    let currentUserRoleSubject = PassthroughSubject<User.Role?, Never>()
    let onSessionClosed = PassthroughSubject<Void, Never>()
    
    var isValid: Bool {
        return accessToken?.isEmpty == false
    }
    var isValidSessionPublisher: AnyPublisher<Bool, Never> {
        return currentUserRoleSubject.map { $0 != nil }.eraseToAnyPublisher()
    }
    
    func save(user: User, accessToken: String, refreshToken: String?) async {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.guestUserID = nil
        await userProvider?.saveUser(user)
        currentUserRoleSubject.send(user.role)
    }
    
    func saveGuestUserID(_ userID: String) {
        self.guestUserID = userID
    }
    
    func refresh(tokenInfo: RefreshTokenResponse) {
        self.accessToken = tokenInfo.accessToken
        self.refreshToken = tokenInfo.refreshToken
    }
    
    func close(error: Error? = nil) {
        Task(priority: .utility) {
            await removeSessionData()
            currentUserRoleSubject.send(nil)
            onSessionClosed.send()
        }
    }
    
    func processAppInstall() {
        accessToken = nil
        refreshToken = nil
        guestUserID = nil
        installDate = Date.now
    }
    
    func handleGuestOnboardingCompleted() {
        didShowGuestOnboarding = true
        didPresentPushNotificationsPermission = true
    }
    
    func showRateTheAppAlert() {
        guard let activeScene = UIApplication.shared.foregroundActiveScene else {
            return
        }
        SKStoreReviewController.requestReview(in: activeScene)
    }
    
    private func removeSessionData() async {
        accessToken = nil
        guestUserID = nil
        refreshToken = nil
        await userProvider?.saveUser(nil)
    }
}

 extension UserSession {
    
    struct StorageKeys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let fcmToken = "fcmToken"
        static let didShowTooltip = "didShowTooltip"
        static let didShowGuestOnboarding = "didShowDiscoveryPages"
        static let guestUserID = "guestUserID"
        static let didPresentPushNotificationsPermission = "didPresentPushNotificationsPermission"
        static let installDate = "installDate"
        static let reminderShowIDs = "reminderShowIDs"
        static let notificationsPermissionEnabled = "notificationsPermissionEnabled"
    }
}

#if DEBUG
class MockUserSession: UserSession {
    
    override var userProvider: UserProvider? {
        get { return MockUserProvider() }
        set { super.userProvider = newValue }
    }
}
#endif
