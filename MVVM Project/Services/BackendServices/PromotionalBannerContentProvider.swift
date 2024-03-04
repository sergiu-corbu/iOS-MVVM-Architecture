//
//  PromotionalBannerContentProvider.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 11.10.2023.
//

import Foundation

protocol PromotionalBannerContentProviderProtocol {
    func getPromotedBrand(id brandID: String) async throws -> Brand?
    func getPromotedCreator(id creatorID: String) async throws -> Creator?
    func getPromotionalBanner(id: String, type: PromotionalBannerType) async throws -> PromotionalBanner?
    func getPromotionalBanners() async throws -> [PromotionalBanner]
}

extension PromotionalBannerContentProviderProtocol {
    func getPromotionalBanner(id: String, type: PromotionalBannerType = .productList) async throws -> PromotionalBanner? {
        try await self.getPromotionalBanner(id: id, type: type)
    }
}

class PromotionalBannerContentRepository: PromotionalBannerContentProviderProtocol {
    
    init(client: HTTPClient) {
        self.client = client
        self.brandService = BrandService(client: client)
        self.creatorService = CreatorService(client: client)
    }
    
    //MARK: - Services
    let client: HTTPClient
    let brandService: BrandServiceProtocol
    let creatorService: CreatorServiceProtocol
    
    func getPromotedBrand(id brandID: String) async throws -> Brand? {
        return try await brandService.getBrand(id: brandID)
    }
    func getPromotedCreator(id creatorID: String) async throws -> Creator? {
        return try await creatorService.getPublicCreator(id: creatorID)
    }
    
    func getPromotionalBanner(id: String, type: PromotionalBannerType) async throws -> PromotionalBanner? {
        let request = HTTPRequest(
            method: .get,
            path: "v1/banners/\(id)",
            queryItems: ["type" : type.rawValue],
            decodingKeyPath: "banner"
        )
        return try await client.sendRequest(request)
    }
    
    func getPromotionalBanners() async throws -> [PromotionalBanner] {
        let request = HTTPRequest(method: .get, path: "v1/banners", queryItems: ["lenght" : 20], decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
}

#if DEBUG
struct MockPromotionalBannerContentProvider: PromotionalBannerContentProviderProtocol {
    func getPromotedBrand(id brandID: String) async throws -> Brand? {
        return Brand.allBrands.randomElement()
    }
    func getPromotedCreator(id creatorID: String) async throws -> Creator? {
        return Creator.creator
    }
    func getPromotionalBanner(id: String, type: PromotionalBannerType) async throws -> PromotionalBanner? {
        await Task.debugSleep()
        return PromotionalBanner.mockedBanners.first
    }
    func getPromotionalBanners() async throws -> [PromotionalBanner] {
        await Task.debugSleep()
        return PromotionalBanner.mockedBanners
    }
}

struct MockEmptyPromotionalBannerContentProvider: PromotionalBannerContentProviderProtocol {
    func getPromotedBrand(id brandID: String) async throws -> Brand? {
        return Brand.allBrands.randomElement()
    }
    func getPromotedCreator(id creatorID: String) async throws -> Creator? {
        return Creator.creator
    }
    func getPromotedProducts(bannerID: String) async throws -> [Product] {
        return [Product.sampleProduct]
    }
    func getPromotionalBanners() async throws -> [PromotionalBanner] {
        await Task.debugSleep()
        return []
    }
}
#endif
