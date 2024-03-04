//
//  ShowVideoStreamBuilder.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.03.2023.
//

import Foundation
import SwiftUI

struct ShowVideoStreamBuilder {
    
    //MARK: Services
    let showRepository: ShowRepository
    let liveStreamService: LiveStreamServiceProtocol
    let deeplinkProvider: DeeplinkProvider
    let permissionsProvider = MediaPermissionsHandler()
    let pushNotificationsHandler: PushNotificationsPermissionHandler
    let followService: FollowServiceProtocol
    let userRepository: UserRepository
    let favoritesManager: FavoritesManager
    
    enum ShowPresentationType {
        case singleView
        case caruselView
    }
    
    init(showRepository: ShowRepository, liveStreamService: LiveStreamServiceProtocol, deeplinkProvider: DeeplinkProvider,
         userRepository: UserRepository, pushNotificationsHandler: PushNotificationsPermissionHandler,
         followService: FollowServiceProtocol, favoritesManager: FavoritesManager) {
        
        self.showRepository = showRepository
        self.liveStreamService = liveStreamService
        self.deeplinkProvider = deeplinkProvider
        self.userRepository = userRepository
        self.followService = followService
        self.favoritesManager = favoritesManager
        self.pushNotificationsHandler = pushNotificationsHandler
    }
    
    private var currentUserID: String? {
        return userRepository.currentUserSubject.value?.id
    }
    
    @ViewBuilder func createShowStreamableDetailView(
        _ show: Show, showPresentationType: ShowPresentationType,
        videoInteractor: VideoInteractor? = nil,
        onShowDetailInteraction: @escaping ShowDetailInteraction
    ) -> some View {
        
        let isBroadcaster = show.creatorID == currentUserID
        let userRole: VideoStreamUserRole = isBroadcaster ? .broadcaster : .audience
        let followViewModel = FollowViewModel(
            followingID: show.creatorID, followType: .user,
            userRepository: userRepository, followService: followService,
            pushNotificationsPermissionHandler: pushNotificationsHandler,
            onRequestAuthentication: { completion in
                onShowDetailInteraction(.onRequestAuthentication(.follow, completion))
            }
        )
        
        if show.shouldBeUsedInLiveStream {
            let liveStreamPlayerViewModel = LiveStreamPlayerViewModel(
                show: show, userRole: userRole, videoInteractor: videoInteractor, liveStreamService: liveStreamService,
                showService: showRepository, deeplinkProvider: deeplinkProvider,
                pushNotificationsPermissionHandler: pushNotificationsHandler,
                onShowDetailInteraction: onShowDetailInteraction
            )
            
            if showPresentationType == .singleView {
                let _ = liveStreamPlayerViewModel.trackShowViewStartEvent()
            }
            
            LiveStreamPlayerView(viewModel: liveStreamPlayerViewModel)
                .environmentObject(followViewModel)
        } else {
            let baseShowDetailViewModel = BaseShowDetailViewModel(
                show, userRole: userRole, videoInteractor: videoInteractor, showService: showRepository,
                deeplinkProvider: deeplinkProvider,
                pushNotificationsPermissionHandler: pushNotificationsHandler,
                onShowDetailInteraction: onShowDetailInteraction
            )
            
            if showPresentationType == .singleView {
                let _ = baseShowDetailViewModel.trackShowViewStartEvent()
            }
            
            RecordedVideoView(showDetailViewModel: baseShowDetailViewModel, shouldDisplayReminder: !isBroadcaster)
                .environmentObject(followViewModel)
                .environmentObject(favoritesManager)
        }
    }
}

extension ShowVideoStreamBuilder: ShowSelectionHandler {
    
    var minimumRemainingMinutesToLiveStream: Int {
        return 30
    }
    
    var broadcasterMediaPermissionsGranted: Bool {
        get async {
            return await permissionsProvider.checkForAudioVideoPermissions()
        }
    }
    
    func shouldAskForMediaPermissions(show: Show) -> Bool {
        return show.type == .liveStream && currentUserID == show.creatorID
    }
    
    func isCreatorSetupRoomAvailable(show: Show) -> Bool {
        guard let publishDate = show.publishingDate else {
            return false
        }
        
        guard show.status == .scheduled else {
            return true
        }
        
        guard let remainingMinutes = publishDate.minutesFromCurrentDate else {
            return false
        }
        
        return remainingMinutes <= minimumRemainingMinutesToLiveStream
    }
}

protocol ShowSelectionHandler {
    
    var minimumRemainingMinutesToLiveStream: Int { get }
    
    @MainActor
    var broadcasterMediaPermissionsGranted: Bool { get async }
    
    func shouldAskForMediaPermissions(show: Show) -> Bool
    
    func isCreatorSetupRoomAvailable(show: Show) -> Bool
}

extension ShowSelectionHandler {
    
    func handleShowSelection(_ show: Show?) async throws -> Show? {
        guard let show, shouldAskForMediaPermissions(show: show) else {
            return show
        }
        
        if isCreatorSetupRoomAvailable(show: show) == false {
            throw LiveStreamSelectionError.setupRoomNotAvailable
        }
        
        if await broadcasterMediaPermissionsGranted {
            return show
        } else {
            throw LiveStreamSelectionError.mediaPermissionsNotGranted
        }
    }
}

#if DEBUG
extension ShowVideoStreamBuilder {
    
    static var mockedBuilder: Self {
        ShowVideoStreamBuilder(
            showRepository: ShowRepository(showSevice: MockShowService(), favoritesManager: .mockedFavoritesManager),
            liveStreamService: MockLiveStreamService(),
            deeplinkProvider: MockDeeplinkProvider(),
            userRepository: MockUserRepository(),
            pushNotificationsHandler: MockPushNotificationsHandler(),
            followService: MockFollowService(),
            favoritesManager: .mockedFavoritesManager
        )
    }
}
#endif
