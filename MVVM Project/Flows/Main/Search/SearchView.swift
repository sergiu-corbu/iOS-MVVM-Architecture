//
//  SearchView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import SwiftUI

struct SearchView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    @State private var contentSize: CGSize = .zero
    private let sectionHeaderID = "sectionHeaderID"
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ScrollViewReader { scrollProxy in
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    Section(content: {
                        contentView
                    }, header: {
                        sectionHeader
                    })
                }
                .onReceive(viewModel.contentScrollViewOffsetResetPublisher) { _ in
                    scrollProxy.scrollTo(sectionHeaderID, anchor: .top)
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .setViewportLayoutSize($contentSize)
        .primaryBackground()
        .minimizedCartViewOverlay(
            cartManager: viewModel.checkoutCartManager,
            onPresentCart: { viewModel.searchActionHandler(.checkoutCart) }
        )
        .safeAreaOverlay {
            Color.cultured
        }
        .overlayLoadingIndicator(viewModel.justDroppedProductsDataStore.loadingType == .new)
        .refreshable {
            await Task {
                viewModel.handleRefreshAction()
            }.value
            
        }
        .onAppear(perform: viewModel.trackSearchTabSelection)
    }
    
    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text(Strings.NavigationTitles.search).font(.Main.h2Italic)
                if viewModel.searchState.isSearching {
                   searchLoadingIndicator
                }
                Spacer()
                if viewModel.isFilterActionEnabled {
                    FilterButtonView(
                        action: viewModel.handleFilterSelection,
                        filtersCountPublisher: viewModel.activeFiltersCountPublisher
                    )
                }
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
            .animation(.easeInOut, value: viewModel.searchState.isSearching)
            SearchBarView(viewModel: viewModel.searchBarViewModel)
            if viewModel.searchState.shouldDisplayTagsSelector {
                SearchCategoriesSelectorView(
                    selectedSearchTag: Binding(
                        get: { return viewModel.selectedSearchTag },
                        set: { viewModel.searchTagSelectedAction($0) }
                    ), searchTags: viewModel.searchTags
                )
                .padding(.bottom, 8)
            }
        }
        .background(Color.cultured)
        .id(sectionHeaderID)
    }

    @ViewBuilder private var contentView: some View {
        switch viewModel.searchState {
        case .inactive: justDroppedProductsGridView
        case .finishedSearching(let noResults):
            if noResults { emptyView(.noResults) }
            else { searchResultsView }
        case .idle: emptyView(.idle)
        case .searching: EmptyView() ///NOTE:  handled in sectionHeader
        }
    }

    private func emptyView(_ state: SearchEmptyView.State) -> some View {
        SearchEmptyView(state: state)
            .padding(EdgeInsets(top: 64, leading: 52, bottom: 0, trailing: 52))
    }

    private var searchResultsView: some View {
        SearchResultsContainerView(viewModel: viewModel.searchResultsViewModel)
            .padding(.top, 8)
    }
    
    private var searchLoadingIndicator: some View {
        ProgressView()
            .tint(.darkGreen)
            .scaleEffect(0.9)
            .offset(y: 1)
            .transition(.opacity.combined(with: .scale))
    }

    private var justDroppedProductsGridView: some View {
        let viewportSize = CGSize(width: contentSize.width - 32, height: contentSize.height)
        let products = viewModel.justDroppedProductsDataStore.products
        return PinterestGridView(gridItems: products, viewportSize: viewportSize, cellContent: { product in
            Button {
                viewModel.searchActionHandler(.product(product))
            } label: {
                ProductView(product: product, viewportSize: viewportSize)
            }.buttonStyle(.scaled)
        }, onReachedLastPage: { _ in
            viewModel.loadMoreProductsIfNeeded()
        })
        .padding(16)
        .overlayLoadingIndicator(viewModel.justDroppedProductsDataStore.loadingType == .paged, scale: 0.9, alignment: .bottom)
    }
}

#if DEBUG
#Preview {
    ViewModelPreviewWrapper(SearchViewModel.previewVM) { vm in
        return SearchView(viewModel: vm)
    }
}
#endif
