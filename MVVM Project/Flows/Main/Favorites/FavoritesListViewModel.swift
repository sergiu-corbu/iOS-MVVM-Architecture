//
//  FavoritesListViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.09.2023.
//

import Foundation
import Combine

class FavoritesListViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var selectedFavoriteType: FavoriteType
    @Published var error: Error?
    let userID: String
    private let pageSize: Int = 20
    
    private var cancellables = Set<AnyCancellable>()
    private var ongoingTasks = [Task<Void, Never>]()
    
    //MARK: - Computed
    var didLoadFirstPage: Bool {
        switch selectedFavoriteType {
        case .shows: return showsDataStore.didLoadFirstPage
        case .products: return productsDataStore.didLoadFirstPage
        }
    }
    
    @Published private(set) var favoriteCounts: (shows: Int, products: Int) = (0,0)
    
    //MARK: - Services
    let favoritesService: FavoritesServiceProtocol
    let favoritesManager: FavoritesManager
    let showsDataStore: PaginatedDataStore<Show>
    let productsDataStore: PaginatedDataStore<Product>
    let analyticsService: AnalyticsServiceProtocol
    private let imageDownloader: any ImageDownloader
        
    //MARK: - Actions
    enum FavoritesListAction {
        case selectShow(Show)
        case selectProduct(Product)
        case back
    }
    let favoritesListActionHandler: (FavoritesListAction) -> Void
    
    init(userID: String, preselectedSection: FavoriteType? = nil, favoritesService: FavoritesServiceProtocol, favoritesManager: FavoritesManager,
         imageDownloader: any ImageDownloader = KFImageDownloader(), analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
         favoritesListActionHandler: @escaping (FavoritesListAction) -> Void) {
        
        self.userID = userID
        self.selectedFavoriteType = preselectedSection ?? .shows
        self.favoritesService = favoritesService
        self.favoritesManager = favoritesManager
        self.favoritesListActionHandler = favoritesListActionHandler
        self.imageDownloader = imageDownloader
        self.analyticsService = analyticsService
        self.showsDataStore = PaginatedDataStore<Show>(pageSize: pageSize)
        self.productsDataStore = PaginatedDataStore<Product>(pageSize: pageSize)
        self.setupBindings()
    }
    
    deinit {
        ongoingTasks.forEach { $0.cancel() }
    }
    
    func updateSelectedSection(favoriteRawValue: String) {
        guard let favoriteType = FavoriteType(rawValue: favoriteRawValue) else {
            return
        }
        selectedFavoriteType = favoriteType
        switch favoriteType {
        case .shows: analyticsService.trackActionEvent(.see_favorite_shows, properties: nil)
        case .products: analyticsService.trackActionEvent(.see_favorite_products, properties: nil)
        }
    }
    
    func loadInitialContent(forceRefresh: Bool = false) {
        if didLoadFirstPage, !forceRefresh {
            return
        }
        
        let task = Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                switch self.selectedFavoriteType {
                case .products: try await forceRefresh ? productsDataStore.refreshContent() : productsDataStore.loadInitialContent()
                case .shows: try await forceRefresh ? showsDataStore.refreshContent() : showsDataStore.loadInitialContent()
                }
            } catch {
                self.error = error
            }
        }
        ongoingTasks.append(task)
    }
    
    @MainActor func handleLoadMore<Item: StringIdentifiable>(for item: Item) async {
        do {
            switch selectedFavoriteType {
            case .shows:
                try await showsDataStore.loadMoreIfNeeded(item as? Show)
            case .products:
                try await productsDataStore.loadMoreIfNeeded(item as? Product)
            }
        } catch {
            self.error = error
        }
    }
    
    private func setupBindings() {
        showsDataStore.onLoadPage { [weak self] _ in
            guard let self else { return [] }
            let response: FavoritesService.FavoritesDTO<Show> = try await favoritesService.getFavorites(
                userID: self.userID, favoriteType: .shows,
                pageSize: self.pageSize, page: self.showsDataStore.currentPage, existingIDs: nil
            )
            await MainActor.run {
                self.favoriteCounts = (response.totalShows, response.totalProducts)
            }
            let favoriteShows = response.data
            await self.favoritesManager.processShows(favoriteShows)
            return favoriteShows
        }
        productsDataStore.onLoadPage { [weak self] _ in
            guard let self else { return [] }
            let response: FavoritesService.FavoritesDTO<Product> = try await favoritesService.getFavorites(
                userID: self.userID, favoriteType: .products,
                pageSize: self.pageSize, page: self.productsDataStore.currentPage, existingIDs: nil
            )
            await MainActor.run {
                self.favoriteCounts = (response.totalShows, response.totalProducts)
            }
            var favoriteProducts = response.data
            await self.favoritesManager.processProducts(favoriteProducts)
            favoriteProducts = await self.imageDownloader.prefetchImages(objects: favoriteProducts)
            return favoriteProducts
        }
        Publishers.MergeMany(showsDataStore.objectWillChange, productsDataStore.objectWillChange).sink { [weak self] in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
        favoritesService.updatePublisher.receive(on: DispatchQueue.main)
            .sink { [weak self] updateContext in
                switch updateContext.favoriteType {
                case .products:
                    guard let product = self?.productsDataStore.findValue(id: updateContext.objectID) else { return }
                    self?.updateSection(item: product, updateContext: updateContext)
                case .shows:
                    guard let show = self?.showsDataStore.findValue(id: updateContext.objectID) else { return }
                    self?.updateSection(item: show, updateContext: updateContext)
                }
            }
            .store(in: &cancellables)
    }
    
    func updateSection<Item: StringIdentifiable>(item: Item, updateContext: FavoriteUpdateContext) {
        switch updateContext.favoriteType {
        case .shows:
            if updateContext.isFavorite {
                showsDataStore.insert(element: item as? Show)
                favoriteCounts.shows += 1
            } else {
                showsDataStore.remove(id: item.id)
                favoriteCounts.shows -= 1
            }
        case .products:
            if updateContext.isFavorite {
                productsDataStore.insert(element: item as? Product)
                favoriteCounts.products += 1
            } else {
                productsDataStore.remove(id: item.id)
                favoriteCounts.products -= 1
            }
        }
    }
}
