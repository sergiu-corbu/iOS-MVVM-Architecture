//
//  FilterView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 23.08.2023.
//

import SwiftUI

struct FilterView: View {
    
    @ObservedObject var viewModel: FilterViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            GrabberView()
            ScrollView {
                VStack(spacing: 48) {
                    filterSectionView
                    SortingContainerView(selectedSortingType: $viewModel.selectedPriceSortingType)
                }
                .disabled(viewModel.loadingSectionType != nil)
                .padding(.top, 8)
            }
            filterButtonsStackView
        }
        .background(Color.cultured.opacity(0.9))
    }
    
    private var filterSectionView: some View {
        VStack(spacing: 16) {
            Text(Strings.FilterAndSort.filterBy)
                .textStyle(.outlinedHeader())
                .padding(.bottom, 4)
            ForEach(viewModel.filterFacets, id: \.filterType.rawValue) { filterFacet in
                FilterSectionContainerView(
                    filterFacet: filterFacet,
                    selectedFilterSection: $viewModel.selectedFilterSection,
                    selectedItems: Binding(get: {
                        viewModel.selectedFilterFacetsMap[filterFacet.filterType] ?? .init()
                    }, set: {
                        viewModel.updateFiltersSelection(values: $0)
                    }),
                    isLoading: viewModel.loadingSectionType == filterFacet.filterType
                )
            }
        }
    }
    
    private var filterButtonsStackView: some View {
        HStack(spacing: 0) {
            if viewModel.isResetFiltersActionEnabled {
                Buttons.FillBorderedButton(
                    title: Strings.Buttons.resetFilters,
                    fillColor: .battleshipGray, textColor: .jet,
                    action: viewModel.resetFiltersAction
                )
                .padding([.leading, .bottom], 16)
            }
            Buttons.FilledRoundedButton(title: Strings.Buttons.applyFilters, action: viewModel.applyFiltersAction)
        }
        .disabled(viewModel.loadingSectionType != nil)
    }
}

#if DEBUG
struct FilterView_Previews: PreviewProvider {
    
    static var previews: some View {
        let viewModel = FilterViewModel(facets: FilterFacet.mockedFacets, searchFilter: SearchFilter(query: "", searchTag: .products, currentPage: 1, pageSize: 20), searchService: MockSearchService())
        ViewModelPreviewWrapper(viewModel) { vm in
            FilterView(viewModel: vm)
        }
    }
}
#endif
