//
//  ShowRepository.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 11.09.2023.
//

import Foundation
import Combine

class ShowRepository: ObservableObject, ShowRepositoryProtocol {
    
    //MARK: - Services
    let showService: ShowRepositoryProtocol
    let favoritesManager: FavoritesManager
    
    init(showSevice: ShowRepositoryProtocol, favoritesManager: FavoritesManager) {
        self.showService = showSevice
        self.favoritesManager = favoritesManager
    }
    
    func getCreatorShows(pageSize: Int, lastShowID: String?) async throws -> [Show] {
        let shows = try await showService.getCreatorShows(pageSize: pageSize, lastShowID: lastShowID)
        await favoritesManager.processShows(shows)
        return shows
    }
    
    func getPublicShows(pageSize: Int, lastShow: Show?) async throws -> [Show] {
        let shows = try await showService.getPublicShows(pageSize: pageSize, lastShow: lastShow)
        await favoritesManager.processShows(shows)
        return shows
    }
    
    func getCreatorShow(id: String) async throws -> Show? {
        let show = try await showService.getCreatorShow(id: id)
        if let show {
            await favoritesManager.processShows([show])
        }
        return show
    }
    
    func getPublicShow(id: String) async throws -> Show? {
        let show = try await showService.getPublicShow(id: id)
        if let show {
            await favoritesManager.processShows([show])
        }
        return show
    }
    
    func getPublicShows(pageSize: Int, discoverSectionType: DiscoverShowsFeedType) async throws -> [Show] {
        let shows = try await showService.getPublicShows(pageSize: pageSize, discoverSectionType: discoverSectionType)
        await favoritesManager.processShows(shows)
        return shows
    }
    
    func getCreatorPublishedShows(creatorID: String, pageSize: Int, lastShowID: String?) async throws -> [Show] {
        let shows = try await showService.getCreatorPublishedShows(creatorID: creatorID, pageSize: pageSize, lastShowID: lastShowID)
        await favoritesManager.processShows(shows)
        return shows
    }
    
    func getProductsForShow(showID: String) async throws -> [Product] {
        return try await showService.getProductsForShow(showID: showID)
    }
    
    func incrementShowCount(id: String) async throws {
        return try await showService.incrementShowCount(id: id)
    }
    
    func incrementProductViewCount(id: String) async throws {
        return try await showService.incrementProductViewCount(id: id)
    }
    
    func setShowReminder(id: String, fcmToken: String) async throws {
        return try await showService.setShowReminder(id: id, fcmToken: fcmToken)
    }
    
    func getShowsForBrand(brandID: String, pageSize: Int, lastID: String?) async throws -> [Show] {
        let shows = try await showService.getShowsForBrand(brandID: brandID, pageSize: pageSize, lastID: lastID)
        await favoritesManager.processShows(shows)
        return shows
    }
}
