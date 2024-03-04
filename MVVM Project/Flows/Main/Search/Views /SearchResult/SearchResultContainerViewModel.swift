//
//  SearchResultContainerViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.07.2023.
//

import Foundation
import Combine

class SearchResultsContainerViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published private(set) var configs: [SearchResultItemView.Config] = []
    @Published var loadingSourceType: LoadingSourceType?
    let pageSize: Int
    private(set) var filterFacets: [FilterFacet]?
    private(set) var initialFilterFacets: [FilterFacet]?
    private(set) var currentSearchFilter: SearchFilter?
    
    //MARK: - Actions
    let onFinishedSearch = PassthroughSubject<SearchViewModel.SearchState, Never>()
    let onSelectItem = PassthroughSubject<SearchResultItemView.Config, Never>()
    
    //MARK: - Services
    private let searchService: SearchServiceProtocol
    private var ongoingSearchTask: Task<Void, Never>?
    
    init(searchService: SearchServiceProtocol, searchPageSize: Int = 20) {
        self.searchService = searchService
        self.pageSize = searchPageSize
    }
    
    deinit {
        ongoingSearchTask?.cancel()
    }
    
    //MARK: - Search
    func search(text: String, tag: SearchTag, dataSourceType: DataSourceType = .new) {
        let searchFilter = SearchFilter(query: text, searchTag: tag,
                                        currentPage: currentSearchFilter?.currentPage ?? 1,
                                        pageSize: pageSize, priceSorting: .lowToHigh)
        ongoingSearchTask?.cancel()
        ongoingSearchTask = Task(priority: .userInitiated) { [weak self] in
            await self?.search(filter: searchFilter, dataSourceType: dataSourceType)
        }
    }
    
    @MainActor func search(filter: SearchFilter, dataSourceType: DataSourceType) async {
        do {
            self.loadingSourceType = dataSourceType
            var mutableFilter = filter
            if dataSourceType == .new {
                mutableFilter.currentPage = 1
            }
            if mutableFilter.priceSorting == nil {
                mutableFilter.priceSorting = .lowToHigh
            }
            let searchResult = try await searchService.search(filter: mutableFilter)
            if ongoingSearchTask?.isCancelled == true {
                return
            }
            switch dataSourceType {
            case .new: configs = searchResult.configs
            case .paged: configs.append(contentsOf: searchResult.configs)
            }
            
            filterFacets = searchResult.facets
            currentSearchFilter = mutableFilter
            currentSearchFilter?.didLoadLastPage = searchResult.configs.count < pageSize
            onFinishedSearch.send(.finishedSearching(noResults: searchResult.configs.isEmpty && configs.isEmpty))
        } catch {
            if Task.isCancelled {
                self.loadingSourceType = nil
                return
            }
            currentSearchFilter = nil
            onFinishedSearch.send(.finishedSearching(noResults: true))
        }
        self.loadingSourceType = nil
    }
    
    //MARK: Refresh
    func reloadProducts() {
        guard var currentSearchFilter else {
            return
        }
        currentSearchFilter.currentPage = 1
        if currentSearchFilter.priceSorting == nil {
            currentSearchFilter.priceSorting = .lowToHigh
        }
        let filter = currentSearchFilter
        
        ongoingSearchTask?.cancel()
        ongoingSearchTask = Task(priority: .userInitiated) { [weak self] in
            await self?.search(filter: filter, dataSourceType: .new)
        }
    }
    
    func getInitialFilterFacets() async throws {
        guard initialFilterFacets == nil else {
            return
        }
        
        let searchResult = try await searchService.search(filter: SearchFilter.initialProductsFilter)
        filterFacets = searchResult.facets
        initialFilterFacets = filterFacets
        currentSearchFilter = .initialProductsFilter
    }
    
    //MARK: - Pagination
    func loadMoreIfNeeded(for itemID: String) async {
        guard itemID == configs[safe: configs.count - 1]?.id, currentSearchFilter?.didLoadLastPage == false else {
            return
        }
        
        currentSearchFilter?.currentPage += 1
        guard let currentSearchFilter else {
            return
        }
        await search(filter: currentSearchFilter, dataSourceType: .paged)
    }
}
