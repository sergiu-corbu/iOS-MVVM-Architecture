//
//  ShowService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 30.01.2023.
//

import Foundation
import Combine

protocol ShowRepositoryProtocol {

    func getCreatorShows(pageSize: Int, lastShowID: String?) async throws -> [Show]
    
    func getPublicShows(pageSize: Int, lastShow: Show?) async throws -> [Show]
    
    func getCreatorShow(id: String) async throws -> Show?
    
    func getPublicShow(id: String) async throws -> Show?
    
    func getPublicShows(pageSize: Int, discoverSectionType: DiscoverShowsFeedType) async throws -> [Show]
    
    func getCreatorPublishedShows(creatorID: String, pageSize: Int, lastShowID: String?) async throws -> [Show]
    
    func getProductsForShow(showID: String) async throws -> [Product]
    
    func incrementShowCount(id: String) async throws
    
    func incrementProductViewCount(id: String) async throws
    
    func setShowReminder(id: String, fcmToken: String) async throws
    
    func getShowsForBrand(brandID: String, pageSize: Int, lastID: String?) async throws -> [Show]
}

class ShowService: ShowRepositoryProtocol {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func getCreatorShows(pageSize: Int, lastShowID: String?) async throws -> [Show] {
        var queryItems: [String: Any] = ["length": pageSize]
        queryItems["lastId"] = lastShowID
        let request = HTTPRequest(method: .get, path: "v1/shows", queryItems: queryItems, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func getCreatorShow(id: String) async throws -> Show? {
        let request = HTTPRequest(method: .get, path: "v1/shows/\(id)", decodingKeyPath: "show")
        return try await client.sendRequest(request)
    }
    
    func getPublicShows(pageSize: Int, lastShow: Show?) async throws -> [Show] {
        var queryItems: [String: Any] = ["length": pageSize]
        queryItems["lastId"] = lastShow?.id
        queryItems["lastPropValue"] = [
            lastShow?.statusOrder.description,
            lastShow?.publishingDate?.dateString(formatType: .defaultDate, timeZone: TimeZone(secondsFromGMT: 0)!)
        ]
        if lastShow != nil {
            queryItems["lastPropName"] = "statusOrder,publishingDate"
        }
        
        let request = HTTPRequest(method: .get, path: "v1/shows/public", queryItems: queryItems, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func getPublicShow(id: String) async throws -> Show? {
        let request = HTTPRequest(method: .get, path: "v1/shows/\(id)/public", decodingKeyPath: "show")
        return try await client.sendRequest(request)
    }
    
    func getPublicShows(pageSize: Int, discoverSectionType: DiscoverShowsFeedType) async throws -> [Show] {
        let queryItems: [String: Any] = ["length": pageSize, "type": discoverSectionType.rawValue]
        let request = HTTPRequest(
            method: .get,
            path: "v1/shows/trending",
            queryItems: queryItems,
            decodingKeyPath: "data"
        )
        
        return try await client.sendRequest(request)
    }
    
    func getCreatorPublishedShows(creatorID: String, pageSize: Int, lastShowID: String?) async throws -> [Show] {
        var queryItems: [String: Any] = ["length": pageSize]
        queryItems["lastId"] = lastShowID
        let request = HTTPRequest(method: .get, path: "v1/creators/\(creatorID)/shows", queryItems: queryItems, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func getProductsForShow(showID: String) async throws -> [Product] {
        let request = HTTPRequest(method: .get, path: "v1/products/show/\(showID)", decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func incrementShowCount(id: String) async throws {
        let request = HTTPRequest(method: .post, path: "v1/shows/\(id)/view")
        return try await client.sendRequest(request)
    }
    
    func incrementProductViewCount(id: String) async throws {
        let request = HTTPRequest(method: .post, path: "v1/products/\(id)/view")
        return try await client.sendRequest(request)
    }
    
    func setShowReminder(id: String, fcmToken: String) async throws {
        let parameters: [String:Any] = ["fcmToken": fcmToken]
        let request = HTTPRequest(method: .post, path: "v1/shows/\(id)/reminder", bodyParameters: parameters)
        return try await client.sendRequest(request)
    }
    
    func getShowsForBrand(brandID: String, pageSize: Int, lastID: String?) async throws -> [Show] {
        var queryParams: [String:Any] = ["length": pageSize]
        queryParams["lastId"] = lastID
        let request = HTTPRequest(method: .get, path: "v1/brands/\(brandID)/shows", queryItems: queryParams, decodingKeyPath: "data")
        
        return try await client.sendRequest(request)
    }
}

#if DEBUG
struct MockShowService: ShowRepositoryProtocol {
    
    func getCreatorShows(pageSize: Int, lastShowID: String?) async throws -> [Show] {
        await Task.sleep(seconds: 1)
        return Show.allShows
    }
    
    func getCreatorShow(id: String) async throws -> Show? {
        await Task.sleep(seconds: 1)
        return [.scheduled, .sample].randomElement()
    }
    
    func getPublicShow(id: String) async throws -> Show? {
        await Task.sleep(seconds: 1)
        return [.scheduled, .sample].randomElement()
    }
    
    func getPublicShows(pageSize: Int, lastShow: Show?) async throws -> [Show] {
        await Task.sleep(seconds: 1)
        return Show.allShows
    }
    
    func getPublicShows(pageSize: Int, discoverSectionType: DiscoverShowsFeedType) async throws -> [Show] {
        await Task.sleep(seconds: 1)
        return Show.allShows
    }
    
    func incrementShowCount(id: String) async throws {
        
    }
    
    func getCreatorPublishedShows(creatorID: String, pageSize: Int, lastShowID: String?) async throws -> [Show] {
        await Task.sleep(seconds: 1)
        return [.scheduled, .sample]
    }
    
    func getProductsForShow(showID: String) async throws -> [Product] {
        await Task.sleep(seconds: 1)
        return try Bundle.main.decode([Product].self, from: "file", keyPath: "data") ?? [.prod1, .prod2, .prod3]
    }
    
    func incrementProductViewCount(id: String) async throws {
        
    }
    
    func setShowReminder(id: String, fcmToken: String) async throws {
        await Task.debugSleep()
    }
    
    func getShowsForBrand(brandID: String, pageSize: Int, lastID: String?) async throws -> [Show] {
        await Task.sleep(seconds: 1)
        return [.scheduled, .sample, .published]
    }

}
#endif
