//
//  LiveStreamPlayerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.03.2023.
//

import SwiftUI

struct LiveStreamPlayerView: View {
    
    @ObservedObject var viewModel: LiveStreamPlayerViewModel
    
    private var show: Show {
        return viewModel.show
    }
    
    var body: some View {
        BaseShowDetailView(viewModel: viewModel, namespaceID: nil, showStreamComposableLayoutView: {
            PassthroughView {
                showStreamView
//                    .signInRestrictionOverlay(
//                        isPresented: viewModel.showAuthenticationRestriction,
//                        onRequestAuthentication: {
//                            viewModel.handleAuthenticationAction(source: .feedSwipe)
//                        }
//                    )
                    .overlay(alignment: .topLeading, content: creatorShowDetailHeaderView)
                    .overlay(alignment: .bottom, content: additionalFooterShowContentView)
            }
            .frame(maxHeight: .infinity)
            .modifier(
                DimmedLiveStreamView(
                    isPresented: viewModel.shouldPresentDimmingInterruptionView,
                    supplementaryView: liveStreamInterruptionsView
                )
            )
            .cornerRadius(8, antialiased: true)
            .animation(.easeInOut, value: show)
            .animation(.easeInOut, value: viewModel.liveStreamStatus)
        }, additionalNavigationBarContent: {
            navigationBarContent
        })
        .alert(Strings.ShowDetail.endLiveShowMessage, isPresented: $viewModel.isCloseLiveStreamAlertPresented) {
            Button(Strings.Buttons.cancel) {
                viewModel.isCloseLiveStreamAlertPresented = false
            }
            Button(Strings.Buttons.endShow) {
                viewModel.closeShowDetail(isLiveStreamEnded: true)
            }
        }
    }
}

//MARK: Views
private extension LiveStreamPlayerView {
        
    //MARK: Header view
    @ViewBuilder func creatorShowDetailHeaderView() -> some View {
        if let creator = show.creator, viewModel.userRole == .audience {
            CreatorShowDetailHeaderView(creator: creator, onSelectCreator: {
                viewModel.onShowDetailInteraction(.creatorSelected(creator))
            })
        }
    }
    
    private var liveStreamView: some View {
        ZStack {
            LiveStreamVideoView(viewProxy: { liveView in
                viewModel.setupLiveStreamView(liveView)
            })
            .videoStreamGradientView(nil)

            Group {
                if viewModel.isConnectingToLiveStream {
                    LiveStreamConnectingView(thumbnailURL: viewModel.userRole == .audience ? show.thumbnailUrl : nil)
                }
                if viewModel.broadcasterIsStartingLiveStream {
                    InterruptionView(message: Strings.ShowDetail.startingLiveStreamMessage)
                }
            }
            .transition(.opacity)
        }
    }
    
    //MARK: Stream view
    @ViewBuilder var showStreamView: some View {
        switch viewModel.userRole {
        case .broadcaster:
            liveStreamView
        case .audience:
            switch show.status {
            case .published:
                VideoPlayerView(videoPlayerService: viewModel.videoPlayerService, show: show)
            case .live, .scheduled:
                ZStack {
                    liveStreamView
                        .opacity(show.status == .scheduled ? 0 : 1)
                    if show.status == .scheduled {
                        VideoPlayerView(videoPlayerService: viewModel.videoPlayerService, show: show)
                            .transition(.asymetricFade(isSource: true))
                    }
                }
            default: EmptyView()
            }
        @unknown default: EmptyView()
        }
    }
    
    //MARK: Additional footer view
    @ViewBuilder func additionalFooterShowContentView() -> some View {
        switch viewModel.userRole {
        case .broadcaster:
            if viewModel.isConnectedToStream {
                FeaturedProductsListView(show: show, interactionsEnabled: false, onSelectProductAction: nil)
                    .padding(.bottom, 16)
            } else if viewModel.showGoLiveButton {
                Buttons.FilledRoundedButton(
                    title: Strings.Buttons.goLive,
                    isEnabled: viewModel.isStartLiveStremButtonEnabled,
                    isLoading: viewModel.broadcasterIsStartingLiveStream,
                    action: viewModel.startLiveStreamShow
                )
            }
        case .audience:
            switch show.status {
            case .scheduled:
                InteractiveVideoPlayerView(show: show, videoPlayerService: viewModel.videoPlayerService, content: {
                    ScheduledShowDetailView(viewModel: viewModel.scheduledShowViewModel)
                })
            case .live:
                if !viewModel.liveStreamDidEnd {
                    FeaturedProductsListView(show: show, onSelectProductAction: {
                        viewModel.onShowDetailInteraction(.productSelected($0))
                    })
                    .padding(.bottom, 16)
                }
            default: EmptyView()
            }
        @unknown default:
            EmptyView()
        }
    }
    
    //MARK: NavigationBar
    var navigationBarContent: some View {
        ZStack {
            if viewModel.showLiveStreamIndicator {
                LiveStreamIndicatorView()
                    .padding(.leading, 16)
                    .transition(.opacity)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            switch viewModel.userRole {
            case .broadcaster:
                switch show.status {
                case .live:
                    LiveStreamElapsedTimeView()
                case .scheduled:
                    if let scheduledDate = show.publishingDate {
                        ShowCountDownTimerView(
                            publishDate: scheduledDate,
                            onCountDownTimerReached: viewModel.handleScheduledShowCountDownTimerFired
                        )
                    }
                default: EmptyView()
                }
            case .audience:
                ScheduledShowTimerView(show: show)
            @unknown default:
                EmptyView()
            }
        }
    }
    
    //MARK: Interruptions view
    @ViewBuilder
    private func liveStreamInterruptionsView() -> some View {
        if viewModel.shouldPresentDimmingInterruptionView {
            switch viewModel.liveStreamStatus  {
            case .broadcasterConnectionLost:
                InterruptionView(message: viewModel.liveStreamStatus?.interruptionDescription ?? "")
            case .liveEnded:
                LiveStreamEndedView(onBackAction: {
                    viewModel.closeShowDetail(isLiveStreamEnded: true)
                })
                .frame(maxHeight: .infinity, alignment: .bottom)
            case .none:
                if !viewModel.isConnectedToInternet {
                    InterruptionView(message: Strings.ShowDetail.noInternetConnection)
                }
            default: EmptyView()
            }
        }
    }
}

fileprivate struct LiveStreamVideoView: UIViewRepresentable {
    
    let viewProxy: (UIView) -> Void

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.contentMode = .scaleAspectFit
        viewProxy(view)
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

#if DEBUG
struct LiveStreamView_Previews: PreviewProvider {

    static var previews: some View {
        LiveStreamPreviews(userRole: .broadcaster)
            .previewDisplayName("Broadcaster")
        LiveStreamPreviews(userRole: .audience)
            .previewDisplayName("Audience")
    }

    private struct LiveStreamPreviews: View {

        @StateObject var viewModel: LiveStreamPlayerViewModel

        init(userRole: VideoStreamUserRole) {
            self._viewModel = StateObject(wrappedValue: LiveStreamPlayerViewModel(show: .liveStream, userRole: userRole, videoInteractor: nil, liveStreamService: MockLiveStreamService(), showService: MockShowService(), deeplinkProvider: MockDeeplinkProvider(), pushNotificationsPermissionHandler: MockPushNotificationsHandler(), onShowDetailInteraction: { _ in }))
        }

        var body: some View {
            LiveStreamPlayerView(viewModel: viewModel)
        }
    }
}
#endif
