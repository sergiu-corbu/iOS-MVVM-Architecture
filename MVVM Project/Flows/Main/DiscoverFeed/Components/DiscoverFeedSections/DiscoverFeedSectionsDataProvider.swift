//
//  DiscoverFeedSectionsDataProvider.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.11.2023.
//

import Foundation

protocol DiscoverFeedSectionsDataProviderProtocol {
    func getTopBrands(maxLength: Int, lastID: String?, lastPriority: Int?) async throws -> [Brand]
    func getTopCreators(maxLength: Int, lastID: String?, lastViewsPriority: Int?) async throws -> [Creator]
    func getPublicShows(sectionType: DiscoverShowsFeedType, maxLength: Int) async throws -> [Show]
    func getJustDroppedProducts(maxLength: Int, lastID: String?, lastPublishDate: Date?) async throws -> [ProductWrapper]
    func getHotDealsProducts(maxLength: Int, fetchTopDealsOnly: Bool?, lastID: String?) async throws -> [Product]
}

extension DiscoverFeedSectionsDataProviderProtocol {
    func getTopBrands(maxLength: Int, lastID: String? = nil, lastPriority: Int? = nil) async throws -> [Brand] {
        try await getTopBrands(maxLength: maxLength, lastID: lastID, lastPriority: lastPriority)
    }
    func getTopCreators(maxLength: Int, lastID: String? = nil, lastViewsPriority: Int? = nil) async throws -> [Creator] {
        try await self.getTopCreators(maxLength: maxLength, lastID: lastID, lastViewsPriority: lastViewsPriority)
    }
    func getJustDroppedProducts(maxLength: Int, lastID: String? = nil, lastPublishDate: Date? = nil) async throws -> [ProductWrapper] {
        try await self.getJustDroppedProducts(maxLength: maxLength, lastID: lastID, lastPublishDate: lastPublishDate)
    }
    func getHotDealsProducts(maxLength: Int, fetchTopDealsOnly: Bool? = nil, lastID: String? = nil) async throws -> [Product] {
        try await self.getHotDealsProducts(maxLength: maxLength, fetchTopDealsOnly: fetchTopDealsOnly, lastID: lastID)
    }
}

class DiscoverFeedSectionsDataProvider: DiscoverFeedSectionsDataProviderProtocol {
    
    private let creatorService: CreatorServiceProtocol
    private let brandService: BrandServiceProtocol
    private let showRepository: ShowRepositoryProtocol
    private let productService: ProductServiceProtocol
    
    init(creatorService: CreatorServiceProtocol, brandService: BrandServiceProtocol,
         showRepository: ShowRepositoryProtocol, productService: ProductServiceProtocol) {
        self.creatorService = creatorService
        self.brandService = brandService
        self.showRepository = showRepository
        self.productService = productService
    }
    
    func getTopBrands(maxLength: Int, lastID: String?, lastPriority: Int?) async throws -> [Brand] {
        try await brandService.getBrands(pageSize: maxLength, lastID: lastID, lastPriority: lastPriority)
    }
    
    func getTopCreators(maxLength: Int, lastID: String?, lastViewsPriority: Int?) async throws -> [Creator] {
        try await creatorService.getTopCreators(pageSize: maxLength, lastId: lastID, lastViewsValue: lastViewsPriority)
    }
    
    func getPublicShows(sectionType: DiscoverShowsFeedType, maxLength: Int) async throws -> [Show] {
        try await showRepository.getPublicShows(pageSize: maxLength, discoverSectionType: sectionType)
    }
    
    func getJustDroppedProducts(maxLength: Int, lastID: String?, lastPublishDate: Date?) async throws -> [ProductWrapper] {
        var products = try await productService.getJustDroppedProducts(
            pageSize: maxLength, lastID: lastID, lastProductPublishDate: lastPublishDate
        )
        return await products.prefetchImagesMetadata()
    }
    
    func getHotDealsProducts(maxLength: Int, fetchTopDealsOnly: Bool?, lastID: String?) async throws -> [Product] {
        var products = try await productService.getHotDealsProducts(
            maxLength: maxLength, fetchTopDealsOnly: fetchTopDealsOnly, lastID: lastID
        )
        return await products.prefetchImagesMetadata()
    }
}

#if DEBUG
struct MockDiscoverFeedSectionsDataProvider: DiscoverFeedSectionsDataProviderProtocol {
    func getTopBrands(maxLength: Int, lastID: String?, lastPriority: Int?) async throws -> [Brand] {
        await Task.debugSleep()
        return Array(Brand.allBrands.prefix(6))
    }
    
    func getTopCreators(maxLength: Int, lastID: String?, lastViewsPriority: Int?) async throws -> [Creator] {
        await Task.debugSleep()
        return User.mockUsers
    }
    
    func getPublicShows(sectionType: DiscoverShowsFeedType, maxLength: Int) async throws -> [Show] {
        await Task.debugSleep()
        return Show.allShows
    }
    
    func getJustDroppedProducts(maxLength: Int, lastID: String?, lastPublishDate: Date?) async throws -> [ProductWrapper] {
        await Task.debugSleep()
        return Product.all.map { ProductWrapper(id: UUID().uuidString, publishDate: .now, product: $0) }
    }
    
    func getHotDealsProducts(maxLength: Int, fetchTopDealsOnly: Bool?, lastID: String?) async throws -> [Product] {
        await Task.debugSleep()
        return Product.all
    }
}
#endif
