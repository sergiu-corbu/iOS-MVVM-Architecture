//
//  BrandProfileCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.05.2023.
//

import Foundation
import UIKit

typealias BrandProfileAction = BrandProfileCoordinator.Action

class BrandProfileCoordinator {
    
    //MARK: - Properties
    private weak var navigationController: UINavigationController?
    private var ongoingTasks = [Task<Void, Never>]()
    private(set) var currentPresentedBrand: Brand?
    private let tabBarController: TabBarController?
    
    //MARK: - Actions
    enum Action {
        case back
        case selectProduct(Product)
        case requestSignIn(() -> Void)
        case shareLink(ShareLinkActivityViewController)
    }
    let showDetailInteractionHandler: ShowDetailInteraction
    let brandProfileActionHandler: (Action) -> Void
    
    //MARK: - Services
    private let dependencyContainer: DependencyContainer
    let brandService: BrandServiceProtocol
    let productService: ProductServiceProtocol
    let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    init(navigationController: UINavigationController, dependencyContainer: DependencyContainer,
         showDetailInteractionHandler: @escaping ShowDetailInteraction, brandProfileActionHandler: @escaping (Action) -> Void) {
        
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        self.brandService = dependencyContainer.brandService
        self.productService = dependencyContainer.productService
        self.showDetailInteractionHandler = showDetailInteractionHandler
        self.brandProfileActionHandler = brandProfileActionHandler
        self.tabBarController = dependencyContainer.tabBarController?()
    }
    
    func showBrandProfileView(
        _ brand: Brand, navigationSource: ProfileNavigationSource?,
        preselectedSection: ProfileSectionType = .products,
        animated: Bool = true, completion: (() -> Void)? = nil
    ) {
        
        let brandProfileVM = BrandProfileViewModel(
            brand: brand,
            preselectedSection: preselectedSection,
            brandService: brandService,
            deeplinkProvider: dependencyContainer.deeplinkService,
            showStreamBuilder: dependencyContainer.showVideoStreamBuilder,
            brandProfileActionHandler: { [weak self] action in
                self?.brandProfileActionHandler(action)
            },
            showDetailInteractionHandler: { [weak self] action in
                self?.showDetailInteractionHandler(action)
            },
            showSelectionHandler: { [weak self] showArray, selectedShow in
                self?.goToShowCarousel(shows: showArray, selectedShow: selectedShow)
            }
        )
        currentPresentedBrand = brand
        
        let brandProfileVC = BrandProfileViewController(viewModel: brandProfileVM)
        brandProfileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(brandProfileVC, animated: animated, completion: completion)
        
        trackBrandProfileScreen(brand, navigationSource: navigationSource)
    }
    
    private func prepareAndShowBrandProfileView(
        _ brand: Brand,
        preselectedSection: ProfileSectionType = .about,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        tabBarController?.selectedTab = .profile
        navigationController?.dismissPresentedViewControllerIfNeeded(animated: false)
        showBrandProfileView(brand, navigationSource: .sharedLink, preselectedSection: preselectedSection, animated: animated, completion: completion)
    }
    
    func showBrandProfileView(id brandID: String, animated: Bool) {
        cancelOngoingTasks()
        
        ongoingTasks.append(
            Task(priority: .userInitiated) { @MainActor [weak self] in
                do {
                    guard let brand = try await self?.brandService.getBrand(id: brandID), !Task.isCancelled else {
                        return
                    }
                    self?.prepareAndShowBrandProfileView(brand, animated: animated)
                } catch {
                    ToastDisplay.showErrorToast(from: self?.navigationController, error: error, animated: animated)
                }
            }
        )
    }
    
    func showProductFromBrandProfileView(productID: String, animated: Bool) {
        cancelOngoingTasks()
        
        ongoingTasks.append(
            Task(priority: .userInitiated) { @MainActor [weak self] in
                do {
                    guard let product = try await self?.productService.getProductWith(id: productID), !Task.isCancelled else {
                        return
                    }
                    self?.prepareAndShowBrandProfileView(product.brand, preselectedSection: .products, animated: animated, completion: {
                        self?.brandProfileActionHandler(.selectProduct(product))
                    })
                } catch {
                    ToastDisplay.showErrorToast(from: self?.navigationController, error: error, animated: animated)
                }
            }
        )
    }
    
    private func goToShowCarousel(shows: [Show], selectedShow: Show) {
        let showsDetailViewModel = ShowsDetailViewModel(
            selectedShowID: selectedShow.id,
            showsDataStore: PaginatedShowsDataStore(showService: dependencyContainer.showRepository, shows: shows),
            showVideoStreamBuilder: dependencyContainer.showVideoStreamBuilder
        )
        let showsDetailView = ShowsDetailView(viewModel: showsDetailViewModel, showDetailInteraction: { [weak self] action, _ in
            self?.showDetailInteractionHandler(action)
        })
        navigationController?.pushViewController(BaseShowDetailViewController(rootView: showsDetailView), animated: true)
        
        var properties = currentPresentedBrand?.baseAnalyticsProperties
        properties?[.show_id] = selectedShow.id
        properties?[.show_name] = selectedShow.title
        properties?[.show_type] = selectedShow.type.rawValue
        analyticsService.trackActionEvent(.select_brand_collaboration, properties: properties)
    }
    
    private func cancelOngoingTasks() {
        ongoingTasks.forEach({$0.cancel()})
        ongoingTasks.removeAll(keepingCapacity: true)
    }
}

//MARK: - Analytics
extension BrandProfileCoordinator {
    
    func trackBrandProfileScreen(_ brand: Brand, navigationSource: ProfileNavigationSource?) {
        var properties = brand.baseAnalyticsProperties
        properties[.source] = navigationSource?.rawValue.capitalized
        analyticsService.trackScreenEvent(.brand_profile, properties: properties)
    }
}
