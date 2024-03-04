//
//  ProductService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 20.06.2023.
//

import Foundation

protocol ProductServiceProtocol {
    
    func getProductWith(id: String) async throws -> Product
    func getJustDroppedProducts(pageSize: Int, lastID: String?, lastProductPublishDate: Date?) async throws -> [ProductWrapper]
    func getProduct(id: String) async throws -> Product?
    func getProductsForPromotionalBanner(bannerID: String) async throws -> [Product]
    func getHotDealsProducts(maxLength: Int, fetchTopDealsOnly: Bool?, lastID: String?) async throws -> [Product]
}

class ProductService: ProductServiceProtocol {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func getProductWith(id: String) async throws -> Product {
        let request = HTTPRequest(method: .get, path: "v1/products/\(id)", decodingKeyPath: "product")
        return try await client.sendRequest(request)
    }
    
    func getJustDroppedProducts(pageSize: Int, lastID: String?, lastProductPublishDate: Date?) async throws -> [ProductWrapper] {
        var queryParams: [String:Any] = ["length": pageSize]
        queryParams["lastPropName"] = "publishingDate"
        queryParams["lastPropValue"] = lastProductPublishDate?.dateString(formatType: .defaultDate, timeZone: TimeZone(secondsFromGMT: 0)!)
        queryParams["lastId"] = lastID
        
        let request = HTTPRequest(method: .get, path: "v1/products/discovery", queryItems: queryParams, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }

    func getProduct(id: String) async throws -> Product? {
        let request = HTTPRequest(
            method: .get,
            path: "v1/products/\(id)",
            decodingKeyPath: "product"
        )
        return try await client.sendRequest(request)
    }
    
    func getProductsForPromotionalBanner(bannerID: String) async throws -> [Product] {
        let request = HTTPRequest(method: .get, path: "v1/products/banner/\(bannerID)", decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func getHotDealsProducts(maxLength: Int, fetchTopDealsOnly: Bool?, lastID: String?) async throws -> [Product] {
        var queryParams: [String:Any] = ["length": maxLength]
        queryParams["lastId"] = lastID
        queryParams["onlyFeatured"] = fetchTopDealsOnly

        let request = HTTPRequest(method: .get, path: "v1/products/hot-deals", queryItems: queryParams, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
}

#if DEBUG
struct MockProductService: ProductServiceProtocol {
    
    func getProductWith(id: String) async throws -> Product {
        await Task.debugSleep()
        return .sampleProduct
    }
    
    func getJustDroppedProducts(pageSize: Int, lastID: String?, lastProductPublishDate: Date?) async throws -> [ProductWrapper] {
        await Task.debugSleep()
        return [ProductWrapper(id: "1", publishDate: .now, product: .sampleProduct), ProductWrapper(id: "2", publishDate: .now, product: .sampleProduct), ProductWrapper(id: "3", publishDate: .now, product: .sampleProduct)]
    }

    func getProduct(id: String) async throws -> Product? {
        nil
    }
    func getProductsForPromotionalBanner(bannerID: String) async throws -> [Product] {
        await Task.debugSleep()
        return [.sampleProduct]
    }
    
    func getHotDealsProducts(maxLength: Int, fetchTopDealsOnly: Bool?, lastID: String?) async throws -> [Product] {
        await Task.debugSleep()
        return Product.all
    }
}
#endif
