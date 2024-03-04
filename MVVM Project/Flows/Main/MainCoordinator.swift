//
//  MainCoordinator.swift
//  Bond
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation
import Combine
import UIKit
import SwiftUI

class MainCoordinator {
    
    //MARK: Properties
    let window: UIWindow
    private let navigationController: UINavigationController
    private let tabBarController = TabBarController()
    
    private lazy var showsDataStore = ShowsDataStore(showService: dependencyContainer.showService)
    private lazy var showVideoStreamBuilder: ShowVideoStreamBuilder = {
        return ShowVideoStreamBuilder(
            showService: dependencyContainer.showService,
            liveStreamService: dependencyContainer.liveStreamService,
            deeplinkProvider: dependencyContainer.deeplinkService,
            userRepository: userRepository,
            remoteNotificationsHandler: dependencyContainer.remoteNotificationsManager,
            followService: dependencyContainer.followService
        )
    }()
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: Services
    private let dependencyContainer: DependencyContainer
    private let userRepository: UserRepository
    private let userSession: UserSession
    private let deeplinkService: DeeplinkService
    private let contentCreationService: ContentCreationServiceProtocol
    private let remoteNotificationsManager: RemoteNotificationsManager
    private let analyticsService: AnalyticsServiceProtocol
    
    //MARK: Coordinators
    private var guestOnboardingCoordinator: GuestOnboardingCoordinator?
    private var creatorOnboardingCoordinator: CreatorOnboardingCoordinator?
    private var contentCreationCoordinator: ContentCreationCoordinator?
    private var productsDetailCoordinator: ProductsDetailCoordinator?
    
    init(window: UIWindow, dependencyContainer: DependencyContainer, launchOptions: [UIApplication.LaunchOptionsKey:Any]?) {
        self.window = window
        self.dependencyContainer = dependencyContainer
        self.userRepository = dependencyContainer.userRepository
        self.deeplinkService = dependencyContainer.deeplinkService
        self.contentCreationService = dependencyContainer.contentCreationService
        self.remoteNotificationsManager = dependencyContainer.remoteNotificationsManager
        self.analyticsService = AnalyticsService.shared
        self.userSession = dependencyContainer.userSession
        self.navigationController = CustomNavigationController(rootViewController: tabBarController)
        
        self.setupPublishers()
        if let launchOptions {
            deeplinkService.processLaunchOptions(launchOptions)
            remoteNotificationsManager.processRemoteNotification(options: launchOptions)
        }
    }
    
    func start(animated: Bool = true) {
        let user = userRepository.currentUser
        setupTabBar(user: user)
        window.transitionRootViewController(navigationController)
        
        deeplinkService.processScheduledLaunchAction()
        
        if user?.wasRecentlyApprovedAsCreator == true {
            DispatchQueue.main.asyncAfter(seconds: 1) { [weak self] in
                self?.showApprovedCreatorView(animated: animated)
            }
        }
    }
    
    private func setupTabBar(user: User?) {
        dependencyContainer.tabBarController = { [weak tabBarController] in
            return tabBarController
        }
        
        let homeVC = setupHomeViewController()
        let profileVC = configureProfileViewController(user: user, animated: true)
        let viewControllers = [homeVC, profileVC].map { CustomNavigationController(rootViewController: $0) }
        
        tabBarController.setViewControllers(viewControllers, animated: false)
    }
}

//MARK: Flows
private extension MainCoordinator {
    
    //MARK: - Onboarding
    func showGuestOnboarding(onboardingType: OnboardingType, signUpToken: String?, animated: Bool) {
        guestOnboardingCoordinator = GuestOnboardingCoordinator(
            onboardingType: onboardingType,
            dependencyContainer: dependencyContainer,
            navigationController: navigationController
        )
        
        guestOnboardingCoordinator?.start(signUpToken: signUpToken, animated: animated)
        guestOnboardingCoordinator?.onFinishedInteraction.sink { [weak self] in
            self?.handleOnboardingFinishedInteraction(animated: animated)
        }.store(in: &cancellables)
    }
    
    func showCreatorOnboarding(signUpToken: String?, animated: Bool) {
        creatorOnboardingCoordinator = CreatorOnboardingCoordinator(
            dependencyContainer: dependencyContainer,
            navigationController: navigationController
        )
        
        creatorOnboardingCoordinator?.start(signUpToken: signUpToken, animated: animated)
        creatorOnboardingCoordinator?.onFinishedInteraction.sink { [weak self] in
            self?.handleOnboardingFinishedInteraction(animated: animated)
        }.store(in: &cancellables)
    }
    
