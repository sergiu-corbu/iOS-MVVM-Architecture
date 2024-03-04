//
//  DiscoverFeedSectionsViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2023.
//

import Foundation
import Combine
import SwiftUI
import UIKit

class DiscoverFeedSectionsViewModel: ObservableObject {
    
    //MARK: - Properties
    private(set) var showSections: [DiscoverShowsFeedType: [Show]]
    private(set) var productSections: [DiscoverProductsFeedType: [Product]]
    private(set) var topCreators: [Creator]?
    private(set) var topBrands: [Brand]?
    let currentUserPublisher: CurrentValueSubject<User?, Never>
    private var cancellable: AnyCancellable?
    
    //MARK: - Services
    let justDroppedProductsDataStore: JustDroppedProductsDataStore
    let hotDealsViewModel: HotDealsFeedViewModel
    let sectionsDataProvider: DiscoverFeedSectionsDataProviderProtocol
    
    //MARK: - Actions
    let actionHandler: DiscoverFeedActionsHandler
    var onErrorReceived: ((Error) -> Void)?
    
    init(sectionsDataProvider: DiscoverFeedSectionsDataProviderProtocol,
         justDroppedProductsDataStore: JustDroppedProductsDataStore,
         actionHandler: DiscoverFeedActionsHandler, currentUserPublisher: CurrentValueSubject<User?, Never>,
         onErrorReceived: ((Error) -> Void)? = nil) {
        
        self.sectionsDataProvider = sectionsDataProvider
        self.justDroppedProductsDataStore = justDroppedProductsDataStore
        self.actionHandler = actionHandler
        self.currentUserPublisher = currentUserPublisher
        self.onErrorReceived = onErrorReceived
        self.showSections = [.justHappened: [], .mostPopular: []]
        self.productSections = [.topDeals: [], .justDropped: [], .hotDeals: []]
        self.hotDealsViewModel = HotDealsFeedViewModel(dataProvider: sectionsDataProvider)
        
        setupJustDroppedProductsDataSource()
        loadAllContent()
    }
    
    //MARK: Content Loading
    @MainActor func loadTopCreatorsContent(maxLength: Int = 10) async {
        do {
            topCreators = try await sectionsDataProvider.getTopCreators(maxLength: maxLength)
        } catch {
            onErrorReceived?(error)
        }
    }
    
    @MainActor func loadTopBrandsContent(maxLength: Int = 6) async {
        do {
            topBrands = try await sectionsDataProvider.getTopBrands(maxLength: maxLength)
        } catch {
            onErrorReceived?(error)
        }
    }
    
    @MainActor
    func loadProductsSectionContent(for productSectionType: DiscoverProductsFeedType) async {
        do {
            let products: [Product]
            let maxLength = productsFeedPageSize(productSectionType)
            switch productSectionType {
            case .justDropped:
                products = computeJustDroppedProductsSection(from: justDroppedProductsDataStore.products)
            case .topDeals:
                products = try await sectionsDataProvider.getHotDealsProducts(maxLength: maxLength, fetchTopDealsOnly: true)
            case .hotDeals:
                try await hotDealsViewModel.loadContent()
                products = hotDealsViewModel.products
            }
            productSections[productSectionType] = products
        } catch {
            onErrorReceived?(error)
        }
    }
    
    @MainActor func loadShowsSectionContent(
        for showSectionType: DiscoverShowsFeedType,
        maxLength: Int = 10
    ) async {
        do {
            showSections[showSectionType] = try await sectionsDataProvider.getPublicShows(
                sectionType: showSectionType, 
                maxLength: maxLength
            )
        } catch {
            onErrorReceived?(error)
        }
    }
    
    final func loadAllContent() {
        Task(priority: .userInitiated) { @MainActor [weak self] in
            await withTaskGroup(of: Void.self) { taskGroup in
                guard let self else { return }
                taskGroup.addTask {
                    await self.loadTopBrandsContent()
                }
                taskGroup.addTask {
                    await self.loadTopCreatorsContent()
                }
                for productSectionType in DiscoverProductsFeedType.allCases {
                    taskGroup.addTask {
                        await self.loadProductsSectionContent(for: productSectionType)
                    }
                }
                for showSectionType in DiscoverShowsFeedType.allCases {
                    taskGroup.addTask {
                        await self.loadShowsSectionContent(for: showSectionType)
                    }
                }
                await taskGroup.waitForAll()
            }
            self?.objectWillChange.send()
        }
    }
    
    //MARK: - Helpers
    private func setupJustDroppedProductsDataSource() {
        cancellable = justDroppedProductsDataStore.productsWillChangePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                if self?.productSections[.justDropped]?.isEmpty == true {
                    self?.productSections[.justDropped] = self?.computeJustDroppedProductsSection(from: products)
                    self?.objectWillChange.send()
                }
            }
    }
    
    private func computeJustDroppedProductsSection(from products: [Product]) -> [Product] {
        Array(products.prefix(upTo: min(products.count, productsFeedPageSize(.justDropped))))
    }
    
    private func productsFeedPageSize(_ feedType: DiscoverProductsFeedType) -> Int {
        switch feedType {
        case .justDropped: 9
        case .topDeals: 6
        case .hotDeals: 12
        }
    }
    
    func brandsFlowLayout(availableSize: CGSize, spacing: CGFloat) -> UICollectionViewLayout {
        let availableWidth = availableSize.width - (2 * spacing) - (spacing / 2)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: availableWidth / 2, height: 72)
        layout.minimumInteritemSpacing = spacing / 2
        layout.minimumLineSpacing = spacing / 2
        
        return layout
    }
}

struct ShowsFeedDiscoverSection: Equatable {
    let shows: [Show]
    let selectedShowID: String
    let feedType: DiscoverShowsFeedType
}

#if DEBUG
extension DiscoverFeedSectionsViewModel {
    static let preview = DiscoverFeedSectionsViewModel(
        sectionsDataProvider: MockDiscoverFeedSectionsDataProvider(),
        justDroppedProductsDataStore: PreviewJustDroppedProductsDataStore(),
        actionHandler: .previewActions, currentUserPublisher: .init(nil)
    )
}
#endif
/* NOTE: live shows are not handled at this point. business decision
 func handleShowSelection(_ show: Show, section: DiscoverSectionType) {
 guard case .upcoming = section else {
 discoverAction(.selectShow(show, getDiscoverSection(for: section)))
 return
 }
 
 Task(priority: .userInitiated) { @MainActor in
 do {
 discoverAction(.selectShow(try await showSelectionHandler?.handleShowSelection(show) ?? show, getDiscoverSection(for: section)))
 } catch {
 onErrorReceived?(error)
 }
 }
 }*/
