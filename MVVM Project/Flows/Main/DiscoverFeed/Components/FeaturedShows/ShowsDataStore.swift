//
//  ShowsDataStore.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.04.2023.
//

import Foundation

protocol ShowsDataStoreProtocol: ObservableObject {
    var loadingSourceType: LoadingSourceType? { get }
    var shows: [Show] { get }
    
    func loadInitialContent() async throws
    func loadMoreShowsIfNeeded(_ showID: String?) async throws
    func refreshContent(delay: TimeInterval?) async throws
    func updatePublicShow(_ updatedShow: Show)
    func removeShow(id showID: String)
    func indexOf(showID: String) -> Int?
    func getExistingShowOrFetchIfNeeded(showID: String) async throws -> Show?
}

final class StaticShowsDataStore: ShowsDataStoreProtocol {
        
    var loadingSourceType: LoadingSourceType? = nil
    @Published private(set) var shows: [Show]
    
    init(shows: [Show]) {
        self.shows = shows
    }
    
    func loadInitialContent() async throws {
    }
    
    func loadMoreShowsIfNeeded(_ showID: String?) async throws {
    }
    
    func refreshContent(delay: TimeInterval?) async throws {
    }
    
    func updatePublicShow(_ updatedShow: Show) {
        guard let showIndex = indexOf(showID: updatedShow.id) else {
            return
        }
        shows[showIndex] = updatedShow
    }
    
    func removeShow(id showID: String) {
        guard let showIndex = indexOf(showID: showID) else {
            return
        }
        shows.remove(at: showIndex)
    }
    
    func indexOf(showID: String) -> Int? {
        return shows.firstIndex(where: { $0.id == showID })
    }
    
    func getExistingShowOrFetchIfNeeded(showID: String) async throws -> Show? {
        return shows.first(where: { $0.id == showID })
    }
}

final class PaginatedShowsDataStore: ShowsDataStoreProtocol {
    
    //MARK: Properties
    @Published private(set) var loadingSourceType: LoadingSourceType?
    @Published private(set) var shows = [Show]()
    
    /// Loading more content will be paused as shows.last will be != previewShows.last unless there is no shows left to load
    /// This takes into consideration the possibility of not having the shows correctly sorted by the backend
    var previewShows: [Show] {
        shows.prefix(while: \.isFeatured)        
    }
    
    //MARK: Services
    let showService: ShowRepositoryProtocol
    private(set) var dataSourceConfiguration: any DataSourceConfiguration
    
    init(showService: ShowRepositoryProtocol,
         dataSourceConfiguration: any DataSourceConfiguration = PaginatedDataSourceConfiguration(pageSize: 10),
         shows: [Show]? = nil) {
        
        self.showService = showService
        self.dataSourceConfiguration = dataSourceConfiguration
        
        if let shows {
            self.dataSourceConfiguration.processResult(results: shows, additionalValue: shows.last)
            self.shows = shows
        }
    }
    
    private func loadPublicShows() async throws -> [Show] {
        let retrievedShows = try await showService.getPublicShows(pageSize: dataSourceConfiguration.pageSize, lastShow: dataSourceConfiguration.additionalLastItemProperty as? Show)
        dataSourceConfiguration.processResult(results: retrievedShows, additionalValue: retrievedShows.last)
        
        return retrievedShows
    }
    
    @MainActor
    func loadInitialContent() async throws {
        loadingSourceType = .new
        dataSourceConfiguration.reset()
        
        defer {
            loadingSourceType = nil
        }
        shows = try await loadPublicShows()
    }
    
    @MainActor
    func refreshContent(delay: TimeInterval? = nil) async throws {
        dataSourceConfiguration.reset()
        let shows_ = try await loadPublicShows()
    
        if let delay {
            DispatchQueue.main.asyncAfter(seconds: delay) { [weak self] in
                self?.shows = shows_
            }
        } else {
            shows = shows_
        }
    }
    
    @MainActor
    func loadMoreShowsIfNeeded(_ showID: String?) async throws {
        guard dataSourceConfiguration.shouldLoadMore(itemID: showID), loadingSourceType == nil else {
            return
        }
        
        defer {
            loadingSourceType = nil
        }
        
        loadingSourceType = .paged
        shows.append(contentsOf: try await loadPublicShows())
    }
    
    func updatePublicShow(_ updatedShow: Show) {
        guard let showIndex = indexOf(showID: updatedShow.id) else {
            return
        }
        shows[showIndex] = updatedShow
    }
    
    func removeShow(id showID: String) {
        guard let showIndex = indexOf(showID: showID) else {
            return
        }
        shows.remove(at: showIndex)
    }
    
    func indexOf(showID: String) -> Int? {
        return shows.firstIndex(where: { $0.id == showID })
    }
    
    func getExistingShowOrFetchIfNeeded(showID: String) async throws -> Show? {
        var sharedShow: Show? = shows.first(where: { $0.id == showID })
        if sharedShow == nil {
            sharedShow = try await showService.getPublicShow(id: showID)
        }
        return sharedShow
    }
}