    private func handleOnboardingFinishedInteraction(animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
        creatorOnboardingCoordinator = nil
        guestOnboardingCoordinator = nil
        tabBarController.selectedTab = .profile
        
        if userSession.isValid {
            remoteNotificationsManager.updateCurrentUserFCMToken()
        }
    }
    
    //MARK: Create content
    func showCreateContent(animated: Bool = true) {
        self.contentCreationCoordinator = ContentCreationCoordinator(
            dependencyContainer: dependencyContainer,
            navigationController: navigationController
        )
        contentCreationCoordinator?.onFinishedInteraction.sink { [weak self] in
            self?.navigationController.popToRootViewController(animated: animated)
            self?.contentCreationCoordinator = nil
        }.store(in: &cancellables)
        contentCreationCoordinator?.start(animated: animated)
    }
    
    //MARK: Creator Profile
    func showCreatorProfileView(_ creator: Creator, animated: Bool = true) {
        let creatorProfileAccessLevel = getCreatorProfileAccesLevel(creator)
        switch creatorProfileAccessLevel {
        case .readOnly:
            let publicCreatorViewModel = PublicCreatorProfileViewModel(
                creator: creator, onBack: { [weak self] in
                    self?.navigationController.popViewController(animated: animated)
                }, showService: dependencyContainer.showService, creatorService: dependencyContainer.creatorService
            )
            publicCreatorViewModel.baseProfileAction.onSelectProducts = { [weak self] selectableShow in
                self?.showProductsDetail(selectableShow: selectableShow, animated: animated)
            }
            publicCreatorViewModel.baseProfileAction.onSelectFavoriteProduct = { [weak self] product in
                self?.showProductsDetail(selectableShow: SelectableShow(products: [product], selectedProductIndex: 0, creator: creator), animated: animated)
            }
            publicCreatorViewModel.baseProfileAction.onSelectCreatorProfile = { [weak self] creator in
                self?.showCreatorProfileView(creator, animated: animated)
            }
            publicCreatorViewModel.baseProfileAction.onSelectBrand = { [weak self] brand in
                self?.showBrandProfileView(brand, animated: animated)
            }
            
            let publicCreatorVC = PublicCreatorProfileViewController(
                viewModel: publicCreatorViewModel,
                showVideoStreamBuilder: showVideoStreamBuilder
            )
            
            
            navigationController.pushViewController(publicCreatorVC, animated: animated)
        case .readWrite:
            navigationController.popToRootViewController(animated: animated)
            tabBarController.selectedTab = .profile
        }
    }
    
    func configureProfileViewController(user: User?, animated: Bool) -> UIViewController {
        let profileVC: UIViewController
        
        if let user, user.role == .creator {
            let personalProfileVC = PersonalCreatorProfileViewController(
                dependencyContainer: dependencyContainer,
                showVideoStreamBuilder: showVideoStreamBuilder,
                creator: user,
                onCreateShow: { [unowned self] in
                    self.showCreateContent(animated: animated)
                }
            )
            personalProfileVC.viewModel.baseProfileAction.onSelectProducts = { [weak self] selectableShow in
                self?.showProductsDetail(selectableShow: selectableShow, animated: animated)
            }
            personalProfileVC.viewModel.baseProfileAction.onSelectFavoriteProduct = { [weak self] product in
                self?.showProductsDetail(selectableShow: SelectableShow(products: [product], selectedProductIndex: 0, creator: user), animated: animated)
            }
            personalProfileVC.viewModel.baseProfileAction.onSelectBrand = { [weak self] brand in
                self?.showBrandProfileView(brand, animated: animated)
            }
            profileVC = personalProfileVC
        } else {
            let shopperVC = ShopperProfileViewController(dependencyContainer: dependencyContainer)
            shopperVC.onSignIn.sink { [weak self] onboardingType in
                self?.showGuestOnboarding(onboardingType: onboardingType, signUpToken: nil, animated: animated)
            }.store(in: &cancellables)
            shopperVC.onApplyToSell.sink { [weak self] in
                self?.showCreatorOnboarding(signUpToken: nil, animated: animated)
            }.store(in: &cancellables)
            
            profileVC = shopperVC
        }
        
        return profileVC
    }
    
