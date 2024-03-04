//
//  DiscoverFeedCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.11.2023.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class DiscoverFeedCoordinator: MainFlowCoordinator {
    
    //MARK: - Properties
    private var discoverFeedViewModel: DiscoverFeedViewModel!
    
    //MARK: - Services
    lazy var discoverSectionsDataProvider: DiscoverFeedSectionsDataProviderProtocol = {
        DiscoverFeedSectionsDataProvider(
            creatorService: dependencyContainer.creatorService,
            brandService: dependencyContainer.brandService,
            showRepository: dependencyContainer.showRepository,
            productService: dependencyContainer.productService
        )
    }()
    
    func start() {
        setupDiscoverFeedController()
        setupDeeplinkBindings()
        setupRemoteNotificationsBindings()
    }
    
    //MARK: - Setup
    private func setupDiscoverFeedController() {
        let discoverFeedActionHandler = createDiscoverFeedActionsHandler()
        let promotionalBannerViewModel = PromotionalBannerViewModel(
            promotionalBannerContentProvider: dependencyContainer.promotionalBannerContentProvider,
            actionHander: { [weak self] action in
                switch action {
                case .selectCreator(let creator):
                    self?.showCreatorProfileView(creator, navigationSource: .promotionalBanner)
                case .selectBrand(let brand):
                    self?.brandProfileCoordinator.showBrandProfileView(brand, navigationSource: .promotionalBanner, animated: true)
                case .selectPromotedProducts(bannerID: let bannerID, products: let products, title: let title):
                    self?.showPromotedProductsView(bannerID: bannerID, products: products, title: title, animated: true)
                }
            }
        )
        
        let discoverFeedSectionsVM = DiscoverFeedSectionsViewModel(
            sectionsDataProvider: discoverSectionsDataProvider,
            justDroppedProductsDataStore: dependencyContainer.justDroppedProductsDataStore,
            actionHandler: discoverFeedActionHandler,
            currentUserPublisher: userRepository.currentUserSubject
        )
        
        self.discoverFeedViewModel = DiscoverFeedViewModel(
            checkoutCartManager: dependencyContainer.checkoutCartManager,
            featuredShowsViewModel: featuredShowsViewModel,
            discoverFeedSectionsViewModel: discoverFeedSectionsVM,
            promotionalBannerViewModel: promotionalBannerViewModel,
            currentUserPublisher: userRepository.currentUserSubject,
            actionsHandler: discoverFeedActionHandler
        )
        
        navigationController.setViewControllers([DiscoverFeedViewController(viewModel: discoverFeedViewModel)], animated: false)
    }
    
    //MARK: - Actions Handler
    private func createDiscoverFeedActionsHandler() -> DiscoverFeedActionsHandler {
        DiscoverFeedActionsHandler(onPresentCart: { [weak self] in
            self?.checkoutCoordinator.start(animated: true)
        }, onSelectProduct: { [weak self] product in
            self?.showProductsDetail(productSelectable: ProductSelectableDTO(product: product))
        }, onSelectBrand: { [weak self] brand in
            self?.brandProfileCoordinator.showBrandProfileView(brand, navigationSource: .discoverFeed, animated: true)
        }, onSelectCreator: { [weak self] creator in
            self?.showCreatorProfileView(creator, navigationSource: .discoverFeed)
        }, onSelectShow: { [weak self] showsSection in
            self?.presentShowsDetailViewCarousel(showID: showsSection.selectedShowID, showsDataStore: StaticShowsDataStore(shows: showsSection.shows))
        }, onSelectExpandedSectionContent: { [weak self] sectionType in
            let pageSize = 20
            switch sectionType {
            case .brands:
                self?.showDiscoverFeedSectionDetail(sectionType: sectionType, dataStore: PaginatedDataStore<BrandWrapper>(pageSize: pageSize))
            case .creators:
                self?.showDiscoverFeedSectionDetail(sectionType: sectionType, dataStore: PaginatedDataStore<Creator>(pageSize: pageSize))
            case .products(_):
                self?.showDiscoverFeedSectionDetail(sectionType: sectionType, dataStore: PaginatedDataStore<ProductWrapper>(pageSize: pageSize))
            case .shows(_):
                self?.showDiscoverFeedSectionDetail(sectionType: sectionType, dataStore: PaginatedDataStore<Show>(pageSize: pageSize * 2))
            }
        }, onCreateContent: { [weak self] in
            self?.showCreateContent()
        }, onApplyAsCreator: { [weak self] in
            self?.showCreatorOnboarding(signUpToken: nil, animated: true)
        })
    }
    
    //MARK: - Featured Shows
    private lazy var featuredShowsViewModel: FeaturedShowsViewModel<PaginatedShowsDataStore> = {
        let actionHandler = FeaturedShowsActionHandler(onSelectShow: { [weak self] (show, closePublisher) in
            guard let self else { return }
            self.presentShowsDetailViewCarousel(
                showID: show.id,
                showsDataStore: self.featuredShowsDataStore,
                showsSectionClosedSubject: closePublisher
            )
        }, onSelectCreator: { [weak self] creator in
            self?.showCreatorProfileView(creator, navigationSource: .featuredFeed)
        }, onSelectBrand: { [weak self] brand in
            self?.brandProfileCoordinator.showBrandProfileView(brand, navigationSource: .featuredFeed)
        }, onSelectProduct: { [weak self] productSelectable in
            self?.showProductsDetail(productSelectable: productSelectable)
        })
        
        return FeaturedShowsViewModel(
            showsDataStore: featuredShowsDataStore,
            actionHandler: actionHandler,
            currentUserPublisher: userRepository.currentUserSubject.eraseToAnyPublisher()
        )
    }()
    
    func showDiscoverFeedSectionDetail<Item>(
        sectionType: ExpandedSectionContentType,
        dataStore: PaginatedDataStore<Item>,
        animated: Bool = true
    ) where Item: StringIdentifiable & Equatable {
        
        let actionHandler = DiscoverFeedDetailActionHandler(onBack: { [weak self] in
            self?.navigationController.popViewController(animated: animated)
        }, onSelectItem: { [weak self] item in
            switch sectionType {
            case .shows(_):
                if let show = item as? Show {
                    self?.presentShowsDetailViewCarousel(
                        showID: show.id,
                        showsDataStore: StaticShowsDataStore(shows: dataStore.items as? [Show] ?? [])
                    )
                }
            case .products(_):
                if let product = item as? Product {
                    self?.showProductsDetail(productSelectable: ProductSelectableDTO(product: product))
                }
            case .creators:
                if let creator = item as? Creator {
                    self?.showCreatorProfileView(creator, navigationSource: .topCreators, animated: animated)
                }
            case .brands:
                if let brand = (item as? BrandWrapper)?.value {
                    self?.brandProfileCoordinator.showBrandProfileView(brand, navigationSource: .topBrands, animated: animated)
                }
            }
        }, onRequestAuthentication: { [weak self] completion in
            self?.showShopperOnboarding(
                registrationContext: RegistrationContext(source: .follow),
                startModally: true, completionHandler: completion,
                animated: animated
            )
        })
        let feedDetailViewModel = DiscoverFeedSectionDetailViewModel<Item>(
            sectionType: sectionType, sectionsDataProvider: discoverSectionsDataProvider, dataStore: dataStore,
            userRepository: userRepository, followService: dependencyContainer.followService,
            pushNotificationsPermissionHandler: pushNotificationsManager,
            actionHandler: actionHandler
        )
        
        let feedDetailViewController = UIHostingController(rootView: DiscoverFeedSectionDetailView(viewModel: feedDetailViewModel))
        feedDetailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(feedDetailViewController, animated: animated)
    }
    
    //MARK: - ShowsDetailViewCarousel
    func presentShowsDetailViewCarousel<ShowsDataStore: ShowsDataStoreProtocol>(
        showID: String,
        showsDataStore: ShowsDataStore,
        showsSectionClosedSubject: PassthroughSubject<Show, Never>? = nil,
        animated: Bool = true
    ) {
        let showsDetailViewModel = ShowsDetailViewModel(
            selectedShowID: showID,
            showsDataStore: showsDataStore,
            showVideoStreamBuilder: showStreamBuilder
        )
        let showsDetailView = ShowsDetailView(
            viewModel: showsDetailViewModel,
            showDetailInteraction: { [weak self] action, show in
                self?.handleShowDetailAction(action, show: show, animated: animated)
                if case .close = action, let show {
                    showsSectionClosedSubject?.send(show)
                }
            }
        )
        
        let showsDetailViewController = BaseShowDetailViewController(rootView: showsDetailView)
        showsDetailViewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(showsDetailViewController, animated: animated)
    }
    
    //MARK: - Promoted Products
    func showPromotedProductsView(bannerID: String, products: [Product], title: String, animated: Bool) {
        let shareableProvider = ShareableProvider(deeplinkProvider: deeplinkService, onPresentShareLink: { [weak self] shareLinkVC in
            self?.navigationController.present(shareLinkVC, animated: animated)
        })
        let promotedProductsViewModel = PromotedProductListViewModel(bannerID: bannerID, products: products, shareableProvider: shareableProvider, onSelectProduct: { [weak self] product in
            self?.showProductsDetail(productSelectable: ProductSelectableDTO(product: product), animated: animated)
        }, onBack: { [weak self] in
            self?.navigationController.popViewController(animated: animated)
        })
        
        let promotedProductsVC = UIHostingController(rootView: PromotedProductListView(title: title, viewModel: promotedProductsViewModel))
        promotedProductsVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(promotedProductsVC, animated: animated)
    }
}

