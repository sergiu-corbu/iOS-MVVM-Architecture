//
//  FavoritesManager.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.09.2023.
//

import Foundation
import Combine

class FavoritesManager: ObservableObject {
    
    //MARK: - Properties
    private(set) var favoriteIDs: [FavoriteType:Set<String>]
    private(set) var processedObjectsIDs: [FavoriteType:Set<String>]
    private var currentUserID: String?
    private let maxRequestSize = 200
    
    //MARK: - Computed
    var isFavoriteActionEnabled: Bool {
        return currentUserPublisher.value != nil
    }
    var updatePublisher: PassthroughSubject<FavoriteUpdateContext, Never> {
        return favoritesService.updatePublisher
    }
    func getFavoriteState(type: FavoriteType, objectID: String) -> Bool {
        return favoriteIDs[type]?.contains(objectID) == true
    }
    
    //MARK: - Actions
    private(set) var onRequestAuthentication: NestedCompletionHandler?
    
    //MARK: - Services
    let currentUserPublisher: CurrentValueSubject<User?, Never>
    private let favoritesService: FavoritesServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
        
    init(favoritesService: FavoritesServiceProtocol, analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
         currentUserPublisher: CurrentValueSubject<User?, Never>) {
        
        self.favoritesService = favoritesService
        self.analyticsService = analyticsService
        self.currentUserPublisher = currentUserPublisher
        self.processedObjectsIDs = Dictionary(uniqueKeysWithValues: FavoriteType.allCases.map { ($0, Set<String>() )})
        self.favoriteIDs = self.processedObjectsIDs
    }
    
    //MARK: - Favorite action
    func updateFavoriteState(updateContext: FavoriteUpdateContext) {
        Task(priority: .utility) { [weak self] in
            do {
                await self?.updateFavoritesSet(context: updateContext)
                self?.updatePublisher.send(updateContext)
                switch updateContext.favoriteType {
                case .products:
                    if let product: Product = try await self?.favoritesService.updateFavorites(context: updateContext) {
                        self?.trackFavoriteActionEvent(properties: product.baseAnalyticsProperties, isFavorite: updateContext.isFavorite)
                    }
                case .shows:
                    if let show: Show = try await self?.favoritesService.updateFavorites(context: updateContext) {
                        self?.trackFavoriteActionEvent(properties: show.baseAnalyticsProperties, isFavorite: updateContext.isFavorite)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Note: use this when sign in is required
    func processFavoriteAction(updateContext: FavoriteUpdateContext, onFailure: (() -> Void)?) {
        if isFavoriteActionEnabled {
            updateFavoriteState(updateContext: updateContext)
            return
        }
        
        let signInCompletion = { [weak self] in
            guard let self else { return }
            if self.isFavoriteActionEnabled {
                self.updateFavoriteState(updateContext: updateContext)
            } else {
                onFailure?()
            }
        }
        self.onRequestAuthentication?(signInCompletion)
    }
    
    //MARK: - Data processing
    func processProducts(_ products: [Product]) async {
        for product in products {
            if processedObjectsIDs[.products]?.contains(product.id) == true {
                continue
            }
            await updateFavoritesSet(context: FavoriteUpdateContext(product: product))
            var productIDs = processedObjectsIDs[.products]
            productIDs?.insert(product.id)
            self.processedObjectsIDs[.products] = productIDs
        }
    }
    
    func processShows(_ shows: [Show]) async {
        for show in shows {
            if processedObjectsIDs[.shows]?.contains(show.id) == true {
                continue
            }
            await updateFavoritesSet(context: FavoriteUpdateContext(show: show))
            var showIDs = processedObjectsIDs[.shows]
            showIDs?.insert(show.id)
            self.processedObjectsIDs[.shows] = showIDs
        }
    }
    
    private func updateFavoritesSet(context: FavoriteUpdateContext) async {
        if context.isFavorite {
            var mutable = favoriteIDs[context.favoriteType]
            mutable?.insert(context.objectID)
            favoriteIDs[context.favoriteType] = mutable
        } else {
            var mutable = favoriteIDs[context.favoriteType]
            mutable?.remove(context.objectID)
            favoriteIDs[context.favoriteType] = mutable
        }
    }
    
    //MARK: - Helpers
    func fetchFavoriteItems(userID: String) async {
        do {
            for favoriteType in FavoriteType.allCases {
                if processedObjectsIDs[favoriteType]?.isEmpty == true {
                    continue
                }
                let favoriteIDs: [String]
                switch favoriteType {
                case .shows:
                    let favoriteShows: FavoritesService.FavoritesDTO<Show> = try await favoritesService.getFavorites(
                        userID: userID, favoriteType: favoriteType, pageSize: maxRequestSize, page: nil,
                        existingIDs: processedObjectsIDs[favoriteType]
                    )
                    favoriteIDs = favoriteShows.data.map(\.id)
                case .products:
                    let favoriteProducts: FavoritesService.FavoritesDTO<Product> = try await favoritesService.getFavorites(
                        userID: userID, favoriteType: favoriteType, pageSize: maxRequestSize, page: nil,
                        existingIDs: processedObjectsIDs[favoriteType]
                    )
                    favoriteIDs = favoriteProducts.data.map(\.id)
                }
                self.favoriteIDs[favoriteType] = Set(favoriteIDs)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func reset() {
        favoriteIDs = Dictionary(uniqueKeysWithValues: FavoriteType.allCases.map { ($0, Set<String>() )})
    }
    
    func setAuthenticationAction(_ action: @escaping NestedCompletionHandler) {
        guard onRequestAuthentication == nil else {
            return
        }
        self.onRequestAuthentication = action
    }
    
    //MARK: - Analytics
    func trackFavoriteActionEvent(properties: AnalyticsProperties, isFavorite: Bool) {
        analyticsService.trackActionEvent(isFavorite ? .add_to_favorites : .remove_from_favorites, properties: properties)
    }
}

#if DEBUG
extension FavoritesManager {
    static let mockedFavoritesManager = FavoritesManager(favoritesService: MockFavoritesService(), currentUserPublisher: .init(.creator))
}
#endif
