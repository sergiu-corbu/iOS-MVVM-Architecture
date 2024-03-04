//
//  DiscoverFeedSectionDetailViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.11.2023.
//

import Foundation
import Combine

struct DiscoverFeedDetailActionHandler {
    let onBack: () -> Void
    let onSelectItem: (any StringIdentifiable) -> Void
    let onRequestAuthentication: NestedCompletionHandler
}

class DiscoverFeedSectionDetailViewModel<Item: StringIdentifiable>: ObservableObject {
    
    //MARK: - Properties
    @Published var error: Error?
    let sectionType: ExpandedSectionContentType
    let dataStore: PaginatedDataStore<Item>
    
    var pageSize: Int {
        return dataStore.pageSize
    }
    
    private var cancellables = [AnyCancellable]()
    
    //MARK: - Actions
    let actionHandler: DiscoverFeedDetailActionHandler
    
    //MARK: - Services
    let sectionsDataProvider: DiscoverFeedSectionsDataProviderProtocol
    let userRepository: UserRepository
    let pushNotificationsPermissionHandler: PushNotificationsPermissionHandler
    let followService: FollowServiceProtocol
    private var loadTask: VoidTask?
    
    init(sectionType: ExpandedSectionContentType, sectionsDataProvider: DiscoverFeedSectionsDataProviderProtocol,
         dataStore: PaginatedDataStore<Item>, userRepository: UserRepository, followService: FollowServiceProtocol,
         pushNotificationsPermissionHandler: PushNotificationsPermissionHandler, actionHandler: DiscoverFeedDetailActionHandler
    ) {
        self.sectionType = sectionType
        self.sectionsDataProvider = sectionsDataProvider
        self.dataStore = dataStore
        self.userRepository = userRepository
        self.pushNotificationsPermissionHandler = pushNotificationsPermissionHandler
        self.followService = followService
        self.actionHandler = actionHandler
        
        setupBindings()
        loadTask = Task(priority: .userInitiated) { [weak self] in
            await self?.loadContent()
        }
    }
    
    deinit {
        loadTask?.cancel()
        loadTask = nil
    }
    
    @MainActor func loadContent() async {
        do {
            try await dataStore.loadInitialContent()
        } catch {
            self.error = error
        }
    }
    
    func followViewModel(from creator: Creator) -> FollowViewModel {
        FollowViewModel(
            followingID: creator.id, followType: .user,
            userRepository: userRepository, followService: followService,
            pushNotificationsPermissionHandler: pushNotificationsPermissionHandler,
            onRequestAuthentication: { [weak self] completion in
                self?.actionHandler.onRequestAuthentication(completion)
            }
        )
    }
    
    //MARK: - Setup
    private func setupBindings() {
        dataStore.onLoadPage { [weak self] lastItem in
            guard let self = self else { return [] }
            switch self.sectionType {
            case .brands:
                return try await self.sectionsDataProvider.getTopBrands(
                    maxLength: self.pageSize,
                    lastID: lastItem?.id,
                    lastPriority: (lastItem as? BrandWrapper)?.value.priority
                ).map { BrandWrapper(value: $0) } as? [Item] ?? []
            case .creators:
                return try await self.sectionsDataProvider.getTopCreators(
                    maxLength: self.pageSize,
                    lastID: lastItem?.id,
                    lastViewsPriority: (lastItem as? Creator)?.views
                ) as? [Item] ?? []
            case .products(let sectionType):
                switch sectionType {
                case .justDropped:
                    return try await self.sectionsDataProvider.getJustDroppedProducts(
                        maxLength: self.pageSize,
                        lastID: lastItem?.id,
                        lastPublishDate: (lastItem as? ProductWrapper)?.publishDate
                    ) as? [Item] ?? []
                case .topDeals:
                    return try await self.sectionsDataProvider.getHotDealsProducts(
                        maxLength: self.pageSize,
                        fetchTopDealsOnly: true,
                        lastID: lastItem?.id
                    ).map { ProductWrapper(product: $0) } as? [Item] ?? []
                case .hotDeals:
                    return []
                }
            case .shows(let discoverShowsFeedType):
                return try await self.sectionsDataProvider.getPublicShows(
                    sectionType: discoverShowsFeedType,
                    maxLength: self.pageSize
                ) as? [Item] ?? []
            }
        }
        dataStore.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
    
    func loadMoreContent(lastItem: Item) {
        Task(priority: .userInitiated) { @MainActor [weak self] in
            do {
                try await self?.dataStore.loadMoreIfNeeded(lastItem)
            } catch {
                self?.error = error
            }
        }
    }
}

#if DEBUG
extension DiscoverFeedSectionDetailViewModel {
    static func preview(sectionType: ExpandedSectionContentType) -> DiscoverFeedSectionDetailViewModel {
        DiscoverFeedSectionDetailViewModel(
            sectionType: sectionType,
            sectionsDataProvider: MockDiscoverFeedSectionsDataProvider(),
            dataStore: PaginatedDataStore(pageSize: 10),
            userRepository: MockUserRepository(),
            followService: MockFollowService(),
            pushNotificationsPermissionHandler: MockPushNotificationsHandler(),
            actionHandler: .init(onBack: {}, onSelectItem: {_ in}, onRequestAuthentication: {_ in})
        )
    }
}
#endif
