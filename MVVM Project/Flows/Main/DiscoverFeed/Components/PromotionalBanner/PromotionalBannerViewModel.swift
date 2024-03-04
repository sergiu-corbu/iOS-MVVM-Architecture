//
//  PromotionalBannerViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 11.10.2023.
//

import Foundation

class PromotionalBannerViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var promotionalBanners = [PromotionalBanner]()
    @Published var loadingBannerTaskType: PromotionalBannerType?
    private var loadingBannerTask: VoidTask?
    
    //MARK: - Services
    private let promotionalBannerContentProvider: PromotionalBannerContentProviderProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    //MARK: - Actions
    let actionHandler: (Action) -> Void
    enum Action {
        case selectCreator(Creator)
        case selectBrand(Brand)
        case selectPromotedProducts(bannerID: String, products: [Product], title: String)
    }
    
    init(promotionalBannerContentProvider: PromotionalBannerContentProviderProtocol,
         analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
         actionHander: @escaping (Action) -> Void) {
        
        self.promotionalBannerContentProvider = promotionalBannerContentProvider
        self.analyticsService = analyticsService
        self.actionHandler = actionHander
        self.getPromotionalBanners()
    }
    
    deinit {
        loadingBannerTask?.cancel()
    }
    
    func getPromotionalBanners() {
        Task(priority: .userInitiated) { @MainActor [weak self] in
            do {
                self?.promotionalBanners = try await self?.promotionalBannerContentProvider.getPromotionalBanners() ?? []
            } catch {
                ToastDisplay.showErrorToast(error: error)
            }
        }
    }
    
    //MARK: - Actions
    func handlePromotionalBannerSelection(for banner: PromotionalBanner) {
        if loadingBannerTaskType == banner.type {
            return
        }
        loadingBannerTask?.cancel()
        loadingBannerTask = Task(priority: .userInitiated) { @MainActor [weak self] in
            self?.loadingBannerTaskType = banner.type
            do {
                switch banner.type {
                case .brandProfile:
                    if let brandID = banner.brandID,
                        let brand = try await self?.promotionalBannerContentProvider.getPromotedBrand(id: brandID) {
                        self?.actionHandler(.selectBrand(brand))
                    }
                case .creatorProfile:
                    if let creatorID = banner.creatorID,
                        let creator = try await self?.promotionalBannerContentProvider.getPromotedCreator(id: creatorID) {
                        self?.actionHandler(.selectCreator(creator))
                    }
                case .productList:
                    if var products = try await self?.promotionalBannerContentProvider.getPromotionalBanner(id: banner.id)?.products {
                        await products.prefetchImagesMetadata()
                        self?.actionHandler(.selectPromotedProducts(bannerID: banner.id, products: products, title: banner.title))
                    }
                }
                self?.trackPromotionalBannerActionEvent(banner)
            } catch {
                ToastDisplay.showErrorToast(error: error)
            }
            self?.loadingBannerTaskType = nil
        }
    }
    
    func handleSharedProductList(bannerID: String) {
        Task(priority: .userInitiated) { @MainActor [weak self] in
            do {
                if let banner = try await self?.promotionalBannerContentProvider.getPromotionalBanner(id: bannerID),
                   var products = banner.products {
                    await products.prefetchImagesMetadata()
                    self?.actionHandler(.selectPromotedProducts(bannerID: bannerID, products: products, title: banner.title))
                }
            } catch {
                ToastDisplay.showErrorToast(error: error)
            }
        }
    }
    
    private func trackPromotionalBannerActionEvent(_ banner: PromotionalBanner) {
        var properties = AnalyticsProperties()
        properties[.promotional_banner_type] = banner.type.rawValue
        properties[.promotional_banner_title] = banner.title
        
        analyticsService.trackActionEvent(.select_promo_banner, properties: properties)
    }
}

#if DEBUG
extension PromotionalBannerViewModel {
    
    static let mocked = PromotionalBannerViewModel(
        promotionalBannerContentProvider: MockPromotionalBannerContentProvider(),
        analyticsService: MockAnalyticsService(),
        actionHander: { _ in}
    )
    
    static let mockedEmpty = PromotionalBannerViewModel(
        promotionalBannerContentProvider: MockEmptyPromotionalBannerContentProvider(),
        analyticsService: MockAnalyticsService(),
        actionHander: { _ in}
    )
}
#endif