    func getCreatorProfileAccesLevel(_ creator: Creator) -> ProfileAccessLevel {
        guard let currentCreator = userRepository.currentUser else {
            return .readOnly
        }
        return currentCreator.id == creator.id ? .readWrite : .readOnly
    }
    
    //MARK: Show Detail
    func presentShowsDetailViewCarousel(_ selectedShow: Show, showsSectionClosedSubject: PassthroughSubject<String, Never>?, animated: Bool) {
        let showsDetailViewModel = ShowsDetailViewModel(selectedShowID: selectedShow.id, showsDataStore: showsDataStore, showVideoStreamBuilder: showVideoStreamBuilder)
        let showsDetailView = ShowsDetailView(viewModel: showsDetailViewModel, showDetailInteraction: { [weak self] action, show in
            self?.handleShowDetailAction(action, show: show, animated: animated)
            if case .close = action, let showID = show?.id {
                showsSectionClosedSubject?.send(showID)
            }
        })
        
        navigationController.pushViewController(BaseShowDetailViewController(rootView: showsDetailView), animated: animated)
    }
    
    //MARK: Show Detail
    func presentShowDetailView(_ show: Show, animated: Bool) {
        let showDetailView = showVideoStreamBuilder.createShowVideoStreamView(show, showPresentationType: .singleView, onShowDetailInteraction: { [weak self] action in
            switch action {
            case .close(_):
                self?.navigationController.popViewController(animated: animated)
            case .creatorSelected(let creator):
                self?.showCreatorProfileView(creator, animated: animated)
            case .productSelected(let selectableShow):
                self?.showProductsDetail(selectableShow: selectableShow, animated: animated)
            case .brandSelected(let brand):
                self?.showBrandProfileView(brand, animated: animated)
            case .shareLinkGenerated(let shareLinkVC):
                self?.navigationController.present(shareLinkVC, animated: animated)
            default: break
            }
        })
        
        navigationController.pushViewController(BaseShowDetailViewController(rootView: showDetailView), animated: animated)
    }
    
    func handleShowDetailAction(_ showActionType: ShowDetailInteractionType, show: Show?, animated: Bool) {
        switch showActionType {
        case .close(let shouldProcessShow):
            if shouldProcessShow, let show {
                showsDataStore.removeShow(id: show.id)
            }
            navigationController.popViewController(animated: animated)
        case .creatorSelected(let creator):
            showCreatorProfileView(creator, animated: animated)
        case .productSelected(let selectableShow):
            showProductsDetail(selectableShow: selectableShow, animated: animated)
        case .brandSelected(let brand):
            showBrandProfileView(brand, animated: animated)
        case .shareLinkGenerated(let shareLinkVC):
            navigationController.present(shareLinkVC, animated: animated)
        case .didUpdateShow(let updatedShow):
            showsDataStore.updatePublicShow(updatedShow)
        }
    }
    
    //MARK: Products Detail
    func showProductsDetail(selectableShow: SelectableShow, animated: Bool = true) {
        self.productsDetailCoordinator = ProductsDetailCoordinator(
            selectableShow: selectableShow,
            dependencyContainer: dependencyContainer,
            presentingNavigationController: self.navigationController,
            onFinishedInteraction: { [weak self] in
                self?.productsDetailCoordinator = nil
            }
        )
        trackProductClickedEvent(selectableShow: selectableShow)
        
        productsDetailCoordinator?.start(animated: animated)
    }
    
    //MARK: Approved Creator
    func showApprovedCreatorView(animated: Bool) {
        let approvedCreatorVC = ApprovedCreatorViewController { [weak self] in
            self?.navigationController.dismiss(animated: animated) {
                self?.tabBarController.selectedTab = .profile
            }
        }
        navigationController.present(approvedCreatorVC, animated: animated)
        analyticsService.trackActionEvent(.creator_registration_steps, properties: [.registration_step: RegistrationStepValue.creator_application_approved])
    }
    
