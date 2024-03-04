//
//  LiveStreamPlayerViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.03.2023.
//

import Foundation
import AgoraRtcKit
import UIKit

class LiveStreamPlayerViewModel: BaseShowDetailViewModel {
    
    //MARK: LiveStream properties
    @Published var liveStreamStatus: LiveStreamStatus?
    @Published var isCloseLiveStreamAlertPresented = false
    
    @Published private(set) var isConnectedToStream = false
    @Published var isConnectedToInternet = true
    
    @Published private(set) var creatorCanStartLiveStream: Bool
    
    //MARK: LiveStream properties
    private weak var liveStreamView: UIView?
    private var liveStreamConnectable: (any LiveStreamConnectable)?
    
    var liveStreamDidEnd: Bool {
        return liveStreamStatus == .liveEnded
    }
    var isConnectingToLiveStream: Bool {
        return liveStreamStatus == .connectingToLiveStreamChannel
    }
    var broadcasterIsStartingLiveStream: Bool {
        return liveStreamStatus == .startingLiveStream
    }
    var shouldPresentDimmingInterruptionView: Bool {
        return [.liveEnded, .broadcasterConnectionLost].contains(liveStreamStatus) || !isConnectedToInternet
    }
    var showGoLiveButton: Bool {
        return !isConnectingToLiveStream && liveStreamView != nil
    }
    var showLiveStreamIndicator: Bool {
        return show.status == .live && !shouldPresentDimmingInterruptionView
    }
    var isStartLiveStremButtonEnabled: Bool {
        return !broadcasterIsStartingLiveStream && creatorCanStartLiveStream
    }
    
    //MARK: Services
    let liveStreamService: LiveStreamServiceProtocol
    private let liveStreamManager: LiveStreamManager
    private let networkMonitorHandler = NetworkMonitorHandler()
    
    private var prepareToJoinLiveStreamTask: Task<Void, Never>?
    
    init(show: Show, userRole: VideoStreamUserRole, videoInteractor: VideoInteractor?,
         liveStreamService: LiveStreamServiceProtocol, showService: ShowRepositoryProtocol,
         deeplinkProvider: DeeplinkProvider, pushNotificationsPermissionHandler: PushNotificationsPermissionHandler,
         onShowDetailInteraction: @escaping ShowDetailInteraction) {
        
        self.liveStreamService = liveStreamService
        self.liveStreamManager = LiveStreamManager(userRole: userRole)
        self.creatorCanStartLiveStream = Date.now > (show.publishingDate ?? .now)
        
        super.init(
            show, userRole: userRole,
            videoInteractor: videoInteractor, showService: showService,
            deeplinkProvider: deeplinkProvider, pushNotificationsPermissionHandler: pushNotificationsPermissionHandler,
            onShowDetailInteraction: onShowDetailInteraction
        )
        
        UIApplication.shared.isIdleTimerDisabled = true
        setup()
        setupVideoInteractorActions()
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
        prepareToJoinLiveStreamTask?.cancel()
    }
    
    private func setup() {
        liveStreamManager.setupLiveStreamEngine(delegate: self)
        networkMonitorHandler.start(connectionStatusChanged: { [weak self] isConnectedToInternet in
            self?.isConnectedToInternet = isConnectedToInternet
        })
    }
    
    func setupLiveStreamView(_ view: UIView) {
        guard liveStreamView == nil else {
            return
        }
        liveStreamView = view
        prepareToJoin()
    }
    
    //MARK: Broadcaster actions
    private func prepareBroadcasterPreview() {
        prepareToJoinLiveStreamTask = Task(priority: .userInitiated) { @MainActor in
            do {
                liveStreamStatus = .connectingToLiveStreamChannel
                let liveStreamConnectingData = try await liveStreamService.prepareLiveStream(showID: show.id)
                self.liveStreamConnectable = liveStreamConnectingData
                
                try await liveStreamManager.prepareBroadcasterPreviewCanvas(
                    localStreamView: liveStreamView,
                    liveStreamConnectable: liveStreamConnectingData
                )
            } catch {
                self.error = error
            }
            liveStreamStatus = nil
        }
    }
    
    func startLiveStreamShow() {
        guard userRole == .broadcaster, !isConnectedToStream, let liveStreamConnectable else {
            return
        }
    
        Task(priority: .userInitiated) { @MainActor in
            do {
                liveStreamStatus = .startingLiveStream
                var liveShow = try await liveStreamService.startLiveStream(showID: show.id)
                liveShow.featuredProducts = try await showService.getProductsForShow(showID: show.id)
                try await liveStreamManager.joinChannel(liveStreamConnectable: liveStreamConnectable)
                isConnectedToStream = true
                
                self.updateShow(liveShow)
                onShowDetailInteraction(.didUpdateShow(liveShow))
            } catch {
                self.error = error
            }
            liveStreamStatus = nil
        }
    }
    
