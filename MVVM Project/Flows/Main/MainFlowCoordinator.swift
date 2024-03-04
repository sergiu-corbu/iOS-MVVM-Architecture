//
//  MainFlowCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.05.2023.
//

import Foundation
import UIKit
import Combine
import SwiftUI

class MainFlowCoordinator {
    
    //MARK: - Coordinators
    private var contentCreationCoordinator: ContentCreationCoordinator?
    private var shopperOnboardingCoordinator: ShopperOnboardingCoordinator?
    private var creatorOnboardingCoordinator: CreatorOnboardingCoordinator?
    private var productsDetailCoordinator: ProductsDetailCoordinator?
    lazy var brandProfileCoordinator: BrandProfileCoordinator = {
        return BrandProfileCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer,
            showDetailInteractionHandler: { [weak self] showAction in
                self?.handleShowDetailAction(showAction, show: nil, animated: true)
            },
            brandProfileActionHandler: { [weak self] brandProfileAction in
                self?.handleBrandProfileAction(brandProfileAction, animated: true)
            }
        )
    }()
    
    lazy var checkoutCoordinator = CheckoutCoordinator(dependencyContainer: dependencyContainer, navigationController: navigationController)
    
    
    //MARK: - Properties
    private(set) var isSignInFlowActive = false
    let navigationController: CustomNavigationController
    weak var rootNavigationController: UINavigationController?
    lazy var featuredShowsDataStore = PaginatedShowsDataStore(showService: dependencyContainer.showRepository)
    var cancellables = Set<AnyCancellable>()
    
    var tabBarController: TabBarController? {
        return dependencyContainer.tabBarController?()
    }
    
    //MARK: - Depencies
    let dependencyContainer: DependencyContainer
    let userRepository: UserRepository
    let userSession: UserSession
    let deeplinkService: DeeplinkService
    let favoritesManager: FavoritesManager
    let contentCreationService: ContentCreationServiceProtocol
    let creatorService: CreatorServiceProtocol
    let pushNotificationsManager: PushNotificationsManager
    let showStreamBuilder: ShowVideoStreamBuilder
    let analyticsService: AnalyticsServiceProtocol
    
    init(navigationController: CustomNavigationController, rootNavigationController: UINavigationController, dependencyContainer: DependencyContainer) {
        self.navigationController = navigationController
        self.rootNavigationController = rootNavigationController
        self.dependencyContainer = dependencyContainer
        self.userRepository = dependencyContainer.userRepository
        self.userSession = dependencyContainer.userSession
        self.deeplinkService = dependencyContainer.deeplinkService
        self.contentCreationService = dependencyContainer.contentCreationService
        self.creatorService = dependencyContainer.creatorService
        self.favoritesManager = dependencyContainer.favoritesManager
        self.pushNotificationsManager = dependencyContainer.pushNotificationsManager
        self.analyticsService = AnalyticsService.shared
        self.showStreamBuilder = dependencyContainer.showVideoStreamBuilder
        
        setup()
    }
    
    /// Note: Additional setup
    private func setup() {
        favoritesManager.setAuthenticationAction { [weak self] completion in
            self?.navigationController.dismiss(animated: true, completion: {
                self?.showShopperOnboarding(
                    registrationContext: RegistrationContext(source: .feedSwipe),
                    startModally: true, completionHandler: completion, animated: true
                )
            })
        }
    }
    
    //MARK: - Show Detail
    func presentShowDetailView(_ show: Show, animated: Bool) {
        let showDetailView = showStreamBuilder.createShowStreamableDetailView(
            show, showPresentationType: .singleView,
            onShowDetailInteraction: { [weak self] action in
                self?.handleShowDetailAction(action, show: show, animated: animated)
            }
        )
        let showDetailViewController = BaseShowDetailViewController(rootView: showDetailView)
        showDetailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(showDetailViewController, animated: animated)
    }
    
    func handleShowDetailAction(_ showActionType: ShowDetailInteractionType, show: Show?, animated: Bool) {
        switch showActionType {
        case .close(let shouldProcessShow):
            if shouldProcessShow, let show {
                featuredShowsDataStore.removeShow(id: show.id)
            }
            navigationController.popViewController(animated: animated)
        case .creatorSelected(let creator):
            showCreatorProfileView(creator, navigationSource: .showDetail, animated: animated)
        case .productSelected(let productSelectable):
            showProductsDetail(productSelectable: productSelectable, animated: animated)
        case .brandSelected(let brand):
            brandProfileCoordinator.showBrandProfileView(brand, navigationSource: .showDetail, animated: animated)
        case .shareLinkGenerated(let shareLinkVC):
            navigationController.present(shareLinkVC, animated: animated)
        case .didUpdateShow(let updatedShow):
            featuredShowsDataStore.updatePublicShow(updatedShow)
        case .onRequestAuthentication(let source, let completion):
            showShopperOnboarding(registrationContext: RegistrationContext(source: source), startModally: true, completionHandler: completion, animated: animated)
        }
    }
    
    //MARK: - Brand Profile Action
    func handleBrandProfileAction(_ brandProfileAction: BrandProfileAction, animated: Bool) {
        switch brandProfileAction {
        case .back:
            navigationController.popViewController(animated: true)
        case .selectProduct(let product):
            showProductsDetail(productSelectable: ProductSelectableDTO(product: product))
            var properties = product.baseAnalyticsProperties
            if let selectedBrand = brandProfileCoordinator.currentPresentedBrand {
                properties.merge(other: selectedBrand.baseAnalyticsProperties)
            }
            analyticsService.trackActionEvent(.select_brand_product, properties: properties)
        case .requestSignIn(let completion):
            showShopperOnboarding(registrationContext: RegistrationContext(source: .follow), startModally: true, completionHandler: completion, animated: animated)
        case .shareLink(let shareVC):
            navigationController.present(shareVC, animated: animated)
        }
    }
    
    func showCreateContent(startFromGiftRequest: Bool = false, animated: Bool = true) {
        self.contentCreationCoordinator = ContentCreationCoordinator(
            dependencyContainer: dependencyContainer,
            startFromGiftingRequest: startFromGiftRequest,
            navigationController: navigationController
        )
        contentCreationCoordinator?.start(animated: animated, onFinishedInteraction: { [weak self] didUploadContent in
            self?.navigationController.popToRootViewController(animated: animated)
            self?.contentCreationCoordinator = nil
            if didUploadContent {
                DispatchQueue.main.asyncAfter(seconds: 0.5) {
                    self?.tabBarController?.selectedTab = .profile
                }
            }
        })
    }
    
    //MARK: - Creator Profile
    func showCreatorProfileView(_ creator: Creator, navigationSource: ProfileNavigationSource?, animated: Bool = true) {
        let creatorProfileAccessLevel = getCreatorProfileAccesLevel(creator)
        var analyticsProperties = creator.baseAnalyticsProperties
        analyticsProperties[.source] = navigationSource?.rawValue
        
        switch creatorProfileAccessLevel {
        case .readOnly:
            let publicCreatorViewModel = PublicCreatorProfileViewModel(
                creator: creator, showService: dependencyContainer.showRepository,
                creatorService: dependencyContainer.creatorService,
                deeplinkProvider: dependencyContainer.deeplinkService,
                onBack: { [weak self] in
                    self?.navigationController.popViewController(animated: animated)
                }, onRequestAuthentication: { [weak self] completion in
                    self?.showShopperOnboarding(registrationContext: RegistrationContext(source: .follow), startModally: true, completionHandler: completion, animated: animated)
                }
            )
            publicCreatorViewModel.baseProfileAction.onSelectProducts = { [weak self] productSelectable in
                self?.showProductsDetail(productSelectable: productSelectable, animated: animated)
            }
            publicCreatorViewModel.baseProfileAction.onSelectFavoriteProduct = { [weak self] product in
                self?.showProductsDetail(productSelectable: ProductSelectableDTO(product: product, creator: creator), animated: animated)
                self?.trackFavoriteProductSelection(for: product, creator: creator)
            }
            publicCreatorViewModel.baseProfileAction.onSelectCreatorProfile = { [weak self] creator in
                self?.showCreatorProfileView(creator, navigationSource: .creatorProfile, animated: animated)
            }
            publicCreatorViewModel.baseProfileAction.onSelectBrand = { [weak self] brand in
                self?.brandProfileCoordinator.showBrandProfileView(brand, navigationSource: .creatorProfile, animated: animated)
            }
            publicCreatorViewModel.baseProfileAction.onSelectShow = { [weak self] showSelection in
                self?.presentShowsDetailView(showSelection.shows, selectedShow: showSelection.selectedShow, animated: animated)
                self?.trackShowSelection(for: showSelection.selectedShow, creator: creator)
            }
            publicCreatorViewModel.baseProfileAction.onSelectFollowSection = { [weak self] followSection in
                self?.showFollowSection(user: publicCreatorViewModel.creator, sectionType: followSection, animated: animated)
            }
            
            let publicCreatorVC = PublicCreatorProfileViewController(viewModel: publicCreatorViewModel, showVideoStreamBuilder: showStreamBuilder)
            publicCreatorVC.hidesBottomBarWhenPushed = true
            
            navigationController.pushViewController(publicCreatorVC, animated: animated)
            analyticsService.trackScreenEvent(.creator_profile, properties: analyticsProperties)
        case .readWrite:
            navigationController.popToRootViewController(animated: animated)
            analyticsService.trackScreenEvent(.personal_profile, properties: analyticsProperties)
            DispatchQueue.main.asyncAfter(seconds: 0.3) {
                self.tabBarController?.selectedTab = .profile
            }
        }
    }
    
    func showFollowSection(user: User, sectionType: FollowSectionType, animated: Bool) {
        if sectionType == .followers { //NOTE: blocking followers action as it is not in scope for now
            return
        }
        
        let followerListViewModel = FollowerListViewModel(
            user: user, contentType: sectionType,
            userRepository: userRepository,
            followService: dependencyContainer.followService,
            pushNotificationsPermissionHandler: pushNotificationsManager,
            followerListActionHandler: { [weak self] followAction in
                switch followAction {
                case .back:
                    self?.navigationController.popViewController(animated: animated)
                case .onRequestAuthentication(let completion):
                    self?.showShopperOnboarding(registrationContext: RegistrationContext(source: .follow), startModally: true, completionHandler: completion, animated: animated)
                case .selectUser(let user):
                    self?.showCreatorProfileView(user, navigationSource: .creatorFollowList)
                case .selectBrand(let brand):
                    self?.brandProfileCoordinator.showBrandProfileView(brand, navigationSource: .creatorFollowList, animated: animated)
                }
            }
        )
        
        let followerListView = FollowerListView(viewModel: followerListViewModel)
        let followerListSectionVC = UIHostingController(rootView: followerListView)
        followerListSectionVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(followerListSectionVC, animated: animated)
    }
    
    private func getCreatorProfileAccesLevel(_ creator: Creator) -> ProfileAccessLevel {
        guard let currentCreator = userRepository.currentUser else {
            return .readOnly
        }
        return currentCreator.id == creator.id ? .readWrite : .readOnly
    }

    func showSearchDetails(for searchItem: SearchViewModel.SearchActionType) {
        switch searchItem {
        case .brand(let brand):
            brandProfileCoordinator.showBrandProfileView(brand, navigationSource: .search, animated: true)
        case .creator(let creator):
            showCreatorProfileView(creator, navigationSource: .search)
        case .show(let show):
            presentShowDetailView(show, animated: true)
        case .product(let product):
            showProductsDetail(productSelectable: ProductSelectableDTO(product: product))
        case .checkoutCart:
            checkoutCoordinator.start(animated: true)
        }
    }
    
    func handleOnboardingFinishedInteraction() {
        creatorOnboardingCoordinator = nil
        shopperOnboardingCoordinator = nil
        isSignInFlowActive = false
        
        if userSession.isValid {
            pushNotificationsManager.updateCurrentUserFCMToken()
        }
    }
    
    private func presentShowsDetailView(_ shows: [Show], selectedShow: Show, animated: Bool) {
        let showsDetailViewModel = ShowsDetailViewModel(
            selectedShowID: selectedShow.id,
            showsDataStore: PaginatedShowsDataStore(showService: dependencyContainer.showRepository, shows: shows),
            showVideoStreamBuilder: showStreamBuilder
        )
        let showsDetailView = ShowsDetailView(viewModel: showsDetailViewModel, showDetailInteraction: { [weak self] action, show in
            self?.handleShowDetailAction(action, show: show, animated: animated)
        })
        navigationController.pushViewController(BaseShowDetailViewController(rootView: showsDetailView), animated: animated)
    }
}

