//
//  ShowsGridViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.12.2022.
//

import Foundation

extension ProfileComponents {
    
    class ShowsGridViewModel: ObservableObject {
        
        //MARK: - Properties
        @Published var shows: [Show] = []
        @Published private(set) var isLoading = true
        private(set) var isInitialLoad = true
        
        let type: ProfileType
        let ownerID: String
        let accessLevel: ProfileAccessLevel
        var showsPlaceholderMessage: String
        private var dataSourceConfiguration: any DataSourceConfiguration
        
        //MARK: - Action
        var actionHandler: ProfileShowsGridAction?
        
        //MARK: - Services
        let showService: ShowRepositoryProtocol
        
        //MARK: - Computed
        var showPlaceholderView: Bool {
            return shows.isEmpty && isFirstLoad
        }
        var isFirstLoad: Bool {
            return dataSourceConfiguration.didLoadFirstPage
        }
        
        init(ownerID: String, type: ProfileType, showService: ShowRepositoryProtocol, accessLevel: ProfileAccessLevel,
             dataSourceConfiguration: any DataSourceConfiguration = PaginatedDataSourceConfiguration(pageSize: 10),
             actionHandler: ProfileShowsGridAction?
        ) {
            self.ownerID = ownerID
            self.type = type
            self.showService = showService
            self.accessLevel = accessLevel
            self.actionHandler = actionHandler
            self.dataSourceConfiguration = dataSourceConfiguration
            self.showsPlaceholderMessage = accessLevel == .readWrite ? Strings.Placeholders.creatorShows : Strings.Placeholders.guestShows(owner: "creator")
        }
        
        func loadMoreShowsIfNeeded(_ lastShowID: String) {
            guard dataSourceConfiguration.shouldLoadMore(itemID: lastShowID) else {
                return
            }
            Task(priority: .userInitiated) {
                await loadShows(sourceType: .paged)
            }
        }
        
        @MainActor
        func loadShows(sourceType: DataSourceType = .new) async {
            do {
                isLoading = true
                
                if sourceType == .new {
                    dataSourceConfiguration.reset()
                }
                
                let newShows: [Show]
                switch accessLevel {
                case .readOnly:
                    switch type {
                    case .user:
                        newShows = try await showService.getCreatorPublishedShows(creatorID: ownerID, pageSize: dataSourceConfiguration.pageSize, lastShowID: dataSourceConfiguration.lastItemID)
                    case .brand:
                        newShows = try await showService.getShowsForBrand(brandID: ownerID, pageSize: dataSourceConfiguration.pageSize, lastID: dataSourceConfiguration.lastItemID)
                    }
                    case .readWrite:
                    newShows = try await showService.getCreatorShows(
                        pageSize: dataSourceConfiguration.pageSize,
                        lastShowID: dataSourceConfiguration.lastItemID
                    )
                }
                dataSourceConfiguration.processResult(results: newShows)
                
                switch sourceType {
                case .paged:
                    shows.append(contentsOf: newShows)
                case .new:
                    shows = newShows
                }
                isInitialLoad = false
            } catch {
                actionHandler?.onErrorReceived?(error)
            }
            isLoading = false
        }
        
        func handlePlacehoderAction() {
            guard accessLevel == .readWrite else {
                return
            }
            actionHandler?.onCreateShow?()
        }
    }
}