    func handleScheduledShowCountDownTimerFired() {
        creatorCanStartLiveStream = true
    }
    
    //MARK: Audience actions
    private func prepareToJoinAsAudience() {
        if liveStreamView == nil, isConnectedToStream {
            return
        }
        
        prepareToJoinLiveStreamTask = Task(priority: .userInitiated) { @MainActor in
            do {
                liveStreamStatus = .connectingToLiveStreamChannel
                await Task.sleep(seconds: 0.5) // used for a smooth user experience - nice to have
                try await liveStreamManager.joinChannel(
                    liveStreamConnectable: try await liveStreamService.getAudienceLiveStreamToken(showID: show.id)
                )
                isConnectedToStream = true
            } catch {
                self.error = error
            }
            liveStreamStatus = nil
        }
    }
    
    func handleScheduledLiveShowStarted() {
        guard userRole == .audience, show.status == .scheduled else {
            return
        }
        
        Task(priority: .userInitiated) { @MainActor in
            do {
                try await self.reloadShow()
            } catch {
                self.error = error
            }
        }
    }
    
    //MARK: Common actions
    private func prepareToJoin() {
        if isConnectedToStream {
            return
        }
        
        switch userRole {
        case .broadcaster:
            prepareBroadcasterPreview()
        case .audience:
            prepareToJoinAsAudience()
        @unknown default:
            break
        }
    }
    
//    override func handleShowSwipeAction(showID: String) {
//        super.handleShowSwipeAction(showID: showID)
//        if super.showsFeedSwipeHandler?.showAuthenticationRestriction == true {
//            liveStreamManager.setAudioVolume(to: .zero)
//        }
//    }
    
    override func handleAuthenticationCompletion() {
        super.handleAuthenticationCompletion()
        liveStreamManager.setAudioVolume(to: 1)
    }
    
    override func handleCloseShowDetailAction(shouldProcessEndedLiveStream: Bool) {
        if userRole == .broadcaster, isCloseLiveStreamAlertPresented == false, isConnectedToStream {
            isCloseLiveStreamAlertPresented = true
            return
        }
        closeShowDetail(isLiveStreamEnded: shouldProcessEndedLiveStream)
    }
    
    func closeShowDetail(isLiveStreamEnded: Bool) {
        Task(priority: .userInitiated) { @MainActor in
            await leaveChannel()
            super.handleCloseShowDetailAction(shouldProcessEndedLiveStream: isLiveStreamEnded)
        }
    }
    
    private func leaveChannel() async {
        if show.status == .live, userRole == .broadcaster {
            try? await liveStreamService.endLiveStream(showID: show.id)
        }
        
        liveStreamManager.leaveChannel()
        await MainActor.run {
            isConnectedToStream = false
        }
    }
    
    override func incrementShowViewsCountAndGetLatestShow() async {
        guard userRole == .audience else {
            return
        }
        await super.incrementShowViewsCountAndGetLatestShow()
    }
    
    private func setupVideoInteractorActions() {
        let onPlayAction = videoInteractor?.onPlayAction
        let onPauseAction = videoInteractor?.onPauseAction
        
        videoInteractor?.onPlayAction = { [weak self] in
            if self?.show.status == .live {
                self?.prepareToJoin()
            } else {
                onPlayAction?()
            }
        }
        
        videoInteractor?.onPauseAction = { [weak self] in
            guard let self else { return }
            if self.show.status == .live {
                Task(priority: .userInitiated) {
                    await self.leaveChannel()
                }
            } else {
                onPauseAction?()
            }
        }
    }
}

extension LiveStreamPlayerViewModel: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid : UInt, elapsed: Int) {
        liveStreamManager.setupVideoCanvas(in: liveStreamView, uid: didJoinedOfUid)
        liveStreamStatus = nil
        
        if userRole == .audience {
            handleScheduledLiveShowStarted()
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        guard userRole == .audience else {
            return
        }
        
        switch reason {
        case .dropped:
            liveStreamStatus = .broadcasterConnectionLost
        case .quit:
            liveStreamStatus = .liveEnded
        default: break
        }
    }

    func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        print("Did lost connection")
    }

    func rtcEngineVideoDidStop(_ engine: AgoraRtcEngineKit) {
        print("Video did stop")
    }
    
    func rtcEngineConnectionDidInterrupted(_ engine: AgoraRtcEngineKit) {
        print("did interrupt")
    }

    //MARK: Helpers
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("LiveStream warning: \(warningCode.rawValue)")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("LiveStream error: \(errorCode.description)")
    }
}

extension LiveStreamPlayerViewModel {
    
    enum LiveStreamStatus: Int {
        
        case broadcasterConnectionLost
        case liveEnded
        case startingLiveStream
        case connectingToLiveStreamChannel
        
        var interruptionDescription: String {
            guard case .broadcasterConnectionLost = self else {
                return ""
            }
            return Strings.ShowDetail.broadcasterConnectionLostMessage
        }
    }
}
