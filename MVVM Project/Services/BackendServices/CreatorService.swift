//
//  CreatorService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 23.11.2022.
//

import Foundation

protocol CreatorServiceProtocol {
    
    func addSocialNetworks(_ socialNetworks: Array<SocialNetworkHandle>) async throws
    
    func updateCreator(bio: String?, socialNetworks: Array<SocialNetworkHandle>?) async throws -> User
    
    func getFavoriteProducts(creatorID: String, pageSize: Int, lastProductID: String?, lastProductPublishDate: Date?) async throws -> [ProductWrapper]
    
    func getTopCreators(pageSize: Int, lastId: String?, lastViewsValue: Int?) async throws -> [Creator]
    
    func getPublicCreator(id: String) async throws -> Creator?
    func getShow(id: String) async throws -> Show?
}

typealias SocialNetworkCollection = [[String:String]]

class CreatorService: CreatorServiceProtocol {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func getShows(pageSize: Int, lastShowID: String?) async throws -> [Show] {
        var queryItems: [String: Any] = ["length": pageSize]
        queryItems["lastId"] = lastShowID
        let request = HTTPRequest(method: .get, path: "v1/shows", queryItems: queryItems, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func getShow(id: String) async throws -> Show? {
        let request = HTTPRequest(method: .get, path: "v1/shows/\(id)", decodingKeyPath: "show")
        return try await client.sendRequest(request)
    }
    
    func getFavoriteProducts(creatorID: String, pageSize: Int, lastProductID: String?, lastProductPublishDate: Date?) async throws -> [ProductWrapper] {
        var queryItems:[String:Any] = ["length":pageSize]
        queryItems["lastId"] = lastProductID
        queryItems["lastPropName"] = "publishingDate"
        queryItems["lastPropValue"] = lastProductPublishDate?.dateString(formatType: .defaultDate, timeZone: TimeZone(secondsFromGMT: 0)!)
        
        let request = HTTPRequest(method: .get, path: "v1/products/favorites/\(creatorID)", queryItems: queryItems, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func addSocialNetworks(_ socialNetworks: Array<SocialNetworkHandle>) async throws {
        let request = HTTPRequest(
            method: .post,
            path: "v1/creator-applications",
            bodyParameters: ["socials": makeSocialNetworksCollection(socialNetworks)],
            decodingKeyPath: "user"
        )
        try await client.sendRequest(request)
    }
    
    func updateCreator(bio: String?, socialNetworks: Array<SocialNetworkHandle>?) async throws -> User {
        var parameters = [String: Any]()
        parameters["bio"] = bio
        if let socialNetworks {
            parameters["socials"] = makeSocialNetworksCollection(socialNetworks)
        }
        
        let request = HTTPRequest(
            method: .patch,
            path: "v1/creators/me",
            bodyParameters: parameters,
            decodingKeyPath: "user"
        )
        return try await client.sendRequest(request)
    }
    
    func getTopCreators(pageSize: Int, lastId: String?, lastViewsValue: Int?) async throws -> [Creator] {
        var queryItems: [String: Any] = ["length": pageSize, "lastPropName": "views"]
        queryItems["lastId"] = lastId
        queryItems["lastPropValue"] = lastViewsValue
        let request = HTTPRequest(method: .get, path: "v1/creators/top", queryItems: queryItems, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func getPublicCreator(id: String) async throws -> Creator? {
        let request = HTTPRequest(method: .get, path: "v1/creators/\(id)", decodingKeyPath: "user")
        return try await client.sendRequest(request)
    }
    
    private func makeSocialNetworksCollection(_ socialNetworks: Array<SocialNetworkHandle>) -> SocialNetworkCollection {
        typealias Key = SocialNetworkHandle.CodingKeys
        var _socialNetworks = [[String: String]]()
        
        socialNetworks.forEach { socialNetwork in
            var result = [Key: String]()
            result[.type] = socialNetwork.type.rawValue
            result[.handle] = socialNetwork.handle
            result[.platformName] = socialNetwork.platformName
            result[.websiteUrl] = socialNetwork.websiteUrl?.absoluteString
            _socialNetworks.append(
                Dictionary(uniqueKeysWithValues: result.map { key, value in (key.rawValue, value) })
            )
        }
        
        return _socialNetworks
    }
}

#if DEBUG
struct MockCreatorService: CreatorServiceProtocol {
    
    func addSocialNetworks(_ socialNetworks: Array<SocialNetworkHandle>) async throws {
        
    }

    func getShow(id: String) async throws -> Show? {
        nil
    }
    
    func updateCreator(bio: String?, socialNetworks: Array<SocialNetworkHandle>?) async throws -> User {
        return User.creator
    }
    
    func getFavoriteProducts(creatorID: String, pageSize: Int, lastProductID: String?, lastProductPublishDate: Date?) async throws -> [ProductWrapper] {
        await Task.sleep(seconds: 1)
        return ProductWrapper.all
    }
    
    func getTopCreators(pageSize: Int, lastId: String?, lastViewsValue: Int?) async throws -> [Creator] {
        await Task.sleep(seconds: 1)
        return User.mockUsers
    }
    
    func getPublicCreator(id: String) async throws -> Creator? {
        return User.creator
    }
}
#endif
