//
//  BaseShowDetailViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 31.01.2023.
//

import Foundation
import Combine

enum ShowDetailInteractionType {
    case creatorSelected(Creator)
    case productSelected(ProductSelectableDTO)
    case brandSelected(Brand)
    case shareLinkGenerated(ShareLinkActivityViewController)
    case didUpdateShow(Show)
    case close(_ shouldProcessLiveShowEnded: Bool)
    case onRequestAuthentication(_ source: RegistrationSource, _ completion: () -> Void)
}

typealias ShowDetailInteraction = (ShowDetailInteractionType) -> Void

class BaseShowDetailViewModel: NSObject, ObservableObject {
    
    //MARK: Properties
    @Published private(set) var show: Show
    @Published var isLoading = false
    @Published var showReminderToast = false
    @Published var error: Error?
    let userRole: VideoStreamUserRole
    
    private(set) lazy var scheduledShowViewModel: ScheduledShowDetailViewModel = {
        let scheduledShowVM = ScheduledShowDetailViewModel(
            show: show, pushNotificationsPermissionHandler: pushNotificationsPermissionHandler, showService: showService,
            configureForConsumer: userRole == .audience, scheduledShowActionHandler: { [weak self] action in
                guard let self else { return }
                switch action {
                case .scheduledTimerFinished:
                    Task(priority: .userInitiated) {
                        try? await self.reloadShow()
                    }
                case .selectBrand(let brand):
                    self.onShowDetailInteraction(.brandSelected(brand))
                case .setReminderForShow:
                    self.showReminderToast = true
                }
            }
        )
        scheduledShowVM.onErrorReceived = { [weak self] error in
            self?.error = error
        }
        return scheduledShowVM
    }()
    
    var videoInteractor: VideoInteractor?
    private(set) lazy var videoPlayerService: VideoPlayerService = {
        let videoPlayerService = VideoPlayerService(videoURL: self.recordedVideoURL, autoPlayEnabled: videoInteractor == nil)
        videoPlayerService.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
        
        return videoPlayerService
    }()
    
    final var recordedVideoURL: URL? {
        switch show.status {
        case .published: return show.videoUrl
        case .scheduled: return show.teaserUrl
        default: return nil
        }
    }
    
    //MARK: Private properties
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: Services
    let showService: ShowRepositoryProtocol
    let deeplinkProvider: DeeplinkProvider
    let pushNotificationsPermissionHandler: PushNotificationsPermissionHandler
    let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    lazy private var shareableProvider = ShareableProvider(deeplinkProvider: deeplinkProvider, onPresentShareLink: { [weak self] shareVC in
        self?.onShowDetailInteraction(.shareLinkGenerated(shareVC))
    })
    
    //MARK: Actions
    let onShowDetailInteraction: ShowDetailInteraction
    
    init(_ show: Show, userRole: VideoStreamUserRole = .audience, videoInteractor: VideoInteractor? = nil, showService: ShowRepositoryProtocol, deeplinkProvider: DeeplinkProvider, pushNotificationsPermissionHandler: PushNotificationsPermissionHandler,
         onShowDetailInteraction: @escaping ShowDetailInteraction) {
        
        self.show = show
        self.userRole = userRole
        self.showService = showService
        self.videoInteractor = videoInteractor
        self.deeplinkProvider = deeplinkProvider
        self.pushNotificationsPermissionHandler = pushNotificationsPermissionHandler
        self.onShowDetailInteraction = onShowDetailInteraction
        super.init()
        
        videoInteractor?.onPlayAction = { [weak self] in
            self?.videoPlayerService.startPlaying()
        }
        videoInteractor?.onPauseAction = { [weak self] in
            self?.videoPlayerService.stopPlaying()
        }
    }
    
    //MARK: Show actions
    func incrementShowViewsCountAndGetLatestShow() async {
        do {
            try? await showService.incrementShowCount(id: show.id)
            if let updatedShow = try await showService.getPublicShow(id: show.id) {
                await MainActor.run {
                    self.show = updatedShow
                    if updatedShow.status == .scheduled {
                        scheduledShowViewModel.updateFeaturedBrands(updatedShow.featuredProducts?.map(\.brand))
                    }
                    if updatedShow.status != show.status {
                        onShowDetailInteraction(.didUpdateShow(updatedShow))
                    }
                }
            }
        } catch {
            if error as? CancellationError == nil {
                print(error.localizedDescription)
            }
        }
    }
    
    func handleAuthenticationCompletion() {
        videoPlayerService.setAudioVolume(to: 1)
        objectWillChange.send()
    }
    
    final func handleAuthenticationAction(source: RegistrationSource = .follow) {
        let completion = { [weak self] in
            guard let self else { return }
            self.handleAuthenticationCompletion()
        }
        onShowDetailInteraction(.onRequestAuthentication(source, completion))
    }
    
//    func handleShowSwipeAction(showID: String) {
//        guard showID == show.id else {
//            return
//        }
//        if showsFeedSwipeHandler?.processSwipeToShowAction(id: show.id) == true {
//            videoPlayerService.setAudioVolume(to: .zero)
//        }
//    }
    
    final func updateShow(_ updatedShow: Show) {
        self.show = updatedShow
    }
    
    func handleCloseShowDetailAction(shouldProcessEndedLiveStream: Bool = false) {
        trackShowViewEndEvent()
        onShowDetailInteraction(.close(shouldProcessEndedLiveStream))
    }
    
    @MainActor
    func reloadShow() async throws {
        isLoading = true
        do {
            if let updatedShow = try await showService.getPublicShow(id: show.id) {
                self.show = updatedShow
                onShowDetailInteraction(.didUpdateShow(updatedShow))
            }
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    //MARK: DeepLink
    func generateShareLink() {
        shareableProvider.generateShareURL(show.shareableObject)
    }
}

//MARK: - Analytics
extension BaseShowDetailViewModel {
    
    func trackShowViewEndEvent() {
        analyticsService.trackActionEvent(.show_view_end, properties: showViewEventProperties)
    }
    
    func trackShowViewStartEvent() {
        analyticsService.trackActionEvent(.show_view_start, properties: showViewEventProperties)
    }
    
    private var showViewEventProperties: AnalyticsProperties {
        var properties = show.baseAnalyticsProperties
        if let products = show.featuredProducts {
            properties[.products] = products.map { product in
                Dictionary(uniqueKeysWithValues: product.baseAnalyticsProperties.map { ($0.key.rawValue, $0.value)} )
            }
        }
        
        return properties
    }
}

final class VideoInteractor {
    
    var onPlayAction: (() -> Void)?
    var onPauseAction: (() -> Void)?
    
    func play() {
        onPlayAction?()
    }
    
    func pause() {
         onPauseAction?()
    }
}
