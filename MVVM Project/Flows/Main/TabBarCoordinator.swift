//
//  TabBarCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation
import UIKit
import Combine

class TabBarCoordinator {
    
    //MARK: - Properties
    let window: UIWindow
    private let navigationController: UINavigationController
    private let tabBarController = TabBarController()
    private var launchOptions: [UIApplication.LaunchOptionsKey:Any]?
    
    //MARK: - Services
    private let dependencyContainer: DependencyContainer
    private let userRepository: UserRepository
    private let userSession: UserSession
    private let deeplinkService: DeeplinkService
    private let analyticsService: AnalyticsServiceProtocol
    private let pushNotificationsManager: PushNotificationsManager
    private let guestUserRepository: GuestUserRepository
    private let favoritesManager: FavoritesManager
    
    //MARK: - Coordinators
    private(set) var discoverCoordinator: DiscoverFeedCoordinator?
    private(set) var searchCoordinator: SearchCoordinator?
    private(set) var profileCoordinator: ProfileCoordinator?
    
    private var cancellables = [AnyCancellable]()
    
    init(window: UIWindow, dependencyContainer: DependencyContainer, launchOptions: [UIApplication.LaunchOptionsKey:Any]?) {
        self.window = window
        self.dependencyContainer = dependencyContainer
        self.userRepository = dependencyContainer.userRepository
        self.userSession = dependencyContainer.userSession
        self.deeplinkService = dependencyContainer.deeplinkService
        self.pushNotificationsManager = dependencyContainer.pushNotificationsManager
        self.favoritesManager = dependencyContainer.favoritesManager
        self.guestUserRepository = dependencyContainer.guestUserRepository
        self.analyticsService = AnalyticsService.shared
        self.launchOptions = launchOptions
        self.navigationController = CustomNavigationController(rootViewController: tabBarController)
        setupCurrentSessionBindings()
    }
    
    func start(animated: Bool = true) {
        setupTabBar()
        window.transitionRootViewController(navigationController)
        
        deeplinkService.processScheduledLaunchAction()
        deeplinkService.processLaunchOptions()
        if let launchOptions {
            pushNotificationsManager.processPushNotification(options: launchOptions)
            self.launchOptions = nil
        }
        
        if userRepository.currentUser?.wasRecentlyApprovedAsCreator == true {
            showApprovedCreatorView(animated: animated)
        }
       
        if userSession.didPresentPushNotificationsPermission == false {
            Task.detached(priority: .utility) { @MainActor [weak self] in
                let notificationsStatus = await self?.pushNotificationsManager.getCurrentAuthorizationStatus()
                if notificationsStatus == .notDetermined {
                    self?.showPushNotificationsReminderView()
                }
            }
        }
    }
    
    private func setupTabBar() {
        dependencyContainer.tabBarController = { [weak tabBarController] in
            return tabBarController
        }
        
        let discoverNavigationController = CustomNavigationController()
        let searchNavigationController = CustomNavigationController()
        let profileNavigationController = CustomNavigationController()
        
        self.discoverCoordinator = DiscoverFeedCoordinator(
            navigationController: discoverNavigationController,
            rootNavigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        self.searchCoordinator = SearchCoordinator(
            navigationController: searchNavigationController,
            rootNavigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        self.profileCoordinator = ProfileCoordinator(
            navigationController: profileNavigationController,
            rootNavigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        
        tabBarController.setViewControllers([discoverNavigationController, searchNavigationController, profileNavigationController], animated: false)
        
        discoverCoordinator?.start()
        searchCoordinator?.start()
        profileCoordinator?.start()
    }
}

//MARK: - PushNotificationsReminder
private extension TabBarCoordinator {
    
    func showPushNotificationsReminderView(animated: Bool = true) {
        let pushNotificationsVC = PushNotificationsReminderViewController(
            pushNotificationsHandler: pushNotificationsManager,
            onDismiss: { [weak self] in
                self?.userSession.didPresentPushNotificationsPermission = true
                self?.navigationController.dismiss(animated: animated)
            }
        )
        
        navigationController.present(pushNotificationsVC, animated: animated)
    }
}

//MARK: - Approved Creator
private extension TabBarCoordinator {
    
    func showApprovedCreatorView(animated: Bool) {
        let approvedCreatorVC = ApprovedCreatorViewController { [weak self] in
            self?.navigationController.dismiss(animated: animated) {
                self?.tabBarController.selectedTab = .profile
            }
        }
        analyticsService.trackActionEvent(.creator_registration_steps, properties: [.registration_step: RegistrationStepValue.creator_application_approved])
        
        DispatchQueue.main.asyncAfter(seconds: 1) { [weak self] in
            self?.navigationController.present(approvedCreatorVC, animated: animated)
        }
    }
}

//MARK: - Current Session
private extension TabBarCoordinator {
    
    func setupCurrentSessionBindings() {
        userSession.onSessionClosed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.analyticsService.reset()
                self?.favoritesManager.reset()
                if let fcmToken = self?.pushNotificationsManager.pushNotificationsTokenPublisher.value {
                    self?.guestUserRepository.registerGuestUser(fcmToken: fcmToken)
                }
            }
            .store(in: &cancellables)
        
        userSession.currentUserRoleSubject.sink { [weak self] userRole in
            guard let self, userRole != nil,
                  let currentUserID = self.userRepository.currentUser?.id else {
                return
            }
            Task(priority: .utility) {
                await self.favoritesManager.fetchFavoriteItems(userID: currentUserID)
            }
        }
        .store(in: &cancellables)
        
        deeplinkService.onSignUpWithToken
            .receive(on: DispatchQueue.main)
            .delay(for: .seconds(1) , scheduler: DispatchQueue.main)
            .sink { [weak self] signUpToken in
                guard self?.userSession.isValid == false else {
                    return
                }
                if self?.discoverCoordinator?.isSignInFlowActive == true {
                    self?.discoverCoordinator?.handleSignIn(token: signUpToken, animated: true)
                } else {
                    self?.profileCoordinator?.handleSignIn(token: signUpToken, animated: true)
                    self?.tabBarController.selectedTab = .profile
                }
            }
            .store(in: &cancellables)
    }
}
