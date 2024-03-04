//
//  ProfileCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.05.2023.
//

import Foundation
import UIKit
import Combine
import SwiftUI

class ProfileCoordinator: MainFlowCoordinator {
    
    //MARK: - Properties
    private var mailActionController: MailActionSheetController?
    private var imageSelectionCoordinator: ImageSelectionCoordinator?
    private var personalCreatorProfileVM: PersonalCreatorProfileViewModel?
    
    var currentUser: User? {
        return userRepository.currentUser
    }
    
    func start() {
        configureProfileViewController(animated: false)
        setupPushNotificationsBindings()
        setupUserSessionChanges()
        setupShareableBindings()
    }
    
    //MARK: - Base ViewController Setup
    private func configureProfileViewController(animated: Bool) {
        let profileVC: UIViewController
        
        if let user = currentUser, user.role == .creator {
            let personalCreatorProfileVM = PersonalCreatorProfileViewModel(
                creator: user, userRepository: userRepository, userSession: userSession, deeplinkProvider: deeplinkService,
                checkoutCartManager: dependencyContainer.checkoutCartManager,
                creatorService: creatorService, showService: dependencyContainer.showRepository, uploadService: dependencyContainer.uploadService,
                pushNotificationsInteractor: dependencyContainer.pushNotificationsManager.pushNotificationsInteractor,
                showStreamBuilder: showStreamBuilder,
                creatorProfileAction: createProfileActionHandler(), showDidPublishSubject: dependencyContainer.contentCreationService.showDidPublishSubject
            )
            personalCreatorProfileVM.baseProfileAction.onSelectProducts = { [weak self] productSelectable in
                self?.showProductsDetail(productSelectable: productSelectable, animated: true)
            }
            personalCreatorProfileVM.baseProfileAction.onSelectFavoriteProduct = { [weak self] product in
                self?.showProductsDetail(productSelectable: ProductSelectableDTO(product: product, creator: user), animated: true)
                self?.trackFavoriteProductSelection(for: product, creator: user)
            }
            personalCreatorProfileVM.baseProfileAction.onSelectBrand = { [weak self] brand in
                self?.brandProfileCoordinator.showBrandProfileView(brand, navigationSource: .creatorProfile, animated: true)
            }
            personalCreatorProfileVM.baseProfileAction.onRequestAuthentication = { [weak self] completion in
                self?.showShopperOnboarding(registrationContext: RegistrationContext(source: .follow), startModally: true, completionHandler: completion, animated: true)
            }
            personalCreatorProfileVM.baseProfileAction.onSelectShow = { [weak self] showSelection in
                self?.presentShowsDetailView(showSelection.shows, selectedShow: showSelection.selectedShow, animated: true)
            }
            personalCreatorProfileVM.baseProfileAction.onSelectFollowSection = { [weak self] followSection in
                if let currentUser = self?.currentUser {
                    self?.showFollowSection(user: currentUser, sectionType: followSection, animated: true)
                }
            }
            self.personalCreatorProfileVM = personalCreatorProfileVM
            profileVC = PersonalCreatorProfileViewController(viewModel: personalCreatorProfileVM)
            
        } else {
            let shopperProfileViewModel = ShopperProfileViewModel(
                userRepository: dependencyContainer.userRepository,
                userSession: dependencyContainer.userSession,
                checkoutCartManager: dependencyContainer.checkoutCartManager,
                actionHandler: createProfileActionHandler()
            )
            
            profileVC = ShopperProfileViewController(viewModel: shopperProfileViewModel)
        }
        
        navigationController.setViewControllers([profileVC], animated: animated)
    }
    
    //MARK: - Actions
    override func handleOnboardingFinishedInteraction() {
        super.handleOnboardingFinishedInteraction()
        configureProfileViewController(animated: true)
    }
    