    //MARK: Home - ShowsSection & DiscoverSection
    func setupHomeViewController() -> UIViewController {
        let showsViewModel = ShowsSectionViewModel(
            showsDataStore: showsDataStore, showSelectionHandler: showVideoStreamBuilder,
            showsSectionActionHandler: { [weak self] actionType in
                switch actionType {
                case .selectShow(let show, let showsSectionClosedSubject):
                    self?.presentShowsDetailViewCarousel(show, showsSectionClosedSubject: showsSectionClosedSubject, animated: true)
                case .selectCreator(let creator):
                    self?.showCreatorProfileView(creator)
                }
            }, currentUserPublisher: userRepository.currentUserSubject.eraseToAnyPublisher()
        )
        
        let discoverViewModel = DiscoverSectionViewModel(
            creatorService: dependencyContainer.creatorService,
            showService: dependencyContainer.showService,
            brandService: dependencyContainer.brandService,
            showSelectionHandler: showVideoStreamBuilder,
            didApplyToGoLive: dependencyContainer.userSession.didShowApplyToGoLive,
            discoverAction: { [weak self] action in
                switch action {
                case .applyToBecomeCreator:
                    self?.showCreatorOnboarding(signUpToken: nil, animated: true)
                case .selectTopCreators:
                    self?.showTopCreatorsView(animated: true)
                case .selectCreator(let creator):
                    self?.showCreatorProfileView(creator, animated: true)
                case .selectShow(let show):
                    self?.presentShowDetailView(show, animated: true)
                case .selectBrand(let brand):
                    self?.showBrandProfileView(brand, animated: true)
                case .selectTrendingShowSection(let section):
                    self?.showTrendingShowsView(discoverSection: section, animated: true)
                case .selectTopBrands:
                    self?.showTopBrandsView(animated: true)
                }
            })
        
        let homeViewModel = HomeViewModel(
            userRepository: dependencyContainer.userRepository,
            showsSectionViewModel: showsViewModel, discoverSectionViewModel: discoverViewModel,
            tabBarController: dependencyContainer.tabBarController?(),
            homeAction: { [weak self] action in
                switch action {
                case .selectCreator(let creator):
                    self?.showCreatorProfileView(creator, animated: true)
                case .shareDeeplink(let shareVC):
                    self?.navigationController.present(shareVC, animated: true)
                case .createContent:
                    self?.showCreateContent()
                case .selectProducts(let selectableShow):
                    self?.showProductsDetail(selectableShow: selectableShow)
                }
            }
        )
        
        return HomeViewController(homeViewModel: homeViewModel)
    }
    
    func showTopCreatorsView(animated: Bool) {
        let topCreatorsVM = TopCreatorsContainerViewModel(
            creatorService: dependencyContainer.creatorService,
            userRepository: dependencyContainer.userRepository,
            followService: dependencyContainer.followService,
            remoteNotificationsPermissionHandler: dependencyContainer.remoteNotificationsManager
        )
        let topCreatorsView = TopCreatorsContainerView(viewModel: topCreatorsVM, onBack: { [unowned self] in
            self.navigationController.popViewController(animated: animated)
        }, onSelectCreator: { [weak self] creator in
            self?.showCreatorProfileView(creator, animated: animated)
        })
        
        navigationController.pushHostingView(topCreatorsView, animated: animated)
    }
    
    func showTrendingShowsView(discoverSection: DiscoverSectionType, animated: Bool) {
        let trendingShowsVM = TrendingShowsContainerViewModel(
            discoverSection: discoverSection, showService: dependencyContainer.showService,
            showSelectionHandler: showVideoStreamBuilder, onSelectShow: { [weak self] selectedShow in
                self?.presentShowDetailView(selectedShow, animated: animated)
            }
        )
        let trendingShowsView = TrendingShowsContainerView(viewModel: trendingShowsVM, onBack: { [unowned self] in
            self.navigationController.popViewController(animated: animated)
        })
        
        navigationController.pushHostingView(trendingShowsView, animated: animated)
    }
    
    func showTopBrandsView(animated: Bool) {
        let topBrandsVM = TopBrandsContainerViewModel(brandService: dependencyContainer.brandService)
        let topCreatorsView = TopBrandsContainerView(viewModel: topBrandsVM, onBack: { [weak self] in
            self?.navigationController.popViewController(animated: animated)
        }, onSelectBrand: { [weak self] brand in
            self?.showBrandProfileView(brand, animated: animated)
        })
        navigationController.pushHostingView(topCreatorsView, animated: animated)
    }
    
    func showBrandProfileView(_ brand: Brand, animated: Bool) {
        let brandProfileVM = BrandProfileViewModel(
            brand: brand,
            brandService: dependencyContainer.brandService,
            creatorService: dependencyContainer.creatorService,
            showStreamBuilder: showVideoStreamBuilder,
            brandProfileActionHandler: { [weak self] action in
                switch action {
                case .back:
                    self?.navigationController.popViewController(animated: animated)
                case .selectProduct(let _):
                    break //TODO: - 
                }
            }, showDetailInteractionHandler: { _ in
                //TODO: interaction / ignore for now
            }
        )
        
        let brandProfileVC = BrandProfileViewController(viewModel: brandProfileVM)
        
        navigationController.pushViewController(brandProfileVC, animated: animated)
    }
}

