//
//  ShopperOnboardingCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine

struct RegistrationContext {
    var type: OnboardingType = .register
    let source: RegistrationSource
}

enum RegistrationSource: String {
    case follow = "Follow"
    case feedSwipe = "Feed Swipe"
    case guestProfile = "Guest Profile"
}

enum OnboardingType {
    case register
    case signIn
    
    var navigationTitle: String {
        switch self {
        case .register: return Strings.NavigationTitles.join
        case .signIn: return Strings.NavigationTitles.welcomeBack
        }
    }
}

fileprivate enum NavigationContextType {
    
    case push(UINavigationController?)
    case present(UIViewController)
    
    var navigationController: UINavigationController? {
        switch self {
        case .push(let navVC):
            return navVC
        case .present(let vc):
            return vc as? UINavigationController
        }
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
    
    func dismissAction(animated: Bool, completion: (() -> Void)? = nil) {
        switch self {
        case .push(let navVC):
            navVC?.popToRootViewController(animated: animated)
            completion?()
        case .present(let vc):
            vc.dismiss(animated: animated, completion: completion)
        }
    }
}

class ShopperOnboardingCoordinator {
    
    weak var rootNavigationController: UINavigationController?
    let onFinishedInteraction = PassthroughSubject<Void, Never>()
    
    //MARK: - Services
    let userSession: UserSession
    let dependencyContainer: DependencyContainer
    private let authenticationService: AuthenticationServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    //MARK: - Internal
    private var navigationContext: NavigationContextType
    private let registrationContext: RegistrationContext
    private var mailActionController: MailActionSheetController?
    private var cancellables = Set<AnyCancellable>()
    
    init(registrationContext: RegistrationContext, dependencyContainer: DependencyContainer, rootNavigationController: UINavigationController?) {
        self.registrationContext = registrationContext
        self.dependencyContainer = dependencyContainer
        self.userSession = dependencyContainer.userSession
        self.rootNavigationController = rootNavigationController
        self.authenticationService = dependencyContainer.authenticationService
        self.navigationContext = .push(rootNavigationController)
    }
    
    func start(signUpToken: String?, animated: Bool = true) {
        if let signUpToken {
            presentSignUpConfirmation(signUpToken: signUpToken, animated: animated)
        } else {
            showEnterEmail(animated: animated)
        }
    }
    
    func startModally(signUpToken: String?, animated: Bool = true) {
        navigationContext = .present(CustomNavigationController())
        start(signUpToken: signUpToken, animated: animated)
    }
    
    func continueWithSignUpToken(_ signUpToken: String, animated: Bool = true) {
        presentSignUpConfirmation(signUpToken: signUpToken, animated: animated)
    }
    
    private func showEnterEmail(animated: Bool) {
        let enterEmailViewModel = EnterEmailViewModel(
            onboardingType: registrationContext.type,
            authenticationService: authenticationService
        )
        enterEmailViewModel.onContinue.sink { [weak self] email in
            self?.trackRegistrationEvent(stepValue: RegistrationStepValue.email_capture)
            self?.showAccountConfirmation(email: email, animated: animated)
        }.store(in: &cancellables)
        enterEmailViewModel.onBack.sink { [weak self] in
            self?.navigationContext.dismissAction(animated: animated)
        }.store(in: &cancellables)
        
        let enterEmailVC = UIHostingController(rootView: EnterEmailView(viewModel: enterEmailViewModel))
        enterEmailVC.hidesBottomBarWhenPushed = true
        
        switch navigationContext {
        case .push(let navVC):
            navVC?.pushViewController(enterEmailVC, animated: animated)
        case .present(let vc):
            navigationContext.navigationController?.setViewControllers([enterEmailVC], animated: false)
            navigationContext.navigationController?.modalPresentationStyle = .fullScreen
            rootNavigationController?.present(vc, animated: animated)
        }
    }
    
    private func showAccountConfirmation(email: String, animated: Bool) {
        let accountConfirmationView = AccountConfirmationView(
            userEmail: email,
            onboardingType: registrationContext.type,
            onBack: { [weak self] in
                self?.navigationContext.popViewController(animated: animated)
            }, onOpenMail: { [unowned self] in
                self.mailActionController = MailActionSheetController(
                    presentationViewController: self.navigationContext.navigationController,
                    shouldComposeMessage: false
                )
        })
        let accountConfirmationVC = UIHostingController(rootView: accountConfirmationView)
        navigationContext.pushViewController(accountConfirmationVC, animated: animated)
        trackRegistrationEvent(stepValue: RegistrationStepValue.email_sent)
    }
    
    private func presentSignUpConfirmation(signUpToken: String, animated: Bool) {
        let signUpConfirmationViewModel = SignUpConfirmationViewModel(
            authenticationCode: signUpToken,
            authenticationService: authenticationService,
            userSession: userSession,
            onCancel: { [weak self] in
                self?.navigationContext.navigationController?.dismiss(animated: animated)
            }, onFinishedValidation: { [weak self] user in
                guard let self else { return }
                self.trackRegistrationEvent(stepValue: RegistrationStepValue.email_verified)
                self.trackSignInEvent(user: user)
                if user.isProfileCompleted {
                    self.handleFinishedInteraction(animated: animated)
                } else {
                    self.navigationContext.navigationController?.dismiss(animated: animated, completion: { [weak self] in
                        self?.showProfileSetup(animated: animated)
                    })
                }
        })
        
        let signUpConfirmationVC = UIHostingController(rootView: SignUpConfirmationView(viewModel: signUpConfirmationViewModel))
        navigationContext.navigationController?.present(signUpConfirmationVC, animated: animated)
    }
    
    private func showProfileSetup(animated: Bool) {
        let profileSetupViewModel = ProfileSetupViewModel(
            userRepository: dependencyContainer.userRepository,
            authenticationService: authenticationService
        )
        profileSetupViewModel.onBack.sink { [weak self] in
            self?.userSession.close()
            self?.handleFinishedInteraction(animated: animated)
        }.store(in: &cancellables)
        
        profileSetupViewModel.onProfileCompleted.sink { [weak self] in
            self?.trackRegistrationEvent(stepValue: RegistrationStepValue.user_details_capture)
            self?.showProfileCompleted(animated: animated)
        }.store(in: &cancellables)
        
        let completeProfileView = ProfileSetupView(viewModel: profileSetupViewModel)
        let completeProfileVC = UIHostingController(rootView: completeProfileView)
        navigationContext.pushViewController(completeProfileVC, animated: animated)
    }
    
    private func showProfileCompleted(animated: Bool) {
        let profileCompletedView = ShopperAuthenticationCompletedView { [weak self] in
            self?.handleFinishedInteraction(animated: animated)
        }
        let profileCompletedVC = InteractivenessHostingController(rootView: profileCompletedView, statusBarStyle: .lightContent)
        navigationContext.pushViewController(profileCompletedVC, animated: animated)
        trackRegistrationEvent(stepValue: RegistrationStepValue.user_profile_completed)
    }
    
    func handleFinishedInteraction(animated: Bool) {
        switch navigationContext {
        case .push(_):
            rootNavigationController?.dismissPresentedViewControllerIfNeeded(animated: animated)
            rootNavigationController?.popToRootViewController(animated: animated)
            onFinishedInteraction.send()
        case .present(_):
            rootNavigationController?.dismiss(animated: animated, completion: { [weak self] in
                self?.onFinishedInteraction.send()
            })
        }
    }
}

//MARK: - Analytics
extension ShopperOnboardingCoordinator {
    
    func trackRegistrationEvent(stepValue: String) {
        analyticsService.trackActionEvent(.shopper_registration_steps, properties: [.registration_step: stepValue])
    }
    
    func trackSignInEvent(user: User) {
        let properties: AnalyticsProperties = [
            .username: user.formattedUsername,
            .account_name: user.fullName ?? "",
            .context: [AnalyticsService.EventProperty.account_id.rawValue: user.id],
            .registrationSource: registrationContext.source.rawValue
        ]
        analyticsService.trackActionEvent(user.isProfileCompleted ? .signed_in : .account_created, properties: properties)
    }
}
