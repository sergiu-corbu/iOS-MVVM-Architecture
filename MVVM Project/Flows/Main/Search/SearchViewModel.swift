//
//  SearchViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.06.2023.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published private(set) var searchState: SearchState = .inactive
    @Published var selectedSearchTag: SearchTag = .all
    
    let searchTags = SearchTag.allCases
    let searchBarViewModel = SearchBarViewModel()
    private(set) lazy var searchResultsViewModel: SearchResultsContainerViewModel = {
        SearchResultsContainerViewModel(searchService: searchService)
    }()
    
    let contentScrollViewOffsetResetPublisher = PassthroughSubject<Void, Never>()
    let activeFiltersCountPublisher = CurrentValueSubject<Int, Never>(0)
    let onResetSearchInput = PassthroughSubject<Void, Never>()
    
    //MARK: - Computed
    var isFilterActionEnabled: Bool {
        if searchState.isInactive, searchResultsViewModel.initialFilterFacets?.isEmpty == false {
            return true
        } else {
            return selectedSearchTag == .products && searchState.shouldDisplayTagsSelector
        }
    }
    
    //MARK: - Services
    private let searchService: SearchServiceProtocol
    private let searchResultSelectionProvider: SearchResultSelectionProviderProtocol
    private let debouncer = Debouncer(delay: 0.3)
    let justDroppedProductsDataStore: JustDroppedProductsDataStore
    let checkoutCartManager: CheckoutCartManager
    let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Actions
    enum SearchActionType {
        case show(Show)
        case brand(Brand)
        case creator(Creator)
        case product(Product)
        case checkoutCart
    }
    
    let searchActionHandler: (SearchActionType) -> Void
    let onSelectFilter: (SearchFilter, [FilterFacet]) -> Void
    
    init(searchService: SearchServiceProtocol, checkoutCartManager: CheckoutCartManager,
         searchResultSelectionProvider: SearchResultSelectionProviderProtocol,
         justDroppedProductsDataStore: JustDroppedProductsDataStore,
         searchActionHandler: @escaping (SearchActionType) -> Void,
         onSelectFilter: @escaping (SearchFilter, [FilterFacet]) -> Void) {
        
        self.searchResultSelectionProvider = searchResultSelectionProvider
        self.checkoutCartManager = checkoutCartManager
        self.searchService = searchService
        self.justDroppedProductsDataStore = justDroppedProductsDataStore
        self.searchActionHandler = searchActionHandler
        self.onSelectFilter = onSelectFilter
        
        setup()
    }
    
    //MARK: - Setup
    private func setup() {
        setupSearchBar()
        setupSearchResults()
        Task(priority: .utility) { [weak self] in
            do {
                try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                    guard let self else { return }
                    taskGroup.addTask(priority: .utility) {
                        try await self.justDroppedProductsDataStore.loadContent()
                    }
                    taskGroup.addTask(priority: .utility) {
                        try await self.searchResultsViewModel.getInitialFilterFacets()
                    }
                    try await taskGroup.waitForAll()
                }
            } catch {
                await MainActor.run {
                    ToastDisplay.showErrorToast(error: error)
                }
            }
        }
        justDroppedProductsDataStore.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
    
    //MARK: - Pull to refresh
    func handleRefreshAction() {
        switch searchState {
        case .finishedSearching(noResults: _):
            searchResultsViewModel.reloadProducts()
        case .inactive:
            Task(priority: .userInitiated) { [weak self] in
                await self?.reloadJustDroppedProduct()
            }
        case .idle, .searching:
            return
        }
    }
    
    @MainActor func reloadJustDroppedProduct() async {
        if searchState.isSearching {
            return
        }
        do {
            try await justDroppedProductsDataStore.refreshContent()
        } catch {
            ToastDisplay.showErrorToast(error: error)
        }
    }
    
    //MARK: - Searching
    private func debounceAndSearch() {
        searchState = .searching
        debouncer.debounce { [weak self] in
            self?.searchAction()
        }
    }
    
    private func searchAction() {
        searchResultsViewModel.search(text: searchBarViewModel.text, tag: selectedSearchTag)
        trackSearchAction()
    }
    
    //MARK: - Setup
    private func setupSearchBar() {
        searchBarViewModel.$text.dropFirst()
            .removeDuplicates()
            .sink { [weak self] in
                self?.handleInputChanged(searchQuery: $0)
            }
            .store(in: &cancellables)
        searchBarViewModel.onCancel.sink { [weak self] in
            self?.searchState = .inactive
            self?.contentScrollViewOffsetResetPublisher.send()
            self?.onResetSearchInput.send()
        }
        .store(in: &cancellables)
        searchBarViewModel.onClear.sink { [weak self] in
            self?.searchState = .idle
            self?.contentScrollViewOffsetResetPublisher.send()
            self?.onResetSearchInput.send()
        }
        .store(in: &cancellables)
        searchBarViewModel.isInputFieldActivePublisher.sink { [weak self] isActive in
            if isActive {
                self?.trackSearchFieldSelectionAction()
                self?.contentScrollViewOffsetResetPublisher.send()
            }
        }
        .store(in: &cancellables)
        onResetSearchInput.sink { [weak self] in
            self?.activeFiltersCountPublisher.send(0)
        }
        .store(in: &cancellables)
    }
    
    private func setupSearchResults() {
        searchResultsViewModel.onFinishedSearch.assign(to: &$searchState)
        searchResultsViewModel.onSelectItem.sink { [weak self] selectedItem in
            Task(priority: .userInitiated) { [weak self] in
                await self?.loadContent(for: selectedItem)
            }
        }
        .store(in: &cancellables)
    }
    
    func searchTagSelectedAction(_ searchTag: SearchTag) {
        selectedSearchTag = searchTag
        trackSearchFilterSelection(searchTag)
        contentScrollViewOffsetResetPublisher.send()
        activeFiltersCountPublisher.send(0)
        onResetSearchInput.send()
        debounceAndSearch()
    }
    
    private func handleInputChanged(searchQuery: String) {
        if searchQuery.isEmpty {
            return
        }
        
        searchBarViewModel.cancelButtonVisible = searchQuery.isEmpty
        if searchQuery.count > 2 {
            debounceAndSearch()
            onResetSearchInput.send()
        } else {
            searchState = .idle
            debouncer.cancel()
        }
    }
    
    func loadMoreProductsIfNeeded() {
        Task(priority: .userInitiated) { @MainActor [weak self] in
            do {
                try await self?.justDroppedProductsDataStore.loadMoreIfNeeded()
            } catch {
                ToastDisplay.showErrorToast(error: error)
            }
        }
    }

    @MainActor
    private func loadContent(for searchConfig: SearchResultItemView.Config) async {
        do {
            switch searchConfig {
            case .show(_):
                if let show: Show = try await searchResultSelectionProvider.loadContent(for: searchConfig) {
                    searchActionHandler(.show(show))
                    trackSearchResultSelection(show.baseAnalyticsProperties)
                }
            case .product(_):
                if let product: Product = try await searchResultSelectionProvider.loadContent(for: searchConfig) {
                    searchActionHandler(.product(product))
                    trackSearchResultSelection(product.baseAnalyticsProperties)
                }
            case .creator(_):
                if let creator: Creator = try await searchResultSelectionProvider.loadContent(for: searchConfig) {
                    searchActionHandler(.creator(creator))
                    trackSearchResultSelection(creator.baseAnalyticsProperties)
                }
            case .brand(_):
                if let brand: Brand = try await searchResultSelectionProvider.loadContent(for: searchConfig) {
                    searchActionHandler(.brand(brand))
                    trackSearchResultSelection(brand.baseAnalyticsProperties)
                }
            }
        }
        catch {
            ToastDisplay.showErrorToast(error: error)
        }
    }
    
    func handleFilterSelection() {
        let filterFacets: [FilterFacet]?
        let searchFilter: SearchFilter?
        if searchState.isInactive {
            filterFacets = searchResultsViewModel.initialFilterFacets
            searchFilter = .initialProductsFilter
        } else {
            filterFacets = searchResultsViewModel.filterFacets
            searchFilter = searchResultsViewModel.currentSearchFilter
        }
        
        guard let filterFacets, let searchFilter else {
            return
        }
        
        onSelectFilter(searchFilter, filterFacets)
    }
    
    func applySearchFilters(_ searchFilter: SearchFilter) {
        activeFiltersCountPublisher.send(searchFilter.activeFiltersCount)
        contentScrollViewOffsetResetPublisher.send()
        if selectedSearchTag != .products {
            selectedSearchTag = .products
        }
        
        Task(priority: .userInitiated) { [weak self] in
            await self?.searchResultsViewModel.search(filter: searchFilter, dataSourceType: .new)
        }
    }
}

extension SearchViewModel {
    
    enum SearchState {
        case inactive, idle
        case searching, finishedSearching(noResults: Bool)

        var shouldDisplayTagsSelector: Bool {
            switch self {
            case .inactive, .idle:
                return false
            case .finishedSearching, .searching:
                return true
            }
        }

        var isSearching: Bool {
            if case .searching = self {
                return true
            }
            return false
        }
        var isInactive: Bool {
            if case .inactive = self {
                return true
            }
            return false
        }
    }
}

#if DEBUG
extension SearchViewModel {
    static let previewVM = SearchViewModel(
        searchService: MockSearchService(),
        checkoutCartManager: .mocked,
        searchResultSelectionProvider: MockSearchResultSelectionProvider(),
        justDroppedProductsDataStore: PreviewJustDroppedProductsDataStore(),
        searchActionHandler: {_ in}, onSelectFilter: { _, _ in}
    )
}
#endif
