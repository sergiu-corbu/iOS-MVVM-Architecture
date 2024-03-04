//
//  PushNotificationsManager.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 12.04.2023.
//

import UIKit
import Combine
import UserNotifications
import FirebaseMessaging
import FirebaseCore

protocol PushNotificationsPermissionHandler {
    
    func shouldRequestPermission() async -> Bool
    func getCurrentAuthorizationStatus() async -> UNAuthorizationStatus
    func requestPushNotificationsPermission() async throws -> Bool
    
    var pushNotificationsTokenPublisher: CurrentValueSubject<String?, Never> { get }
}

class PushNotificationsManager: NSObject {
    
    //MARK: - Properties
    @UserDefault(key: UserSession.StorageKeys.fcmToken, defaultValue: nil)
    private(set) static var fcmToken: String?
    let pushNotificationsTokenPublisher: CurrentValueSubject<String?, Never>
    
    //MARK: - Getters
    var pushNotificationsEnabled: Bool {
        get async {
            return await getCurrentAuthorizationStatus() == .authorized
        }
    }
    
    //MARK: - Services
    let userSession: UserSession
    let pushNotificationsService: PushNotificationsServiceProtocol
    let pushNotificationsInteractor: PushNotificationsInteractorProtocol
    private let notificationCenter: UNUserNotificationCenter = .current()
    
    init(pushNotificationsService: PushNotificationsServiceProtocol, interactor: PushNotificationsInteractorProtocol, userSession: UserSession) {
        self.pushNotificationsService = pushNotificationsService
        self.pushNotificationsInteractor = interactor
        self.userSession = userSession
        self.pushNotificationsTokenPublisher = CurrentValueSubject(Self.fcmToken)
        super.init()
        
        Task(priority: .utility) { @MainActor in
            if await pushNotificationsEnabled {
                configurePushNotificationsService()
            }
        }
    }
    
    //MARK: - Setup
    func configurePushNotificationsService() {
        let options = FirebaseOptions(googleAppID: Constants.PushNotifications.APP_ID, gcmSenderID: Constants.PushNotifications.GCM_SENDER_ID)
        options.apiKey = Constants.PushNotifications.API_KEY
        options.projectID = Constants.PushNotifications.PROJECT_ID
        FirebaseApp.configure(options: options)
        Messaging.messaging().delegate = self
        
        notificationCenter.delegate = self
    }
    
    func unregisterForPushNotifications() async {
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
        try? await Messaging.messaging().deleteToken()
        
        await MainActor.run {
            UIApplication.shared.applicationIconBadgeNumber = 0
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    func registerDeviceToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func updateNotificationsBadgeCount(_ newValue: Int) {
        notificationCenter.setBadgeCount(newValue)
    }
    
    //MARK: - Push Token Updates
    func updateCurrentUserFCMToken() {
        Task(priority: .utility) {
            do {
                let token = try await Messaging.messaging().retrieveFCMToken(forSenderID: Constants.PushNotifications.GCM_SENDER_ID)
                await updateFCMToken(with: token)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateFCMToken(with token: String) async {
        Self.fcmToken = token
        pushNotificationsTokenPublisher.send(token)
                
        do {
            if userSession.isValid {
                try await pushNotificationsService.registerPushNotifications(token: token)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

//MARK: UNUserNotificationCenterDelegate
extension PushNotificationsManager: UNUserNotificationCenterDelegate {
        
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let userInfo = response.notification.userInfoData else {
            completionHandler()
            return
        }

        Task(priority: .userInitiated) {
            await processPushNotification(data: userInfo)
            await MainActor.run {
                completionHandler()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let userInfo = notification.userInfoData else {
            completionHandler([.sound, .banner])
            return
        }

        Task(priority: .userInitiated) {
            await processPushNotification(data: userInfo, shouldPerformAction: { notificationType in
                return [.liveTurnedToPublished, .videoConverted].contains(notificationType)
            })
            await MainActor.run {
                completionHandler([.sound, .banner])
            }
        }
    }
}

//MARK: - PushNotification processing
extension PushNotificationsManager {
    
    private func processPushNotification(
        data userInfo: [String : Any],
        shouldPerformAction: (PushNotificationType) -> Bool = { _ in true}
    ) async {
        
        let objectID = userInfo["objectId"] as? String
        let notificationTypeString = userInfo["event"] as? String
        
        guard let notificationTypeString, let objectID,
              let notificationType = PushNotificationType(rawValue: notificationTypeString),
              shouldPerformAction(notificationType) else {
            return
        }
        
        await pushNotificationsInteractor.processPushNotification(type: notificationType, objectID: objectID)
    }
    
    func processPushNotification(options launchOptions: [UIApplication.LaunchOptionsKey: Any]) {
        guard let data = launchOptions[.remoteNotification] as? [String : Any],
              let pushNotificationData = data["data"] as? [String:Any] else {
            return
        }
        
        Task(priority: .userInitiated) {
            await self.processPushNotification(data: pushNotificationData)
        }
    }
}

//MARK: MessagingDelegate
extension PushNotificationsManager: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else {
            return
        }
        
        Task(priority: .utility) {
            await updateFCMToken(with: fcmToken)
        }
    }
}

//MARK: PushNotificationHandler
extension PushNotificationsManager: PushNotificationsPermissionHandler {
    
    func getCurrentAuthorizationStatus() async -> UNAuthorizationStatus {
        return await notificationCenter.notificationSettings().authorizationStatus
    }
    
    func shouldRequestPermission() async -> Bool {
        let currentNotificationsSettings = await notificationCenter.notificationSettings()
        return [.denied, .notDetermined].contains(currentNotificationsSettings.authorizationStatus)
    }
    
    /// a methd that displays the standard request alert for notifications
    @MainActor func requestPushNotificationsPermission() async throws -> Bool {
        let isAuthorized = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
        if isAuthorized {
            AnalyticsService.notificationsPermissionEnabled = true
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        configurePushNotificationsService()
        return isAuthorized
    }
}

#if DEBUG
extension PushNotificationsManager {
    
    static let mocked = PushNotificationsManager(
        pushNotificationsService: MockPushNotificationsService(),
        interactor: PushNotificationsInteractor(showService: MockShowService()), 
        userSession: MockUserSession()
    )
}
struct MockPushNotificationsHandler: PushNotificationsPermissionHandler {
    
    func shouldRequestPermission() async -> Bool {
        return true
    }
    
    func getCurrentAuthorizationStatus() async -> UNAuthorizationStatus {
        return .notDetermined
    }
    
    func requestPushNotificationsPermission() async throws -> Bool {
        await Task.debugSleep()
        return Bool.random()
    }
    
    var pushNotificationsTokenPublisher: CurrentValueSubject<String?, Never> = .init(nil)
}
#endif
