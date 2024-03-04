//
//  FavoritesListView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.09.2023.
//

import SwiftUI

struct FavoritesListView: View {
    
    @ObservedObject var viewModel: FavoritesListViewModel
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            contentView
                .refreshable {
                    viewModel.loadInitialContent(forceRefresh: true)
                }
        }
        .primaryBackground()
        .errorToast(error: $viewModel.error)
    }
    
    private var headerView: some View {
        SelectableHeaderSectionView(
            selectedSection: Binding(get: {
                return viewModel.selectedFavoriteType.id
            }, set: { newValue in
                viewModel.updateSelectedSection(favoriteRawValue: newValue)
            }), sections: [
                SectionItem(favoriteType: .shows, count: viewModel.favoriteCounts.shows),
                SectionItem(favoriteType: .products, count: viewModel.favoriteCounts.products)
            ], sectionTitle: Strings.NavigationTitles.favorites, onBack: {
                viewModel.favoritesListActionHandler(.back)
            }
        )
        .padding(.bottom, 8)
    }

    @ViewBuilder private var contentView: some View {
        switch viewModel.selectedFavoriteType {
        case .shows:
            let favoriteShows = viewModel.showsDataStore.items
            let showsGridContent = ForEach(favoriteShows.indexEnumeratedArray, id: \.offset) { (index, show) in
                Button {
                    viewModel.favoritesListActionHandler(.selectShow(show))
                } label: {
                    ProfileComponents.ShowCardView(show: show, profileType: .user)
                }
                .buttonStyle(.plain)
                .task(priority: .userInitiated) {
                    await viewModel.handleLoadMore(for: show)
                }
            }
            FavoriteListContainerView(favoriteItems: favoriteShows, favoriteType: .shows) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 2), spacing: 16) {
                    showsGridContent
                }
            }
            .overlayLoadingIndicator(!viewModel.showsDataStore.didLoadFirstPage, scale: 1, shouldDisableInteraction: false)
            .environment(\.isLoading, viewModel.showsDataStore.loadingSourceType == .new)
            .task(priority: .userInitiated) {
                viewModel.loadInitialContent()
            }
        case .products:
            let favoriteProducts = viewModel.productsDataStore.items
            FavoriteListContainerView(favoriteItems: favoriteProducts, favoriteType: .products) {
                let viewportSize = CGSize(width: contentSize.width - 32, height: contentSize.height)
                PinterestGridView(gridItems: favoriteProducts, viewportSize: viewportSize, cellContent: { product in
                    Button {
                        viewModel.favoritesListActionHandler(.selectProduct(product))
                    } label: {
                        ProductView(product: product, viewportSize: viewportSize)
                    }
                    .buttonStyle(.plain)
                }, onReachedLastPage: { lastItem in
                    Task(priority: .userInitiated) {
                        await viewModel.handleLoadMore(for: lastItem)
                    }
                })
            }
            .setViewportLayoutSize($contentSize)
            .overlayLoadingIndicator(!viewModel.productsDataStore.didLoadFirstPage, scale: 1, shouldDisableInteraction: false)
            .environment(\.isLoading, viewModel.productsDataStore.loadingSourceType == .new)
            .task(priority: .userInitiated) {
                viewModel.loadInitialContent()
            }
        }
    }
    
    struct FavoriteListContainerView<Item: Hashable, Content: View>: View {
        
        let favoriteItems: [Item]
        let favoriteType: FavoriteType
        @ViewBuilder let content: () -> Content
        @Environment(\.isLoading) var isLoading: Bool

        var body: some View {
            let contentView = Group {
                if favoriteItems.isEmpty {
                    SectionedListPlaceholderView(message: favoriteType.placeholderMessage, image: favoriteType.placeholderImage)
                } else {
                    ScrollView(.vertical, showsIndicators: true) {
                        content()
                            .padding(16)
                    }
                }
            }
            .transition(.opacity.animation(.easeInOut))

            if isLoading {
                Color.clear
            } else {
                contentView
            }
        }
    }
}

fileprivate extension FavoritesListView {
    struct SectionItem: HeaderSectionCountable {
        let id: String
        let sectionTitle: String
        let count: Int
        
        init(favoriteType: FavoriteType, count: Int) {
            self.id = favoriteType.rawValue
            self.sectionTitle = favoriteType.sectionTitle.uppercased()
            self.count = count
        }
    }
}

#if DEBUG
struct FavoritesListView_Previews: PreviewProvider {
    
    static var previews: some View {
        FavoritesListView(viewModel: .init(userID: "", favoritesService: MockFavoritesService(), favoritesManager: FavoritesManager.mockedFavoritesManager, favoritesListActionHandler: { _ in}))
    }
}
#endif
