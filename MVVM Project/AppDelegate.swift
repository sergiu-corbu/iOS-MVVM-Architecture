//
//  AppDelegate.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var rootCoordinator: RootCoordinator?
    private var deeplinkService: DeeplinkService? {
        return rootCoordinator?.dependencyContainer.deeplinkService
    }
    private var pushNotificationsManager: PushNotificationsManager? {
        return rootCoordinator?.dependencyContainer.pushNotificationsManager
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let newWindow = UIWindow(frame: UIScreen.main.bounds)
        rootCoordinator = RootCoordinator(window: newWindow, launchOptions: launchOptions)
        rootCoordinator?.start()
        newWindow.makeKeyAndVisible()
        self.window = newWindow
        
        deeplinkService?.setLaunchOptions(launchOptions)
        ErrorService.setup()
        AnalyticsService.shared.setup()
        return true
    }
    
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        
        let isProcessedUserActivity = deeplinkService?.processUserActivity(userActivity)
        return isProcessedUserActivity ?? false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.scheme == Constants.URL_SCHEME else {
            return false
        }
        return deeplinkService?.processURL(url) ?? false
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        ToastDisplay.showErrorToast(from: application.rootViewController, error: error)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        VideoPlayerService.setupAudioSessionCategoryPlayback()
        pushNotificationsManager?.updateNotificationsBadgeCount(0)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushNotificationsManager?.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ToastDisplay.showErrorToast(from: application.rootViewController, error: error)
    }
}