//MARK: - Register & SignIn
extension MainFlowCoordinator {
    
    func showShopperOnboarding(registrationContext: RegistrationContext, startModally: Bool = false, signUpToken: String? = nil, completionHandler: (() -> Void)? = nil, animated: Bool) {
        shopperOnboardingCoordinator = ShopperOnboardingCoordinator(
            registrationContext: registrationContext,
            dependencyContainer: dependencyContainer,
            rootNavigationController: navigationController
        )
        isSignInFlowActive = true
        if startModally {
            shopperOnboardingCoordinator?.startModally(signUpToken: signUpToken, animated: animated)
        } else {
            shopperOnboardingCoordinator?.start(signUpToken: signUpToken, animated: animated)
        }
        
        shopperOnboardingCoordinator?.onFinishedInteraction.sink { [weak self] in
            self?.handleOnboardingFinishedInteraction()
            completionHandler?()
        }
        .store(in: &cancellables)
    }
    
    func showCreatorOnboarding(signUpToken: String?, animated: Bool) {
        creatorOnboardingCoordinator = CreatorOnboardingCoordinator(
            dependencyContainer: dependencyContainer,
            navigationController: navigationController
        )
        
        creatorOnboardingCoordinator?.start(signUpToken: signUpToken, animated: animated)
        creatorOnboardingCoordinator?.onFinishedInteraction.sink { [weak self] in
            self?.handleOnboardingFinishedInteraction()
        }.store(in: &cancellables)
    }
    
