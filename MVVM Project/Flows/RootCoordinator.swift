//
//  RootCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import Foundation
import UIKit
import Combine
import AppTrackingTransparency
import StoreKit
import Kingfisher

class RootCoordinator {
    
    //MARK: - Properties
    let window: UIWindow
    let dependencyContainer: DependencyContainer
    private(set) var tabBarCoordinator: TabBarCoordinator?
    private var launchOptions: [UIApplication.LaunchOptionsKey:Any]?
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Services
    private let userSession: UserSession
    private let userRepository: UserRepository
    private let authenticationService: AuthenticationServiceProtocol
    private let pushNotificationsManager: PushNotificationsManager
    private let guestUserRepository: GuestUserRepository
    private let analtyticsService: AnalyticsServiceProtocol
    private let dependencyContainerBuilder = DependencyContainerBuilder()
    
    init(window: UIWindow, launchOptions: [UIApplication.LaunchOptionsKey:Any]?) {
        self.window = window
        self.launchOptions = launchOptions
        self.dependencyContainer = dependencyContainerBuilder.createDependencyContainer()
        self.authenticationService = dependencyContainer.authenticationService
        self.userRepository = dependencyContainer.userRepository
        self.pushNotificationsManager = dependencyContainer.pushNotificationsManager
        self.guestUserRepository = dependencyContainer.guestUserRepository
        self.userSession = dependencyContainer.userSession
        self.analtyticsService = AnalyticsService.shared
        
        setupRemoteImageCachePolicy()
        setupForceUpdateBinding()
        handleAppInstallIfNeeded()
        setupFCMTokenBinding()
    }
    
    //MARK: - Functionality
    func start() {
        self.setupLaunchScreen()
        Task(priority: .userInitiated) {
            await withTaskGroup(of: Void.self) { [unowned self] sessionGroup in
                #if PRODUCTION
                sessionGroup.addTask(priority: .userInitiated) {
                    await self.showSplashScreen()
                }
                #endif
                sessionGroup.addTask(priority: .utility) {
                    await self.resetUserSessionIfNeeded()
                }
                if self.userSession.isValid {
                    sessionGroup.addTask(priority: .utility) {
                        if let currentUser = await self.userRepository.getCurrentUser(loadFromCache: false) {
                            self.analtyticsService.identify(user: currentUser)
                        }
                    }
                } else {
                    self.analtyticsService.identifyAlias(temporaryID: UUID().uuidString)
                }
            }
            await MainActor.run {
                setupRootController()
            }
        }
    }
    
    private func setupLaunchScreen() {
        let splashViewController = UIViewController()
        splashViewController.view.backgroundColor = .darkGreen
        window.rootViewController = splashViewController
    }
    
    private func setupRootController() {
        if userSession.didShowGuestOnboarding {
            self.tabBarCoordinator = TabBarCoordinator(
                window: window,
                dependencyContainer: dependencyContainer,
                launchOptions: launchOptions
            )
            tabBarCoordinator?.start()
        } else {
            showGuestOnboarding()
        }
        
        ATTrackingManager.requestTrackingAuthorization { _ in}
    }
    
    @MainActor
    private func showSplashScreen() async {
        await withCheckedContinuation { continuation in
            let splashVC = SplashViewController(onFinishedInteraction: {
                continuation.resume()
            })
            window.rootViewController = splashVC
        }
    }
    
    private func showGuestOnboarding() {
        let guestOnboardingViewModel = GuestOnboardingViewModel(
            authenticationService: dependencyContainer.authenticationService,
            pushNotificationsHandler: pushNotificationsManager,
            onFinishedInteraction: { [weak self] in
                self?.userSession.handleGuestOnboardingCompleted()
                self?.setupRootController()
            }
        )
        window.transitionRootViewController(GuestOnboardingViewController(viewModel: guestOnboardingViewModel))
    }
    
    private func handleAppInstallIfNeeded() {
        SKAdNetwork.updatePostbackConversionValue(AnalyticsService.ActionEvent.appInstall.skadEventValue ?? .zero)
        if userSession.installDate == nil {
            userSession.processAppInstall()
            analtyticsService.trackActionEvent(.appInstall, properties: nil)
        }
    }
}

private extension RootCoordinator {
    
    func resetUserSessionIfNeeded() async {
        guard await !userRepository.isUserProfileCompleted, userSession.isValid else {
            return
        }
        if let refreshToken = userSession.refreshToken {
            try? await authenticationService.logOut(refreshToken: refreshToken, fcmToken: PushNotificationsManager.fcmToken)
        }
        await MainActor.run {
            userSession.close()
        }
    }
    
    func setupRemoteImageCachePolicy() {
        let memoryCache = ImageCache.default.memoryStorage
        memoryCache.config.cleanInterval = 30
        memoryCache.config.countLimit = 50
        memoryCache.config.totalCostLimit = 250 * 1024 * 1024 // 250MB
    }
    
    func setupForceUpdateBinding() {
        dependencyContainer.forceAppUpdateMiddleware?.forceUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.tabBarCoordinator = nil
                self?.window.transitionRootViewController(ForceUpdateViewController())
            }
            .store(in: &cancellables)
    }
    
    func setupFCMTokenBinding() {
        pushNotificationsManager.pushNotificationsTokenPublisher
            .sink { [weak self] token in
                guard let token else { return }
                if self?.userSession.isValid == true {
                    return
                }
                self?.guestUserRepository.registerGuestUser(fcmToken: token)
            }
            .store(in: &cancellables)
    }
}