    func createProfileActionHandler(animated: Bool = true) -> ProfileActionHandler {
        return ProfileActionHandler(onShowOrders: { [weak self] in
            self?.showOrdersView()
        }, onShowFavorites: { [weak self] in
            if let userID = self?.currentUser?.id {
                self?.showProfileFavorites(userID: userID)
            }
        }, onShowPersonalDetails: { [weak self] in
            self?.showPersonalDetails()
        }, onManageAccount: { [weak self] in
            self?.showManageAccount()
        }, onShowSettings: { [weak self] in
            if let currentUser = self?.currentUser {
                self?.showSettings(user: currentUser, animated: animated)
            }
        }, onEditProfile: { [weak self] in
            self?.showEditProfile(animated: animated)
        }, onPresentCart: { [weak self] in
            self?.checkoutCoordinator.start(animated: animated)
        }, onApplyToSell: { [weak self] in
            self?.showCreatorOnboarding(signUpToken: nil, animated: animated)
        }, onContactUs: { [weak self] in
            self?.mailActionController = MailActionSheetController(
                presentationViewController: self?.navigationController,
                shouldComposeMessage: true
            )
        }, onStartOnboardingFlow: { [weak self] _ in
            self?.showShopperOnboarding(registrationContext: RegistrationContext(source: .guestProfile), animated: animated)
        }, onSelectFollowSection:  { [weak self] in
            if let user = self?.currentUser {
                self?.showFollowSection(user: user, sectionType: .following, animated: animated)
            }
        }, onUploadShow: { [weak self] in
            self?.showCreateContent(animated: animated)
        }, onUpdateBio: { [weak self] in
            self?.showEditBio(animated: animated)
        }, onUpdateSocialLinks: { [weak self] in
            self?.showEditSocialNetwoks(animated: animated)
        }, onUploadProfilePicture: { [weak self] in
            self?.handleProfileImageUpload()
        })
    }
    
    
    //MARK: - Image Upload
    private func handleProfileImageUpload() {
        imageSelectionCoordinator = ImageSelectionCoordinator(navigationController: navigationController)
        imageSelectionCoordinator?.onImageLoaded
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.personalCreatorProfileVM?.error = error
                }
            }, receiveValue: { [weak self] selectedImage in
                self?.personalCreatorProfileVM?.handleSelectedImage(selectedImage)
            })
            .store(in: &cancellables)
        imageSelectionCoordinator?.start(allowsCropping: true)
    }
    
    //MARK: - Edit Profile
    private func showEditProfile(animated: Bool = true) {
        guard let personalCreatorProfileVM else {
            return
        }
        let editProfileVC = EditCreatorProfileViewController(
            user: personalCreatorProfileVM.creator,
            localProfileImage: personalCreatorProfileVM.localProfileImage,
            userRepository: userRepository, uploadService: dependencyContainer.uploadService
        )
        editProfileVC.profileImageDidChangeSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedImage in
                self?.personalCreatorProfileVM?.localProfileImage = updatedImage
            }
            .store(in: &cancellables)
        editProfileVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(editProfileVC, animated: animated)
    }
    
    private func showEditSocialNetwoks(animated: Bool = true) {
        let editSocialNetworksVC = EditSocialNetworksViewController(userRepository: userRepository)
        let navVC = UINavigationController(rootViewController: editSocialNetworksVC)
        navVC.navigationBar.isHidden = true
        navigationController.present(navVC, animated: animated)
    }
    
    private func showEditBio(animated: Bool = true) {
        let editBioViewModel = EditCreatorBioViewModel(
            creatorBio: personalCreatorProfileVM?.creator.bio,
            userRepository: userRepository
        )
        navigationController.presentHostingView(EditCreatorBioView(viewModel: editBioViewModel))
    }
    
    func showCreatorProfile(id creatorID: String) {
        if creatorID == currentUser?.id {
            return
        }
        
        Task(priority: .userInitiated) { @MainActor in
            do {
                guard let creator = try await creatorService.getPublicCreator(id: creatorID) else {
                    return
                }
                tabBarController?.selectedTab = .profile
                navigationController.dismissPresentedViewControllerIfNeeded(animated: false)
                showCreatorProfileView(creator, navigationSource: .sharedLink)
            } catch {
                ToastDisplay.showErrorToast(from: navigationController, error: error, animated: true)
            }
        }
    }
    
    func presentShowsDetailView(_ shows: [Show], selectedShow: Show, animated: Bool) {
        let showsDetailViewModel = ShowsDetailViewModel(selectedShowID: selectedShow.id, showsDataStore: StaticShowsDataStore(shows: shows), showVideoStreamBuilder: showStreamBuilder)
        let showsDetailView = ShowsDetailView(viewModel: showsDetailViewModel, showDetailInteraction: { [weak self] action, show in
            self?.handleShowDetailAction(action, show: show, animated: animated)
        })
        let showsDetailViewController = BaseShowDetailViewController(rootView: showsDetailView)
        showsDetailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(showsDetailViewController, animated: animated)
    }
    
    //MARK: - Orders
    func showOrdersView(animated: Bool = true) {
        let ordersViewController = OrdersViewController(orderService: dependencyContainer.orderService)
        ordersViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(ordersViewController, animated: animated)
    }
    
    //MARK: - Favorites
    func showProfileFavorites(userID: String, preselectedSection: FavoriteType? = nil, animated: Bool = true) {
        let favoritesViewModel = FavoritesListViewModel(
            userID: userID, preselectedSection: preselectedSection,
            favoritesService: dependencyContainer.favoritesService, favoritesManager: dependencyContainer.favoritesManager,
            favoritesListActionHandler: { [weak self] action in
            switch action {
            case .back:
                self?.navigationController.popViewController(animated: animated)
            case .selectProduct(let product):
                self?.showProductsDetail(productSelectable: ProductSelectableDTO(product: product), animated: animated)
            case .selectShow(let show):
                self?.presentShowDetailView(show, animated: animated)
            }
        })
        
        
        let favoritesViewController = UIHostingController(rootView: FavoritesListView(viewModel: favoritesViewModel))
        favoritesViewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(favoritesViewController, animated: animated)
    }
    
    //MARK: - Manage Account
    private func showManageAccount(animated: Bool = true) {
        let manageAccountViewModel = ManageAccountViewModel(
            userSession: dependencyContainer.userSession,
            authenticationService: dependencyContainer.authenticationService
        )
        manageAccountViewModel.onBack.sink { [weak self] in
            self?.navigationController.popViewController(animated: animated)
        }
        .store(in: &cancellables)
        
        let manageAccountVC = ManageAccountViewController(viewModel: manageAccountViewModel)
        manageAccountVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(manageAccountVC, animated: animated)
    }
    
    private func showSettings(user: User, animated: Bool) {
        let settingsView = CreatorSettingsView(user: user, profileActions: createProfileActionHandler(), onBack: { [weak self] in
            self?.navigationController.popViewController(animated: animated)
        })
        navigationController.pushHostingController(settingsView)
    }
    
    private func showPersonalDetails(animated: Bool = true) {
        guard let user = currentUser else {
            return
        }
        let personalDetailsViewModel = PersonalDetailsViewModel(
            user: user,
            userRepository: dependencyContainer.userRepository,
            userSession: dependencyContainer.userSession,
            authenticationService: dependencyContainer.authenticationService
        )
        personalDetailsViewModel.onFinishedInteraction.sink { [weak self] in
            self?.navigationController.popViewController(animated: animated)
        }
        .store(in: &cancellables)
        let personalDetailsVC = UIHostingController(rootView: PersonalDetailsView(viewModel: personalDetailsViewModel))
        personalDetailsVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(personalDetailsVC, animated: animated)
    }
}

