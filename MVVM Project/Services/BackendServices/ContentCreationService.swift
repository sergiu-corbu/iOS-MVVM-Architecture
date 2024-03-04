//
//  ContentCreationService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.12.2022.
//

import Foundation
import Combine
import Photos

typealias PublishingShow = (show: Show, videoSections: [VideoSectionType : AVAsset])

protocol ContentCreationServiceProtocol {
    
    func getProductCategories(brandIDs: Set<String>) async throws -> [ProductCategory]
    
    func searchProducts(_ queryInput: String,
                        brandIDs: Set<String>,
                        productCategoryIDs: Set<String>?,
                        lastProductID: String?,
                        pageSize: Int,
                        inStockOnly: Bool) async throws -> [Product]
    
    func createDraftShow(productIds: Set<String>, contentType: ContentCreationType) async throws -> Show
    
    @discardableResult
    func completeDraftShow(showId: String, title: String, publishingDate: Date) async throws -> Show
    
    func requestGifting(skuIDs: [String], shippingAddress: ShippingAddress) async throws
    
    var showDidPublishSubject: PassthroughSubject<PublishingShow, Never> { get }
}

class ContentCreationService: ContentCreationServiceProtocol {
    
    let client: HTTPClient
    let showDidPublishSubject = PassthroughSubject<PublishingShow, Never>()
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func getProductCategories(brandIDs: Set<String>) async throws -> [ProductCategory] {
        let request = HTTPRequest(
            method: .get,
            path: "v1/products/categories",
            queryItems: ["brandIds": Array(brandIDs)],
            encoding: .url,
            decodingKeyPath: "data"
        )
        let categories: [ProductCategory] = try await client.sendRequest(request)
        return categories
    }
    
    func searchProducts(_ queryInput: String, brandIDs: Set<String>, productCategoryIDs: Set<String>?, lastProductID: String?, pageSize: Int, inStockOnly: Bool) async throws -> [Product] {
        var queryItems = [String:Any]()
        queryItems[SearchKeys.lastId] = lastProductID
        queryItems[SearchKeys.length] = pageSize
        queryItems[SearchKeys.brandIds] = Array(brandIDs)
        if inStockOnly {
            queryItems[SearchKeys.inStock] = inStockOnly
        }
        if queryInput.isEmpty == false {
            queryItems[SearchKeys.search] = queryInput
        }
        if let productCategoryIDs, !productCategoryIDs.isEmpty {
            queryItems[SearchKeys.categoryIds] = Array(productCategoryIDs)
        }
        
        let request = HTTPRequest(method: .get, path: "v1/products", queryItems: queryItems, decodingKeyPath: "data")
        
        let response: [Product] = try await client.sendRequest(request)
        return response
    }
    
    func createDraftShow(productIds: Set<String>, contentType: ContentCreationType) async throws -> Show {
        let parameters: [String:Any] = ["productIds": Array(productIds), "type": contentType.rawValue]
        let request = HTTPRequest(
            method: .post, path: "v1/shows",
            bodyParameters: parameters,
            decodingKeyPath: "show"
        )
        let response: Show = try await client.sendRequest(request)
        return response
    }
    
    func completeDraftShow(showId: String, title: String, publishingDate: Date) async throws -> Show {
        let parameters: [String:String] = [
            "title": title,
            "publishingDate": publishingDate.dateString(formatType: .defaultDate, timeZone: TimeZone(secondsFromGMT: 0)!)
        ]
        let request = HTTPRequest(
            method: .put, path: "v1/shows/\(showId)",
            bodyParameters: parameters,
            decodingKeyPath: "show"
        )
        let response: Show = try await client.sendRequest(request)
        return response
    }
    
    func requestGifting(skuIDs: [String], shippingAddress: ShippingAddress) async throws {
        var parameters: [String:Any] = ["skuIds": skuIDs]
        parameters["shippingAddress"] = try JSONEncoder().encodeToHashMap(shippingAddress)
        let request = HTTPRequest(method: .post, path: "v1/gift-requests", bodyParameters: parameters)
        return try await client.sendRequest(request)
    }
    
    private struct SearchKeys {
        static let lastId = "lastId"
        static let length = "length"
        static let brandIds = "brandIds"
        static let search = "search"
        static let categoryIds = "categoryIds"
        static let inStock = "inStock"
    }
}

#if DEBUG
struct MockContentCreationService: ContentCreationServiceProtocol {
    
    let showDidPublishSubject = PassthroughSubject<PublishingShow, Never>()
    
    func getProductCategories(brandIDs: Set<String>) async throws -> [ProductCategory] {
        return ProductCategory.all
    }
    
    func searchProducts(_ queryInput: String, brandIDs: Set<String>, productCategoryIDs: Set<String>?, lastProductID: String?, pageSize: Int, inStockOnly: Bool) async throws -> [Product] {
        await Task.debugSleep()
        if !queryInput.isEmpty {
            return Product.all.filter { $0.name.contains(queryInput)}
        } else {
            return Product.all
        }
    }
    
    func completeDraftShow(showId: String, title: String, publishingDate: Date) async throws -> Show {
        return.sample
    }
    
    func createDraftShow(productIds: Set<String>, contentType: ContentCreationType) async throws -> Show {
        await Task.debugSleep()
        return .scheduled
    }
    
    func requestGifting(skuIDs: [String], shippingAddress: ShippingAddress) async throws {
        
    }
}
#endif
