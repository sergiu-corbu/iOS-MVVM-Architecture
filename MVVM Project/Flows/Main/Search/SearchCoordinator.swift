//
//  SearchCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.06.2023.
//

import Foundation
import UIKit
import SwiftUI

class SearchCoordinator: MainFlowCoordinator {
    
    //MARK: - Properties
    private(set) var searchViewModel: SearchViewModel?
    private(set) var filterViewModel: FilterViewModel?
    
    func start() {
        setupSearchViewController()
    }
    
    //MARK: - Search VC setup
    private func setupSearchViewController() {
        let searchResultSelectionProvider = SearchResultSelectionProvider(
            productService: dependencyContainer.productService, creatorService: dependencyContainer.creatorService,
            brandService: dependencyContainer.brandService, showService: dependencyContainer.showRepository
        )
        let searchViewModel = SearchViewModel(
            searchService: dependencyContainer.searchService,
            checkoutCartManager: dependencyContainer.checkoutCartManager,
            searchResultSelectionProvider: searchResultSelectionProvider,
            justDroppedProductsDataStore: dependencyContainer.justDroppedProductsDataStore,
            searchActionHandler: { [weak self] searchItem in
                self?.showSearchDetails(for: searchItem)
            }, onSelectFilter: { [weak self] (searchFilter, filterFacets) in
                self?.showFiltersAndSortingView(searchFilter: searchFilter, filterFacets: filterFacets, animated: true)
            }
        )
        searchViewModel.onResetSearchInput.sink { [weak self] in
            self?.filterViewModel = nil
        }
        .store(in: &cancellables)
        
        self.searchViewModel = searchViewModel
        let searchViewController = SearchViewController(viewModel: searchViewModel)
        navigationController.setViewControllers([searchViewController], animated: false)
    }
    
    private func showFiltersAndSortingView(searchFilter: SearchFilter, filterFacets: [FilterFacet], animated: Bool) {
        if let filterViewModel {
            filterViewModel.updateFilterIfNeeded(searchFilter, facets: filterFacets)
        } else {
            self.filterViewModel = FilterViewModel(facets: filterFacets, searchFilter: searchFilter, searchService: dependencyContainer.searchService)
        }

        filterViewModel?.onFilterApplied
            .sink { [weak self] filter in
                self?.searchViewModel?.applySearchFilters(filter)
                self?.navigationController.dismiss(animated: animated)
            }
            .store(in: &cancellables)
        
        navigationController.present(UIHostingController(rootView: FilterView(viewModel: filterViewModel!)), animated: animated)
    }
}
