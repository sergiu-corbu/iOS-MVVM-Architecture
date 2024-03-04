//
//  RecordedVideoView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.03.2023.
//

import SwiftUI

struct RecordedVideoView: View {
    
    @ObservedObject var showDetailViewModel: BaseShowDetailViewModel
    var shouldDisplayReminder: Bool = true
    
    private var show: Show {
        return showDetailViewModel.show
    }
    
    var body: some View {
        BaseShowDetailView(
            viewModel: showDetailViewModel, namespaceID: nil,
            showStreamComposableLayoutView: {
                showStreamView
//                    .signInRestrictionOverlay(
//                        isPresented: showDetailViewModel.showAuthenticationRestriction,
//                        onRequestAuthentication: {
//                            showDetailViewModel.handleAuthenticationAction(source: .feedSwipe)
//                        }
//                    )
                    .overlay(alignment: .topLeading, content: additionalHeaderView)
                    .overlay(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 0) {
                            FavoriteIconWrapperView(favoriteID: show.id, type: .shows, style: .circle)
                                .padding([.trailing], 16)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            additionalFooterShowContentView
                        }
                    }
            }, additionalNavigationBarContent: {
                ScheduledShowTimerView(show: show)
            }
        )
    }
    
    @ViewBuilder private var showStreamView: some View {
        if [.scheduled, .published].contains(show.status) {
            VideoPlayerView(videoPlayerService: showDetailViewModel.videoPlayerService, show: show)
        }
    }
    
    @ViewBuilder private func additionalHeaderView() -> some View {
        if let creator = show.creator {
            CreatorShowDetailHeaderView(creator: creator, onSelectCreator: {
                showDetailViewModel.onShowDetailInteraction(.creatorSelected(creator))
            })
        }
    }
    
    private var additionalFooterShowContentView: some View {
        InteractiveVideoPlayerView(show: show, videoPlayerService: showDetailViewModel.videoPlayerService) {
            switch show.status {
            case .scheduled:
                ScheduledShowDetailView(viewModel: showDetailViewModel.scheduledShowViewModel)
            case .published:
                FeaturedProductsListView(
                    show: show,
                    currentShowPublisher: showDetailViewModel.$show.eraseToAnyPublisher(),
                    onSelectProductAction: {
                        showDetailViewModel.onShowDetailInteraction(.productSelected($0))
                    }
                )
            default: EmptyView()
            }
        }
    }
}

#if DEBUG
#Preview {
    Group {
        RecordedVideoView(showDetailViewModel: BaseShowDetailPreview.baseViewModel(show: .scheduled))
            .previewDisplayName("Scheduled")
        RecordedVideoView(showDetailViewModel: BaseShowDetailPreview.baseViewModel(show: .published))
            .previewDisplayName("Recorded - Published")
    }
    .environmentObject(FollowViewModel.mocked(followType: .user))
    .environmentObject(FavoritesManager.mockedFavoritesManager)
}
#endif