private extension MainCoordinator {
    
    //MARK: - Deeplink
    func setupSignUpDeeplink() {
        deeplinkService.onSignUpWithToken
            .receive(on: DispatchQueue.main)
            .delay(for: .seconds(1) , scheduler: DispatchQueue.main)
            .sink { [weak self] signUpToken in
                guard self?.userSession.isValid == false else {
                    return
                }
                self?.tabBarController.selectedTab = .profile
                
                if let guestOnboardingCoordinator = self?.guestOnboardingCoordinator {
                    guestOnboardingCoordinator.continueWithSignUpToken(signUpToken)
                } else if let creatorOnboardingCoordinator = self?.creatorOnboardingCoordinator {
                    creatorOnboardingCoordinator.continueWithSignUpToken(signUpToken)
                } else {
                    self?.showGuestOnboarding(onboardingType: .register, signUpToken: signUpToken, animated: true)
                }
            }
            .store(in: &cancellables)
        
        deeplinkService.onOpenSharedShow
            .receive(on: DispatchQueue.main)
            .delay(for: .seconds(1) , scheduler: DispatchQueue.main)
            .sink { [weak self] sharedShowID in
                guard let self else { return }
                
                Task(priority: .userInitiated) {
                    do {
                        guard let sharedShow = try await self.showsDataStore.getExistingShowOrFetchIfNeeded(showID: sharedShowID) else {
                            return
                        }
                        
                        await MainActor.run {
                            self.tabBarController.selectedTab = .home
                            self.navigationController.popToRootViewController(animated: false)
                            self.presentShowDetailView(sharedShow, animated: true)
                        }
                    } catch {
                        ToastDisplay.showErrorToast(from: self.navigationController, error: error, animated: true)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Remote Notifications
    func setupRemoteNotifications() {
        let remoteInteractor = remoteNotificationsManager.remoteNotificationsInteractor
        
        remoteInteractor.newShowPublished
            .receive(on: DispatchQueue.main)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] show in
                self?.navigationController.popToRootViewController(animated: false)
                self?.tabBarController.selectedTab = .home
                self?.presentShowDetailView(show, animated: true)
            }
            .store(in: &cancellables)
        
        Publishers.MergeMany(remoteInteractor.creatorShowStatusChanged.map { _ in }.eraseToAnyPublisher(), remoteInteractor.creatorShouldOpenSetupRoom.map { _ in }.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigationController.popToRootViewController(animated: false)
                self?.tabBarController.selectedTab = .profile
            }
            .store(in: &cancellables)
    }
}

//MARK: Private functionalities
private extension MainCoordinator {
    
    func setupPublishers() {
        setupUserSessionChanges()
        setupContentPublishingNotification()
        setupSignUpDeeplink()
        setupRemoteNotifications()
    }
    
    func setupUserSessionChanges(animated: Bool = true) {
        userSession.currentUserRoleSubject
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] userRole in
                let currentUser = self.userRepository.currentUser
                if let currentUser {
                    self.analyticsService.identify(user: currentUser)
                }
                self.tabBarController.changeTabViewController(
                    self.configureProfileViewController(user: currentUser, animated: animated), for: .profile
                )
            }
            .store(in: &cancellables)
        
        userSession.onSessionClosed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigationController.popToRootViewController(animated: animated)
                self?.analyticsService.reset()
            }
            .store(in: &cancellables)
    }
    
    func setupContentPublishingNotification() {
        contentCreationService.showDidPublishSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tabBarController.selectedTab = .profile
            }
            .store(in: &cancellables)
    }
}

//MARK: - Analytics
private extension MainCoordinator {
    
    func trackProductClickedEvent(selectableShow: SelectableShow) {
        var properties = selectableShow.selectedProduct.baseAnalyticsProperties
        properties[.show_id] = selectableShow.showID
        properties[.creator_id] = selectableShow.creator.id
        properties[.creator_username] = selectableShow.creator.formattedUsername
        properties[.product_position] = selectableShow.selectedProductIndex + 1
        
        analyticsService.trackActionEvent(.product_clicked, properties: properties)
    }
}
