//
//  GuestOnboardingCoordinator.swift
//  Bond
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine

enum OnboardingType {
    case register
    case signIn
    
    var navigationTitle: String {
        switch self {
        case .register: return Strings.NavigationTitles.joinBond
        case .signIn: return Strings.NavigationTitles.welcomeBack
        }
    }
}

class GuestOnboardingCoordinator {
    
    weak var navigationController: UINavigationController?
    lazy var onFinishedInteraction = PassthroughSubject<Void, Never>()
    
    let dependencyContainer: DependencyContainer
    private let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    private var cancellables = Set<AnyCancellable>()
    private let onboardingType: OnboardingType
    
    private var mailActionController: MailActionSheetController?
    
    init(onboardingType: OnboardingType, dependencyContainer: DependencyContainer, navigationController: UINavigationController?) {
        self.onboardingType = onboardingType
        self.dependencyContainer = dependencyContainer
        self.navigationController = navigationController
    }
    
    func start(signUpToken: String?, animated: Bool = true) {
        if let signUpToken {
            presentSignUpConfirmation(signUpToken: signUpToken, animated: animated)
        } else {
            showEnterEmail(animated: animated)
        }
    }
    
    func continueWithSignUpToken(_ signUpToken: String, animated: Bool = true) {
        presentSignUpConfirmation(signUpToken: signUpToken, animated: animated)
    }
    
    private func showEnterEmail(animated: Bool) {
        let enterEmailViewModel = EnterEmailViewModel(
            onboardingType: onboardingType,
            authenticationService: dependencyContainer.authenticationService
        )
        enterEmailViewModel.onContinue.sink { [weak self] email in
            self?.trackRegistrationEvent(stepValue: RegistrationStepValue.email_capture)
            self?.showAccountConfirmation(email: email, animated: animated)
        }.store(in: &cancellables)
        enterEmailViewModel.onBack.sink { [weak self] in
            self?.navigationController?.popViewController(animated: animated)
        }.store(in: &cancellables)
        
        let enterEmailVC = UIHostingController(rootView: EnterEmailView(viewModel: enterEmailViewModel))
        enterEmailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(enterEmailVC, animated: animated)
    }
    
    private func showAccountConfirmation(email: String, animated: Bool) {
        let accountConfirmationView = AccountConfirmationView(
            userEmail: email,
            onboardingType: onboardingType,
            onBack: { [unowned self] in
                self.navigationController?.popViewController(animated: animated)
            }, onOpenMail: { [unowned self] in
                self.mailActionController = MailActionSheetController(
                    presentationViewController: self.navigationController,
                    shouldComposeMessage: false
            )
        })
        let accountConfirmationVC = UIHostingController(rootView: accountConfirmationView)
        accountConfirmationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(accountConfirmationVC, animated: animated)
        
        trackRegistrationEvent(stepValue: RegistrationStepValue.email_sent)
    }
    
    private func presentSignUpConfirmation(signUpToken: String, animated: Bool) {
        let signUpConfirmationViewModel = SignUpConfirmationViewModel(
            authenticationCode: signUpToken,
            authenticationService: dependencyContainer.authenticationService,
            userSession: dependencyContainer.userSession,
            onCancel: { [weak self] in
                self?.navigationController?.dismiss(animated: animated)
            }, onFinishedValidation: { [weak self] user in
                self?.trackRegistrationEvent(stepValue: RegistrationStepValue.email_verified)
                self?.navigationController?.dismiss(animated: animated, completion: {
                    if user.isProfileCompleted {
                        self?.onFinishedInteraction.send()
                    } else {
                        self?.showProfileSetup(animated: animated)
                    }
                })
            })
        
        let signUpConfirmationVC = UIHostingController(rootView: SignUpConfirmationView(viewModel: signUpConfirmationViewModel))
        navigationController?.present(signUpConfirmationVC, animated: animated)
    }
    
    private func showProfileSetup(animated: Bool) {
        let profileSetupViewModel = ProfileSetupViewModel(
            userRepository: dependencyContainer.userRepository,
            userSession: dependencyContainer.userSession,
            authenticationService: dependencyContainer.authenticationService
        )
        profileSetupViewModel.onBack.sink { [weak self] in
            self?.dependencyContainer.userSession.close()
            self?.navigationController?.popToRootViewController(animated: animated)
        }.store(in: &cancellables)
        
        profileSetupViewModel.onProfileCompleted.sink { [weak self] in
            self?.trackRegistrationEvent(stepValue: RegistrationStepValue.user_details_capture)
            self?.showProfileCompleted(animated: animated)
        }.store(in: &cancellables)
        
        let completeProfileView = ProfileSetupView(viewModel: profileSetupViewModel)
        let completeProfileVC = UIHostingController(rootView: completeProfileView)
        completeProfileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(completeProfileVC, animated: animated)
    }
    
    private func showProfileCompleted(animated: Bool) {
        let profileCompletedView = ShopperAuthenticationCompletedView { [weak self] in
            self?.onFinishedInteraction.send()
        }
        let profileCompletedVC = InteractivenessHostingController(rootView: profileCompletedView, statusBarStyle: .lightContent)
        profileCompletedVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileCompletedVC, animated: animated)
        
        trackRegistrationEvent(stepValue: RegistrationStepValue.user_profile_completed)
    }
}

//MARK: - Analytics
extension GuestOnboardingCoordinator {
    
    func trackRegistrationEvent(stepValue: String) {
        analyticsService.trackActionEvent(.shopper_registration_steps, properties: [.registration_step: stepValue])
    }
}
