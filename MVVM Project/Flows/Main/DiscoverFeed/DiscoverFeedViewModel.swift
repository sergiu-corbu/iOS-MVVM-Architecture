//
//  DiscoverFeedViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.11.2023.
//

import Foundation
import Combine
import UIKit

class DiscoverFeedViewModel: ObservableObject {
    
    //MARK: - ViewModels Composition
    let featuredShowsViewModel: FeaturedShowsViewModel<PaginatedShowsDataStore>
    let discoverFeedSectionsViewModel: DiscoverFeedSectionsViewModel
    let promotionalBannerViewModel: PromotionalBannerViewModel
    
    //MARK: Actions Handler
    let actionsHandler: DiscoverFeedActionsHandler
    var onReceiveError: ((Error?) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: Services
    let currentUserPublisher: CurrentValueSubject<User?, Never>
    let checkoutCartManager: CheckoutCartManager
    let analyticsService: AnalyticsServiceProtocol
    
    init(checkoutCartManager: CheckoutCartManager, analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
         featuredShowsViewModel: FeaturedShowsViewModel<PaginatedShowsDataStore>,
         discoverFeedSectionsViewModel: DiscoverFeedSectionsViewModel, promotionalBannerViewModel: PromotionalBannerViewModel,
         currentUserPublisher: CurrentValueSubject<User?, Never>, actionsHandler: DiscoverFeedActionsHandler
    ) {
        
        self.checkoutCartManager = checkoutCartManager
        self.analyticsService = analyticsService
        self.currentUserPublisher = currentUserPublisher
        self.actionsHandler = actionsHandler
        self.featuredShowsViewModel = featuredShowsViewModel
        self.discoverFeedSectionsViewModel = discoverFeedSectionsViewModel
        self.promotionalBannerViewModel = promotionalBannerViewModel
        
        let errorClosure: (Error) -> Void = { [weak self] error in
            self?.onReceiveError?(error)
        }
        discoverFeedSectionsViewModel.onErrorReceived = errorClosure
        featuredShowsViewModel.onErrorReceived = errorClosure
        
        self.setupAppLifecycleEvents()
    }
    
    //MARK: - View Lifecycle
    func onViewAppeared() {
        analyticsService.trackScreenEvent(.discovery, properties: nil)
    }
    
    //MARK: - App Lifecycle
    private func setupAppLifecycleEvents() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.reloadAllContent()
            }
            .store(in: &cancellables)
    }
    
    func reloadAllContent() {
        featuredShowsViewModel.reloadContent()
        promotionalBannerViewModel.getPromotionalBanners()
        discoverFeedSectionsViewModel.loadAllContent()
    }
}

#if DEBUG
extension DiscoverFeedViewModel {
    
    static let mocked = DiscoverFeedViewModel(
        checkoutCartManager: CheckoutCartManager.mocked,
        featuredShowsViewModel: FeaturedShowsView.mockedViewModel,
        discoverFeedSectionsViewModel: .preview, promotionalBannerViewModel: .mocked,
        currentUserPublisher: .init(.creator), actionsHandler: .previewActions
    )
}
#endif
