//
//  FollowService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 25.05.2023.
//

import Foundation

enum FollowType: String, Identifiable, Hashable {
    case brand
    case user
    
    var id: String {
        return rawValue
    }
    
    var sectionTitle: String {
        switch self {
        case .brand: return Strings.Buttons.brands
        case .user: return Strings.Buttons.creators
        }
    }
    
    var placeholderImage: ImageResource {
        switch self {
        case .brand: return .menuGridIcon
        case .user: return .doubleUserIcon
        }
    }
    
    var placeholderMessage: String {
        switch self {
        case .brand: return Strings.Placeholders.brands
        case .user: return Strings.Placeholders.following
        }
    }
}

protocol FollowServiceProtocol {
    
    func follow(id: String, type: FollowType) async throws
    func unfollow(id: String, type: FollowType) async throws
    
//    func getFollowers(creatorId: String, pageSize: Int, lastId: String?) async throws -> [FollowService.FollowingUserDTO]
    func getFollowing<T: Decodable & StringIdentifiable>(
        creatorId: String, followType: FollowType, pageSize: Int, lastId: String?
    ) async throws -> [T]
}

class FollowService: FollowServiceProtocol {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func follow(id: String, type: FollowType) async throws {
        let request = HTTPRequest(method: .post, path: "v1/follow/\(id)", bodyParameters: ["followedType": type.rawValue])
        return try await client.sendRequest(request)
    }
    
    func unfollow(id: String, type: FollowType) async throws {
        let request = HTTPRequest(method: .delete, path: "v1/follow/\(id)", bodyParameters: ["followedType": type.rawValue])
        return try await client.sendRequest(request)
    }
    
    //Note: will be implemented in a future feature
//    func getFollowers(creatorId: String, pageSize: Int, lastId: String?) async throws -> [FollowingUserDTO] {
//        var queryItems: [String: Any] = ["length": pageSize]
//        queryItems["lastId"] = lastId
//        let request = HTTPRequest(method: .get, path: "v1/follow/\(creatorId)/followers", queryItems: queryItems, decodingKeyPath: "data")
//        return try await client.sendRequest(request)
//    }
    
    func getFollowing<T: Decodable & StringIdentifiable>(
        creatorId: String, followType: FollowType, pageSize: Int, lastId: String?
    ) async throws -> [T] {
        var queryItems: [String: Any] = ["length": pageSize, "type": followType.rawValue]
        queryItems["lastId"] = lastId
        let request = HTTPRequest(method: .get, path: "v1/follow/\(creatorId)/following", queryItems: queryItems, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
}

extension FollowService {
    
    struct FollowingUserDTO: Decodable, StringIdentifiable, Equatable {
        let _id: String
        let user: User
        
        var id: String { return _id }
        
        #if DEBUG
        static var sampleUsers = ["1", "2", "3"].map {
            FollowService.FollowingUserDTO(_id: $0, user: .mockUsers.randomElement()!)
        }
        #endif
    }
    
    struct FollowingBrandDTO: Decodable, StringIdentifiable, Equatable {
        let _id: String
        let brand: Brand
        
        var id: String { return _id }
        
        #if DEBUG
        static var sampleBrands = ["1", "2", "3"].map {
            FollowService.FollowingBrandDTO(_id: $0, brand: .allBrands.randomElement()!)
        }
        #endif
    }
}

#if DEBUG
struct MockFollowService: FollowServiceProtocol {
    
    func follow(id: String, type: FollowType) async throws {
        
    }
    func unfollow(id: String, type: FollowType) async throws {
        
    }
    
    func getFollowing<T: Decodable & StringIdentifiable>(
        creatorId: String, followType: FollowType, pageSize: Int, lastId: String?
    ) async throws -> [T] {
        await Task.debugSleep()
        switch followType {
        case .brand: return FollowService.FollowingBrandDTO.sampleBrands as! [T]
        case .user: return FollowService.FollowingUserDTO.sampleUsers as! [T]
        }
    }
}
#endif
