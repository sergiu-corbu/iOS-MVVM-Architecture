//
//  JustDroppedProductsDataStore.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.12.2023.
//

import Foundation
import Combine

class JustDroppedProductsDataStore: ObservableObject {
    
    //MARK: - Getters
    var products: [Product] {
        return dataStore.items.map(\.product)
    }
    var loadingType: LoadingSourceType? {
        return dataStore.loadingSourceType
    }
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Publishers
    let productsWillChangePublisher = PassthroughSubject<[Product], Never>()
    
    //MARK: - Services
    private let dataStore: PaginatedDataStore<ProductWrapper>
    private let productService: ProductServiceProtocol
    
    init(pageSize: Int = 14, productService: ProductServiceProtocol) {
        self.dataStore = PaginatedDataStore(pageSize: pageSize)
        self.productService = productService
        setup()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    private func setup() {
        dataStore.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
        dataStore.onLoadPage { [weak self] lastProduct in
            guard let self else { return [] }
            var products = try await self.productService.getJustDroppedProducts(
                pageSize: self.dataStore.pageSize, lastID: lastProduct?.id,
                lastProductPublishDate: lastProduct?.publishDate
            )
            await products.prefetchImagesMetadata()
            productsWillChangePublisher.send(products.map(\.product))
            return products
        }
    }
    
    @MainActor func loadContent() async throws {
        try await dataStore.loadInitialContent()
    }
    
    @MainActor func refreshContent() async throws {
        try await dataStore.refreshContent()
    }
    
    @MainActor func loadMoreIfNeeded(_ lastItem: ProductWrapper? = nil) async throws { //Nil as we do not use ProductWrapper in the UI
        try await dataStore.loadMoreIfNeeded(lastItem ?? dataStore.items.last)
    }
}

#if DEBUG
class PreviewJustDroppedProductsDataStore: JustDroppedProductsDataStore {
    init() {
        super.init(productService: MockProductService())
    }
}
#endif
