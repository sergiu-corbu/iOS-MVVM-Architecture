//
//  FilterViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 23.08.2023.
//

import Foundation
import Combine

class FilterViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var selectedPriceSortingType: PriceSortingType?
    @Published var selectedFilterSection: FilterSectionType?
    @Published var selectedFilterFacetsMap: [FilterSectionType : Set<FilterFacet.FacetValue>] = [:]
    @Published private(set) var filterFacets: [FilterFacet]
    
    @Published var loadingSectionType: FilterSectionType?
    @Published var error: Error?
    
    private(set) var isResetFiltersActionEnabled = false
    private(set) var searchFilter: SearchFilter
    private let initialFilterFacets: [FilterFacet]
    
    let onFilterApplied = PassthroughSubject<SearchFilter, Never>()
    private let facetValuesSelectedPublisher = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?
    private var searchTask: Task<Void, Never>?
    
    //MARK: - Services
    let searchService: SearchServiceProtocol
    
    init(facets: [FilterFacet], searchFilter: SearchFilter, searchService: SearchServiceProtocol) {
        self.searchService = searchService
        self.searchFilter = searchFilter
        let processedFilterFacets = Self.processFilterFacets(facets)
        self.filterFacets = processedFilterFacets
        self.initialFilterFacets = processedFilterFacets
        
        cancellable = facetValuesSelectedPublisher.receive(on: DispatchQueue.main)
            .debounce(for: .seconds(0.75), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.applyFacetsAndSorting()
            }
    }
    
    //MARK: - Setup
    class func processFilterFacets(_ facets: [FilterFacet]?) -> [FilterFacet] {
        guard var facets else {
            return []
        }

        for (index, _) in facets.enumerated() {
            facets[index].values.removeAll(where: { $0.count < 1})
        }
        return facets
    }
    
    func updateFilterIfNeeded(_ filter: SearchFilter, facets: [FilterFacet]) {
        guard filter.query != self.searchFilter.query else {
            return
        }
        
        self.searchFilter = filter
        self.filterFacets = Self.processFilterFacets(facets)
        self.selectedFilterFacetsMap = [:]
        self.selectedFilterSection = nil
    }
    
    //MARK: - Actions
    func applyFiltersAction() {
        isResetFiltersActionEnabled = true
        searchFilter.applyFiltersAndSorting(facets: selectedFilterFacetsMap, sorting: selectedPriceSortingType)
        onFilterApplied.send(searchFilter)
    }
    
    func updateFiltersSelection(values: Set<FilterFacet.FacetValue>) {
        guard let selectedFilterSection else {
            return
        }
        
        selectedFilterFacetsMap[selectedFilterSection] = values
        facetValuesSelectedPublisher.send()
    }
    
    func applyFacetsAndSorting() {
        guard let selectedFilterSection, let selectedValues = selectedFilterFacetsMap[selectedFilterSection] else {
            return
        }
        
        loadingSectionType = selectedFilterSection
        searchTask?.cancel()
        searchTask = Task(priority: .userInitiated) { @MainActor in
            do {
                searchFilter.applyFiltersAndSorting(facets: [selectedFilterSection: selectedValues], sorting: selectedPriceSortingType)
                let searchResult = try await searchService.search(filter: searchFilter)
                updateFilterFacets(with: Self.processFilterFacets(searchResult.facets))
            } catch {
                self.error = error
            }
            loadingSectionType = nil
        }
    }
    
    func resetFiltersAction() {
        guard isResetFiltersActionEnabled else {
            return
        }
        selectedPriceSortingType = nil
        selectedFilterSection = nil
        loadingSectionType = nil
        selectedFilterFacetsMap = [:]
        searchFilter.resetFiltersAndSorting()
        filterFacets = initialFilterFacets
    }
    
    private func updateFilterFacets(with updatedFacets: [FilterFacet]) {
        filterFacets.enumerated().forEach { iterator in
            let element = iterator.element
            let index = iterator.offset
            if element.filterType == selectedFilterSection {
                return
            }
            
            filterFacets[index].values = updatedFacets[index].values
            guard var currentSelectedValues = selectedFilterFacetsMap[element.filterType] else {
                return
            }
            
            for currentSelectedValue in currentSelectedValues {
                currentSelectedValues.remove(currentSelectedValue)
                if let updatedValue = filterFacets[index].values.first(where: {$0.value == currentSelectedValue.value }) {
                    currentSelectedValues.insert(updatedValue)
                }
            }
            
            selectedFilterFacetsMap[element.filterType] = currentSelectedValues
        }
    }
}
