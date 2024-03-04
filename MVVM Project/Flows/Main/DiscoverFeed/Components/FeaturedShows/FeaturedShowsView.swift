//
//  FeaturedShowsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.02.2023.
//

import SwiftUI

struct FeaturedShowsView: View {
    
    @ObservedObject var viewModel: FeaturedShowsViewModel<PaginatedShowsDataStore>

    //Internal
    @State private var viewportSize: CGSize = .zero
    private var previewShows: [Show] {
        return viewModel.showsDataStore.previewShows
    }
    private var showsLayoutSize: CGSize {
        return CGSize(width: viewportSize.width, height: (viewportSize.width * 0.6) * 1.8)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Strings.Discover.featuredShows.uppercased())
                .font(kernedFont: .Main.h2BoldKerned)
                .foregroundColor(.jet)
                .padding(.leading, 16)
            showsCarousellView
                .frame(size: showsLayoutSize)
            FeaturedProductsListView(
                currentShowPublisher: viewModel.currentShowChangedPublisher.eraseToAnyPublisher(),
                style: .plain,
                onSelectProductAction: viewModel.actionHandler.onSelectProduct
            )
            .animation(.smooth(duration: 0.25, extraBounce: 0).delay(0.1), value: viewModel.currentDisplayedShow)
        }
        .setViewportLayoutSize($viewportSize)
        .animation(.easeOut(duration: 0.45), value: previewShows)
        .animation(.easeOut(duration: 0.45), value: viewModel.showsDataStore.loadingSourceType)
        .onAppear(perform: viewModel.onViewAppeared)
        .onDisappear(perform: viewModel.onViewDisappeared)
    }
    
    @ViewBuilder private var showsCarousellView: some View {
        let layout = viewModel.showsCompositionalLayout
        if viewModel.shouldDisplayPlaceholderView {
            CollectionView(dataSource: [1,2], collectionViewLayout: layout, cellProvider: { _ in
                Image(.showPlaceholder)
            })
        } else {
            CollectionView(
                dataSource: previewShows, collectionViewLayout: layout,
                cellProvider: { show in
                    createPreviewShowDetailView(show)
                }, customizeCollectionView: { collectionView in
                    viewModel.configureCollectionView(collectionView)
                }, willDisplayItem: { show in
                    viewModel.handleLoadMoreShows(show?.id)
                }
            )
            .overlay(alignment: .trailing, content: pageLoadingIndicator)
        }
    }
    
    @ViewBuilder
    private func pageLoadingIndicator() -> some View {
        if viewModel.showsDataStore.loadingSourceType == .paged {
            ProgressView()
                .tint(.darkGreen)
                .scaleEffect(1.2)
                .padding(.trailing, 16)
        }
    }
    
    func createPreviewShowDetailView(_ show: Show) -> some View {
        let previewShowViewModel = PreviewShowDetailViewModel(
            show: show, videoInteractor: viewModel.createVideoInteractor(for: show.id),
            currentUserPublisher: viewModel.currentUserPublisher,
            onSelectCreator: viewModel.actionHandler.onSelectCreator,
            onSelectBrand: viewModel.actionHandler.onSelectBrand
        )
        return PreviewShowDetailView(viewModel: previewShowViewModel)
            .onTapGesture {
                viewModel.handleShowSelection(show: show)
            }
    }
}

#if DEBUG
#Preview {
    ZStack(alignment: .top) {
        Color.cappuccino.ignoresSafeArea()
        ViewModelPreviewWrapper(FeaturedShowsView.mockedViewModel) { vm in
            FeaturedShowsView(viewModel: vm)
        }
        .padding(.top)
    }
}
#endif
