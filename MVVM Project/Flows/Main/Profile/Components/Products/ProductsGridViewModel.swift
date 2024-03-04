//
//  ProductsGridViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.01.2023.
//

import Foundation
import Combine

extension ProfileComponents {
    
    class ProductsGridViewModel: ObservableObject {
        
        private let dataStore = PaginatedDataStore<ProductWrapper>(pageSize: 12)
        
        var products: [ProductWrapper] {
            return dataStore.items
        }
        
        var placeholderMessage: String
        let accessLevel: ProfileAccessLevel
        let type: ProfileType
        private let ownerID: String
        
        //MARK: Services
        let favoriteProductsProvider: FavoriteProductsProviderProtocol
        
        var onErrorReceived: ((Error) -> Void)?
        private var cancellables = Set<AnyCancellable>()
        private var loadTask: VoidTask?
        
        var showPlaceholder: Bool {
            return products.isEmpty && dataStore.didLoadFirstPage
        }
        var loadingType: LoadingSourceType? {
            return dataStore.loadingSourceType
        }
        
        init(ownerID: String, type: ProfileType, favoriteProductsProvider: FavoriteProductsProviderProtocol, accessLevel: ProfileAccessLevel) {
            self.ownerID = ownerID
            self.type = type
            self.favoriteProductsProvider = favoriteProductsProvider
            self.accessLevel = accessLevel
            self.placeholderMessage = accessLevel == .readWrite ? Strings.Placeholders.creatorFavorites : Strings.Placeholders.guestFavorites(owner: "creator")
            
            setupDataStore()
            loadTask = Task(priority: .userInitiated, { [weak self] in
                try await self?.dataStore.loadInitialContent()
            }, catch: { [weak self] in
                self?.onErrorReceived?($0)
            })
        }
        
        deinit {
            loadTask?.cancel()
        }
        
        private func setupDataStore() {
            dataStore.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
            
            dataStore.onLoadPage { [weak self] lastProduct in
                guard let self else { return [] }
                var products = try await favoriteProductsProvider.getFavoriteProducts(
                    ownerID: self.ownerID, ownerType: self.type, pageSize: self.dataStore.pageSize,
                    lastID: lastProduct?.id, lastPublishDate: lastProduct?.publishDate
                )
                
                await products.prefetchImagesMetadata()
                return products
            }
        }
        
        func loadMoreProductsIfNeeded(_ lastProduct: ProductWrapper?) {
            Task(priority: .userInitiated) { @MainActor [weak self] in
                try await self?.dataStore.loadMoreIfNeeded(lastProduct)
            } catch: {
                if !Task.isCancelled {
                    self.onErrorReceived?($0)
                }
            }
        }
      
        @MainActor func reloadProducts() async {
            do {
                try await dataStore.refreshContent()
            } catch {
                onErrorReceived?(error)
            }
        }
    }
}

#if DEBUG
extension ProfileComponents.ProductsGridViewModel {
    
    static let previewVM = ProfileComponents.ProductsGridViewModel(
        ownerID: UUID().uuidString, type: .user,
        favoriteProductsProvider: MockFavoriteProductsProvider(),
        accessLevel: .readOnly
    )
}
#endif
