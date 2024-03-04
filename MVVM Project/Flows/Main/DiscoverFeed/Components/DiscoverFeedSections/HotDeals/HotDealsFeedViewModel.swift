//
//  HotDealsFeedViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.11.2023.
//

import Foundation
import Combine

class HotDealsFeedViewModel: ObservableObject {
    
    var products: [Product] {
        return dataStore.items
    }
    var isLoadingMore: Bool {
        return dataStore.loadingSourceType == .paged
    }
    private var cancellable: AnyCancellable?
    
    //MARK: - Services
    let dataProvider: DiscoverFeedSectionsDataProviderProtocol
    private let dataStore = PaginatedDataStore<Product>(pageSize: 12)
    
    init(dataProvider: DiscoverFeedSectionsDataProviderProtocol) {
        self.dataProvider = dataProvider
        cancellable = dataStore.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
        
        dataStore.onLoadPage { lastProduct in
            try await dataProvider.getHotDealsProducts(maxLength: 12, lastID: lastProduct?.id)
        }
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func loadContent() async throws {
        try await dataStore.loadInitialContent()
    }
    
    @MainActor func handleLoadMore(for product: Product?) async {
        try? await dataStore.loadMoreIfNeeded(product)
    }
}