//MARK: - Push Notifications
private extension ProfileCoordinator {
    
    func setupPushNotificationsBindings() {
        let notificationsInteractor = pushNotificationsManager.pushNotificationsInteractor
        Publishers.MergeMany(
            notificationsInteractor.creatorShowStatusChanged.map { _ in }.eraseToAnyPublisher(),
            notificationsInteractor.creatorShouldOpenSetupRoom.map { _ in }.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { [weak self] in
            self?.navigationController.popToRootViewController(animated: false)
            self?.tabBarController?.selectedTab = .profile
        }
        .store(in: &cancellables)
        
        notificationsInteractor.favoritesReminderPublisher.receive(on: DispatchQueue.main)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] favoriteType in
                self?.navigationController.popToRootViewController(animated: false)
                self?.tabBarController?.selectedTab = .profile
                if let userID = self?.currentUser?.id {
                    self?.showProfileFavorites(userID: userID, preselectedSection: favoriteType, animated: true)
                }
            }
            .store(in: &cancellables)
    }
}

//MARK: - Shareable Content
private extension ProfileCoordinator {
    
    func setupShareableBindings() {
        deeplinkService.onOpenCreatorProfile.receive(on: DispatchQueue.main)
            .delay(for: .seconds(1) , scheduler: DispatchQueue.main)
            .sink { [weak self] creatorID in
                self?.showCreatorProfile(id: creatorID)
            }
            .store(in: &cancellables)
        deeplinkService.onOpenBrandProfile.receive(on: DispatchQueue.main)
            .delay(for: .seconds(1) , scheduler: DispatchQueue.main)
            .sink { [weak self] brandID in
                self?.brandProfileCoordinator.showBrandProfileView(id: brandID, animated: true)
            }
            .store(in: &cancellables)
        deeplinkService.onOpenProductDetails.receive(on: DispatchQueue.main)
            .delay(for: .seconds(1) , scheduler: DispatchQueue.main)
            .sink { [weak self] productID in
                self?.brandProfileCoordinator.showProductFromBrandProfileView(productID: productID, animated: true)
            }
            .store(in: &cancellables)
    }
}

//MARK: - Current User Changes
private extension ProfileCoordinator {
    
    func setupUserSessionChanges(animated: Bool = true) {
        userSession.currentUserRoleSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userRole in
                if let currentUser = self?.currentUser {
                    self?.analyticsService.identify(user: currentUser)
                }
                if userRole == nil {
                    self?.configureProfileViewController(animated: true)
                }
            }
            .store(in: &cancellables)
    }
}
