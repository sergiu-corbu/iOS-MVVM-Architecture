//
//  FavoritesService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.09.2023.
//

import Foundation
import Combine

enum FavoriteType: String, Identifiable, CaseIterable {
    case shows
    case products
    
    var id: String {
        return rawValue
    }
    
    var sectionTitle: String {
        switch self {
        case .shows: return Strings.Buttons.shows
        case .products: return Strings.Buttons.products
        }
    }
    
    var placeholderImage: ImageResource {
        switch self {
        case .shows: return .addMediaIcon
        case .products: return .fashionIcon
        }
    }
    
    var placeholderMessage: String {
        switch self {
        case .shows: return Strings.Placeholders.favoriteShows
        case .products: return Strings.Placeholders.favoriteProducts
        }
    }
    
    var encodingValue: String {
        switch self {
        case .shows: return "show"
        case .products: return "product"
        }
    }
}

struct FavoriteUpdateContext {
    let objectID: String
    let favoriteType: FavoriteType
    let isFavorite: Bool
}

extension FavoriteUpdateContext {
    
    init(product: Product) {
        self.objectID = product.id
        self.favoriteType = .products
        self.isFavorite = product.isFavorite
    }
    
    init(show: Show) {
        self.objectID = show.id
        self.favoriteType = .shows
        self.isFavorite = show.isFavorite
    }
}

typealias FavoriteOutput = (objectID: String, isFavorite: Bool)

protocol FavoritesServiceProtocol {
    
    @discardableResult
    func updateFavorites<Item: Decodable>(context favoriteContext: FavoriteUpdateContext) async throws -> Item?
    
    func getFavorites<FavoriteItem: Decodable>(
        userID: String, favoriteType: FavoriteType, pageSize: Int, page: Int?, existingIDs: Set<String>?
    ) async throws -> FavoritesService.FavoritesDTO<FavoriteItem>
    
    var updatePublisher: PassthroughSubject<FavoriteUpdateContext, Never> { get }
}

class FavoritesService: FavoritesServiceProtocol {
    
    let client: HTTPClient
    let updatePublisher = PassthroughSubject<FavoriteUpdateContext, Never>()
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func updateFavorites<Item: Decodable>(context favoriteContext: FavoriteUpdateContext) async throws -> Item? {
        let request = HTTPRequest(
            method: favoriteContext.isFavorite ? .post : .delete,
            path: "v1/favorites/\(favoriteContext.objectID)",
            bodyParameters: ["type": favoriteContext.favoriteType.encodingValue],
            decodingKeyPath: "data"
        )
        return try await client.sendRequest(request)
    }
    
    func getFavorites<FavoriteItem: Decodable>(
        userID: String, favoriteType: FavoriteType, pageSize: Int, page: Int?, existingIDs: Set<String>?
    ) async throws -> FavoritesDTO<FavoriteItem> {
        
        var params: [String:Any] = ["type": favoriteType.encodingValue, "length": pageSize]
        params["page"] = page
        if let existingIDs, !existingIDs.isEmpty {
            params["ids"] = existingIDs.map { $0 }
        }
        let request = HTTPRequest(method: .get, path: "v1/favorites/\(userID)", queryItems: params)
        
        return try await client.sendRequest(request)
    }
    
    struct FavoritesDTO<Item: Decodable>: Decodable {
        let data: [Item]
        let totalShows: Int
        let totalProducts: Int
    }
}

#if DEBUG
struct MockFavoritesService: FavoritesServiceProtocol {
    
    var updatePublisher: PassthroughSubject<FavoriteUpdateContext, Never> = .init()
    
    func updateFavorites<Item>(context favoriteContext: FavoriteUpdateContext) async throws -> Item? where Item : Decodable {
        return nil
    }
    
    func getFavorites<FavoriteItem>(
        userID: String, favoriteType: FavoriteType, pageSize: Int, page: Int?, existingIDs: Set<String>?
    ) async throws -> FavoritesService.FavoritesDTO<FavoriteItem> where FavoriteItem : Decodable {
        
        await Task.debugSleep()
        switch favoriteType {
        case .shows: return FavoritesService.FavoritesDTO(data: Show.allShows as! [FavoriteItem], totalShows: Int.random(in: 0..<20), totalProducts: Int.random(in: 0..<20))
        case .products: return FavoritesService.FavoritesDTO(data: Product.all as! [FavoriteItem], totalShows: Int.random(in: 0..<20), totalProducts: Int.random(in: 0..<20))
        }
    }
}
#endif
