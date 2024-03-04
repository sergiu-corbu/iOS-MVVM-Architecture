//
//  SearchResultSelectionProvider.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.08.2023.
//

import Foundation

protocol SearchResultSelectionProviderProtocol {
    @MainActor func loadContent<T: Identifiable>(
        for searchResultConfiguration: SearchResultItemView.Config
    ) async throws -> T?
}

class SearchResultSelectionProvider: SearchResultSelectionProviderProtocol {
    
    private let productService: ProductServiceProtocol
    private let creatorService: CreatorServiceProtocol
    private let brandService: BrandServiceProtocol
    private let showService: ShowRepositoryProtocol
    
    init(productService: ProductServiceProtocol, creatorService: CreatorServiceProtocol,
         brandService: BrandServiceProtocol, showService: ShowRepositoryProtocol) {
        self.productService = productService
        self.creatorService = creatorService
        self.brandService = brandService
        self.showService = showService
    }
    
    func loadContent<T: Identifiable>(for searchResultConfiguration: SearchResultItemView.Config) async throws -> T? {
            switch searchResultConfiguration {
            case .show(let show):
                return try await showService.getPublicShow(id: show.id) as? T
            case .product(let product):
                return try await productService.getProduct(id: product.id) as? T
            case .creator(let creator):
                return try await creatorService.getPublicCreator(id: creator.id) as? T
            case .brand(let brand):
                return try await brandService.getBrand(id: brand.id) as? T
        }
    }
}

struct MockSearchResultSelectionProvider: SearchResultSelectionProviderProtocol {
    
    func loadContent<T>(for searchResultConfiguration: SearchResultItemView.Config) async throws -> T? where T : Identifiable {
        return nil
    }
}
