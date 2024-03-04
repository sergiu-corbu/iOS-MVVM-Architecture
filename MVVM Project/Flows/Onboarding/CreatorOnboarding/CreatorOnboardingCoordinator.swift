//
//  CreatorOnboardingCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.11.2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class CreatorOnboardingCoordinator {
    
    weak var navigationController: UINavigationController?
    
    let dependencyContainer: DependencyContainer
    private let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    private let userSession: UserSession
    private let authenticationService: AuthenticationServiceProtocol
    
    let onFinishedInteraction = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var mailActionController: MailActionSheetController?
    
    init(dependencyContainer: DependencyContainer, navigationController: UINavigationController?) {
        self.dependencyContainer = dependencyContainer
        self.navigationController = navigationController
        self.userSession = dependencyContainer.userSession
        self.authenticationService = dependencyContainer.authenticationService
    }
    
    func start(signUpToken: String?, animated: Bool = true) {
        if userSession.isValid {
            showLinkSocialNetworks(animated: animated)
        } else if let signUpToken {
            presentSignUpConfirmation(signUpToken: signUpToken, animated: animated)
        } else {
            showEnterEmail(animated: animated)
        }
    }
    
    func continueWithSignUpToken(_ signUpToken: String, animated: Bool = true) {
        presentSignUpConfirmation(signUpToken: signUpToken, animated: animated)
    }
    
    private func showEnterEmail(animated: Bool) {
        let enterEmailViewModel = CreatorEnterEmailViewModel(authenticationService: authenticationService)
        enterEmailViewModel.onContinue.sink { [weak self] email in
            self?.trackRegistrationEvent(stepValue: RegistrationStepValue.email_capture)
            self?.showAccountConfirmation(email: email, animated: animated)
        }.store(in: &cancellables)
        enterEmailViewModel.onBack.sink { [weak self] in
            self?.navigationController?.popViewController(animated: animated)
        }.store(in: &cancellables)

        let enterEmailVC = UIHostingController(rootView: CreatorEnterEmailView(viewModel: enterEmailViewModel))
        enterEmailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(enterEmailVC, animated: animated)
    }
    
    private func showAccountConfirmation(email: String, animated: Bool) {
        let accountConfirmationView = AccountConfirmationView(userEmail: email, onBack: { [unowned self] in
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
            authenticationService: authenticationService, userSession: userSession,
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
        let profileSetupViewModel = CreatorProfileSetupViewModel(
            authenticationService: authenticationService,
            userRepository: dependencyContainer.userRepository
        )
        profileSetupViewModel.onBack.sink { [weak self] in
            self?.userSession.close()
            self?.navigationController?.popToRootViewController(animated: animated)
        }.store(in: &cancellables)

        profileSetupViewModel.onProfileCompleted.sink { [weak self] in
            self?.trackRegistrationEvent(stepValue: RegistrationStepValue.user_details_capture)
            self?.showLinkSocialNetworks(animated: animated)
        }.store(in: &cancellables)

        let completeProfileView = CreatorProfileSetupView(viewModel: profileSetupViewModel)
        let completeProfileVC = UIHostingController(rootView: completeProfileView)
        completeProfileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(completeProfileVC, animated: animated)
    }
    
    private func showLinkSocialNetworks(animated: Bool) {
        let socialNetworksViewModel = LinkSocialNetworksViewModel(
            creatorService: dependencyContainer.creatorService,
            userRepository: dependencyContainer.userRepository
        )
        socialNetworksViewModel.onBack.sink { [weak self] in
            self?.navigationController?.popViewController(animated: animated)
        }.store(in: &cancellables)
        
        socialNetworksViewModel.onContinue.sink { [weak self] firstName in
            self?.showApplicationReceived(firstName: firstName, animated: animated)
            self?.trackRegistrationEvent(stepValue: RegistrationStepValue.creator_social_handles)
        }.store(in: &cancellables)
        
        let socialNetworksVC = InteractivenessHostingController(rootView: LinkSocialNetworksView(viewModel: socialNetworksViewModel))
        socialNetworksVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(socialNetworksVC, animated: animated)
    }
    
    private func showApplicationReceived(firstName: String, isExistingUser: Bool = false, animated: Bool) {
        let applicationReceivedView = CreatorAuthenticationCompletedView(name: firstName) { [weak self] in
            self?.showAccountCreated(animated: animated)
        }
        let applicationReceivedVC = InteractivenessHostingController(rootView: applicationReceivedView)
        applicationReceivedVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(applicationReceivedVC, animated: animated)
        trackRegistrationEvent(stepValue: RegistrationStepValue.creator_soft_application_submitted)
    }
    
    private func showAccountCreated(animated: Bool) {
        let accountCreatedView = CreatorAccountCreatedView(onContinue: { [weak self] in
            self?.showCompleteCreatorApplication(animated: animated)
        })
        let accountCreatedVC = InteractivenessHostingController(rootView: accountCreatedView)
        accountCreatedVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(accountCreatedVC, animated: animated)
        userSession.currentUserRoleSubject.send(.shopper)
    }
    
    private func showCompleteCreatorApplication(animated: Bool) {
        let completeApplicationVM = CompleteCreatorApplicationViewModel(
            authenticationService: authenticationService,
            brandService: dependencyContainer.brandService
        )
        completeApplicationVM.onFinishedInteraction.sink { [weak self] in
            self?.showCreatorApplicationCompleted(animated: animated)
        }.store(in: &cancellables)
        completeApplicationVM.onCancel.sink { [weak self] in
            let alertController = UIAlertController.dismissActionAlert(destructiveAction: { [weak self] in
                self?.dismissAction()
            })
            self?.navigationController?.present(alertController, animated: animated)
        }.store(in: &cancellables)
        let completeApplicationVC = InteractivenessHostingController(rootView: CompleteCreatorApplicationView(viewModel: completeApplicationVM))
        completeApplicationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(completeApplicationVC, animated: animated)
    }
    
    private func showCreatorApplicationCompleted(animated: Bool) {
        let profileCompletedView = CreatorProfileCompletedView { [weak self] in
            self?.dismissAction()
            self?.userSession.currentUserRoleSubject.send(.shopper)
        }
        let profileCompletedVC = InteractivenessHostingController(rootView: profileCompletedView)
        profileCompletedVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileCompletedVC, animated: animated)
        trackRegistrationEvent(stepValue: RegistrationStepValue.creator_full_application_sumbitted)
    }
    
    private func dismissAction() {
        onFinishedInteraction.send()
        navigationController?.popToRootViewController(animated: true)
    }
}

//MARK: - Analytics
extension CreatorOnboardingCoordinator {
    
    func trackRegistrationEvent(stepValue: String) {
        analyticsService.trackActionEvent(.creator_registration_steps, properties: [.registration_step: stepValue])
    }
}