private extension DiscoverFeedCoordinator {
    
    func setupDeeplinkBindings() {
        deeplinkService.onOpenSharedShow.receive(on: DispatchQueue.main)
            .delay(for: .seconds(1) , scheduler: DispatchQueue.main)
            .sink { sharedShowID in
                Task(priority: .userInitiated) { @MainActor [weak self] in
                    do {
                        guard let sharedShow = try await self?.featuredShowsDataStore.getExistingShowOrFetchIfNeeded(showID: sharedShowID) else {
                            return
                        }
                        self?.popToRoot()
                        self?.presentShowDetailView(sharedShow, animated: true)
                    } catch {
                        ToastDisplay.showErrorToast(from: self?.navigationController, error: error, animated: true)
                    }
                }
            }
            .store(in: &cancellables)
        
        deeplinkService.onOpenGiftRequest.receive(on: DispatchQueue.main)
            .delay(for: .seconds(0.5) , scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.popToRoot()
                self?.showCreateContent(startFromGiftRequest: true)
            }
            .store(in: &cancellables)
        deeplinkService.onOpenPromotedProducts
            .receive(on: DispatchQueue.main)
            .delay(for: .seconds(0.5) , scheduler: DispatchQueue.main)
            .sink { [weak self] sharedBannerID in
                self?.popToRoot()
                self?.navigationController.dismissPresentedViewControllerIfNeeded(animated: false)
                self?.discoverFeedViewModel.promotionalBannerViewModel.handleSharedProductList(bannerID: sharedBannerID)
            }
            .store(in: &cancellables)
    }
}

private extension DiscoverFeedCoordinator {
    
    func setupRemoteNotificationsBindings() {
        pushNotificationsManager.pushNotificationsInteractor.newShowPublished
            .receive(on: DispatchQueue.main)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] show in
                self?.popToRoot()
                self?.presentShowDetailView(show, animated: true)
            }
            .store(in: &cancellables)
    }
    
    func popToRoot(animated: Bool = false) {
        navigationController.popToRootViewController(animated: animated)
        tabBarController?.selectedTab = .discover
    }
}
