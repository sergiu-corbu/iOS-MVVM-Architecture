//
//  BrandService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 30.01.2023.
//

import Foundation

protocol BrandServiceProtocol {
    
    func getBrands(query: String?, pageSize: Int?, lastID: String?, lastPriority: Int?) async throws -> [Brand]
    func getBrand(id: String) async throws -> Brand?
    func getProducts(brandID: String, pageSize: Int, lastID: String?) async throws -> [Product]
}

extension BrandServiceProtocol {
    
    func getBrands(query: String? = nil, pageSize: Int?, lastID: String? = nil, lastPriority: Int? = nil) async throws -> [Brand] {
        return try await self.getBrands(query: query, pageSize: pageSize, lastID: lastID, lastPriority: lastPriority)
    }
}

class BrandService: BrandServiceProtocol {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func getBrands(query: String?, pageSize: Int?, lastID: String?, lastPriority: Int?) async throws -> [Brand] {
        var queryParams = [String:Any]()
        queryParams["name"] = query
        queryParams["lastPropName"] = "priority"
        queryParams["lastPropValue"] = lastPriority
        queryParams["lastId"] = lastID
        queryParams["length"] = pageSize
        
        let request = HTTPRequest(method: .get, path: "v1/brands", queryItems: queryParams, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func getBrand(id: String) async throws -> Brand? {
        let request = HTTPRequest(
            method: .get,
            path: "v1/brands/\(id)",
            decodingKeyPath: "brand"
        )
        return try await client.sendRequest(request)
    }
    
    func getProducts(brandID: String, pageSize: Int, lastID: String?) async throws -> [Product] {
        var queryParams: [String:Any] = ["length" : pageSize, "brandIds": brandID]
        queryParams["lastId"] = lastID
        let request = HTTPRequest(method: .get, path: "v1/products", queryItems: queryParams, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
}

#if DEBUG
struct MockBrandService: BrandServiceProtocol {
    
    func getBrands(query: String?, pageSize: Int?, lastID: String?, lastPriority: Int?) async throws -> [Brand] {
        await Task.sleep(seconds: 1)
        return Brand.allBrands
    }
    
    func getBrand(id: String) async throws -> Brand? {
        return try await getBrands(query: nil, pageSize: 0, lastID: nil, lastPriority: nil).randomElement()
    }
    
    func getProducts(brandID: String, pageSize: Int, lastID: String?) async throws -> [Product] {
        await Task.debugSleep()
        return [.sampleProduct]
    }
}
#endif
