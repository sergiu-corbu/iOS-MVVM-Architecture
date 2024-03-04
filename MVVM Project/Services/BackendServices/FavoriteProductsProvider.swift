//
//  FavoriteProductsProvider.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.06.2023.
//

import Foundation

protocol FavoriteProductsProviderProtocol {
    
    func getFavoriteProducts(
        ownerID: String, ownerType: ProfileType,
        pageSize: Int, lastID: String?, lastPublishDate: Date?
    ) async throws -> [ProductWrapper]
}

struct FavoriteProductsProvider: FavoriteProductsProviderProtocol {
    
    private let brandService: BrandServiceProtocol?
    private let creatorService: CreatorServiceProtocol?
    
    init(brandService: BrandServiceProtocol?, creatorService: CreatorServiceProtocol?) {
        self.brandService = brandService
        self.creatorService = creatorService
    }
    
    func getFavoriteProducts(ownerID: String, ownerType: ProfileType, pageSize: Int, lastID: String?, lastPublishDate: Date?) async throws -> [ProductWrapper] {
        switch ownerType {
        case .user:
            return try await creatorService?.getFavoriteProducts(
                creatorID: ownerID, pageSize: pageSize,
                lastProductID: lastID, lastProductPublishDate: lastPublishDate
            ) ?? []
        case .brand:
            let products = try await brandService?.getProducts(
                brandID: ownerID, pageSize: pageSize,
                lastID: lastID
            ) ?? []
            return products.map { ProductWrapper(id: $0.id, publishDate: nil, product: $0)}
        }
    }
}

#if DEBUG
struct MockFavoriteProductsProvider: FavoriteProductsProviderProtocol {
    
    func getFavoriteProducts(ownerID: String, ownerType: ProfileType, pageSize: Int, lastID: String?, lastPublishDate: Date?) async throws -> [ProductWrapper] {
        await Task.debugSleep()
        return ProductWrapper.all
    }
}
#endif
