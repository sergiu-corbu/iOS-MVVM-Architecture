//
//  ShowsDetailView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 10.04.2023.
//

import SwiftUI
import UIKit

struct ShowsDetailView<ViewModel, DataStore>: View where DataStore: ShowsDataStoreProtocol, ViewModel: ShowsDetailViewModel<DataStore> {
    
    @ObservedObject var viewModel: ViewModel
    let showDetailInteraction: (_ interactionType: ShowDetailInteractionType, _ show: Show?) -> Void
    
    var body: some View {
        GeometryReader { geometryProxy in
            let cellContentBuilder = viewModel.showVideoStreamBuilder
            CollectionView(
                dataSource: viewModel.shows,
                collectionViewLayout: showsFlowLayout(availableSize: geometryProxy.size),
                cellProvider: { show in
                    cellContentBuilder.createShowStreamableDetailView(
                        show, showPresentationType: .caruselView,
                        videoInteractor: viewModel.createVideoInteractor(for: show.id),
                        onShowDetailInteraction: { interactionType in
                            showDetailInteraction(interactionType, show)
                        }
                    )
                }, customizeCollectionView: { collectionView in
                    viewModel.setupCollectionView(collectionView)
                    viewModel.setupTooltipViewModel()
                }, onContextUpdated: {
                    viewModel.scrollToSelectedShow()
                    viewModel.playSelectedVideoStream()
                }
            )
            .background(Color.cultured)
            .overlay(tooltipView)
            .overlayLoadingIndicator(
                viewModel.isLoadingMore, tint: .white, alignment: .bottom,
                inset: EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
            )
            .errorToast(error: $viewModel.error)
        }
        .task {
            await viewModel.setupTooltip()
        }
    }
    
    @ViewBuilder
    private var tooltipView: some View {
        if viewModel.shouldShowTooltip {
            ShowsDetailTooltipOverlay(viewModel: viewModel.tooltipViewModel)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0.1, coordinateSpace: .global).onChanged { _ in
                        viewModel.handleTooltipGestureEnded()
                    }
                )
        }
    }
    
    //MARK: - FlowLayout
    private func showsFlowLayout(availableSize: CGSize) -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = .zero
        flowLayout.itemSize = availableSize
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = .zero
        
        return flowLayout
    }
}

#if DEBUG
struct ShowsDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        ShowsDetailPreviews()
    }
    
    private struct ShowsDetailPreviews: View {
        
        @StateObject var viewModel = ShowsDetailViewModel(selectedShowID: "", showsDataStore: PaginatedShowsDataStore(showService: MockShowService()), showVideoStreamBuilder: .mockedBuilder)
        
        var body: some View {
            ShowsDetailView(viewModel: viewModel, showDetailInteraction: {_, _ in})
                .task {
                    try? await viewModel.showsDataStore.loadInitialContent()
                }
        }
    }
}
#endif