    func handleSignIn(token: String, animated: Bool) {
        if let shopperOnboardingCoordinator = shopperOnboardingCoordinator {
            shopperOnboardingCoordinator.continueWithSignUpToken(token)
        } else if let creatorOnboardingCoordinator = creatorOnboardingCoordinator {
            creatorOnboardingCoordinator.continueWithSignUpToken(token)
        } else {
            showShopperOnboarding(registrationContext: RegistrationContext(source: .guestProfile), signUpToken: token, animated: true)
        }
    }
}

//MARK: - ProductsDetail
extension MainFlowCoordinator {
    
    func showProductsDetail(productSelectable: ProductSelectableDTO, animated: Bool = true) {
        self.productsDetailCoordinator = ProductsDetailCoordinator(
            productSelectable: productSelectable,
            dependencyContainer: dependencyContainer,
            presentingNavigationController: self.navigationController,
            onFinishedInteraction: { [weak self] in
                self?.productsDetailCoordinator = nil
            }
        )
        
        productsDetailCoordinator?.start(animated: animated)
        productsDetailCoordinator?.onSelectBrand = { [weak self] selectedBrand in
            self?.brandProfileCoordinator.showBrandProfileView(selectedBrand, navigationSource: .productDetail, animated: animated)
        }
    }
}

//MARK: - Analytics
extension MainFlowCoordinator {
    
    func trackFavoriteProductSelection(for product: Product, creator: Creator) {
        var properties = product.baseAnalyticsProperties
        properties.merge(other: creator.baseAnalyticsProperties)
        analyticsService.trackActionEvent(.select_creator_favorite_product, properties: properties)
    }
    
    func trackShowSelection(for show: Show, creator: Creator) {
        var properties = show.baseAnalyticsProperties
        properties.merge(other: creator.baseAnalyticsProperties)
        analyticsService.trackActionEvent(.select_creator_show, properties: properties)
    }
}
