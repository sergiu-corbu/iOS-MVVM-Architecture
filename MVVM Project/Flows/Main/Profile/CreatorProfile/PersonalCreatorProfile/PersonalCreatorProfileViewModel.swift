//
//  PersonalCreatorProfileViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.11.2022.
//

import Foundation
import UIKit
import Combine
import AVKit

class PersonalCreatorProfileViewModel: BaseCreatorProfileViewModel {
    
    //MARK: - Properties
    @Published var liveStreamSelectionError: LiveStreamSelectionError?
    let showVideoStreamBuilder: ShowVideoStreamBuilder
    private var isProcessingVideo = false
    
    //MARK: Services
    let userRepository: UserRepository
    let userSession: UserSession
    let uploadService: AWSUploadServiceProtocol
    let pushNotificationsInteractor: PushNotificationsInteractorProtocol?
    let deeplinkProvider: DeeplinkProvider
    let checkoutCartManager: CheckoutCartManager
    lazy private var shareableProvider = ShareableProvider(deeplinkProvider: deeplinkProvider, onPresentShareLink: { [weak self] shareVC in
        self?.presentShareLink(shareVC)
    })
    let videoUploadProgressContainer = VideoUploadProgressContainer()
    
    //MARK: - AssetExporter
    private var mediaAssetExporter: MediaAssetExporting?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    private var cancellables = Set<AnyCancellable>()
    
    init(creator: Creator, userRepository: UserRepository, userSession: UserSession, deeplinkProvider: DeeplinkProvider,
         checkoutCartManager: CheckoutCartManager, creatorService: CreatorServiceProtocol,
         showService: ShowRepositoryProtocol, uploadService: AWSUploadServiceProtocol,
         pushNotificationsInteractor: PushNotificationsInteractorProtocol? = nil, showStreamBuilder: ShowVideoStreamBuilder,
         creatorProfileAction: ProfileActionHandler, showDidPublishSubject: PassthroughSubject<PublishingShow, Never>? = nil) {
        
        self.showVideoStreamBuilder = showStreamBuilder
        self.userRepository = userRepository
        self.userSession = userSession
        self.uploadService = uploadService
        self.pushNotificationsInteractor = pushNotificationsInteractor
        self.deeplinkProvider = deeplinkProvider
        self.checkoutCartManager = checkoutCartManager
        
        super.init(creator: creator, creatorAccessLevel: .readWrite, showService: showService, creatorService: creatorService, creatorProfileAction: creatorProfileAction)
                
        showDidPublishSubject?.receive(on: DispatchQueue.main)
            .sink { [weak self] publishingShow in
                self?.processAndUploadVideo(publishingShow: publishingShow)
            }
            .store(in: &cancellables)
        
        setupCurrentCreatorSubjectNotification()
        setupCreatorPushNotifications()
    }
    
    override var creatorHasImage: Bool {
        return super.creatorHasImage || localProfileImage != nil
    }
    
//    override func handleShowSelection(_ show: Show?, showSelectionHandler: ShowSelectionHandler?) {
//        Task(priority: .userInitiated) { @MainActor in
//            do {
//                self.selectedShow = try await showSelectionHandler?.handleShowSelection(show)
//            } catch {
//                liveStreamSelectionError = error as? LiveStreamSelectionError
//            }
//        }
//    }
    
    func onViewAppeared() {
        analyticsService.trackScreenEvent(.personal_profile, properties: nil)
    }
    
    func handleVideoShowProcessingCompleted(showID: String) {
        selectedSection = .shows
        Task(priority: .userInitiated) { @MainActor in
            await creatorShowsViewModel.loadShows()
            if let publishedShow = creatorShowsViewModel.shows.first(where: { $0.id == showID }) {
                creatorShowsViewModel.presentShowStatusChangedToast(for: publishedShow.status)
            }
        }
    }
    
    func generateProfileShareLink() {
        shareableProvider.generateShareURL(creator.shareableObject)
    }
    
    override func reloadShowsSectionDataIfNeeded() {
        if isProcessingVideo {
            return
        }
        super.reloadShowsSectionDataIfNeeded()
    }
    
    //MARK: Private functionality
    private func setupCurrentCreatorSubjectNotification() {
        userRepository.currentUserSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedCreator in
                if let updatedCreator {
                    self?.creator = updatedCreator
                }
            }.store(in: &cancellables)
    }
    
    private func setupCreatorPushNotifications() {
        pushNotificationsInteractor?.creatorShouldOpenSetupRoom
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scheduledShow in
                self?.selectedSection = .shows
                self?.handleShowSelection(scheduledShow)
            }
            .store(in: &cancellables)
        pushNotificationsInteractor?.creatorShowStatusChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showID in
                self?.handleVideoShowProcessingCompleted(showID: showID)
            }
            .store(in: &cancellables)
    }
}

//MARK: - Video upload
private extension PersonalCreatorProfileViewModel {
    
    func processAndUploadVideo(publishingShow: PublishingShow) {
        let showID = publishingShow.show.id
        selectedSection = .shows
        UIApplication.shared.isIdleTimerDisabled = true
        isProcessingVideo = true
        
        Task(priority: .userInitiated) { @MainActor [weak self] in
            do {
                ToastDisplay.showInformativeToast(
                    title: Strings.ContentCreation.videoCompressionAlertTitle,
                    message: Strings.ContentCreation.videoCompressionAlertMessage
                )
                await self?.creatorShowsViewModel.loadShows(sourceType: .new)
                self?.creatorShowsViewModel.updateCurrentProcessingShowStatus(id: showID, status: .compressingVideo)
                try await self?.handleVideosUpload(showID: showID, videoSections: publishingShow.videoSections)
                try await self?.creatorShowsViewModel.updateShow(showID: showID)
                await self?.productsGridViewModel.reloadProducts()
            } catch {
                self?.error = error
                self?.creatorShowsViewModel.removeShow(showID: showID)
            }
            self?.isProcessingVideo = false
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func handleFallbackVideoUpload(showID: String, videoAsset: AVAsset, uploadScope: UploadScope) async throws {
        guard let assetURL = (videoAsset as? AVURLAsset)?.url else {
            throw MediaError.accessDeniedForMediaFile
        }
        
        do {
            try await uploadVideo(assetFileURL: assetURL, publishingShowID: showID, uploadScope: uploadScope)
        } catch {
            throw MediaError.videoCompressionFailure
        }
    }
    
    func uploadVideo(assetFileURL: URL, publishingShowID: String, uploadScope: UploadScope) async throws {
        let multipart = Multipart(uploadResource: .file(assetFileURL), fileName: "file", uploadScope: uploadScope, owner: publishingShowID)
        
        do {
            await MainActor.run {
                creatorShowsViewModel.updateCurrentProcessingShowStatus(id: publishingShowID, status: .uploadingVideo)
            }
            try await uploadService.uploadData(multipart: multipart, uploadProgress: { [weak self] in
                self?.videoUploadProgressContainer.sendUploadProgress(status: .uploadingVideo, value: $0)
            })
            try mediaAssetExporter?.removeTemporaryAsset(temporaryAssetURL: assetFileURL)
        } catch {
            try mediaAssetExporter?.removeTemporaryAsset(temporaryAssetURL: assetFileURL)
            throw error
        }
    }
    
    func handleVideosUpload(showID: String, videoSections: [VideoSectionType : AVAsset]) async throws {
        self.backgroundTaskID = await UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.backgroundTaskID = .invalid
        }
        
        for (videoSection, videoAsset) in videoSections {
            self.mediaAssetExporter = MediaAssetExporter(asset: videoAsset)

            if let compressedAsset = try? await mediaAssetExporter?.exportMediaAsset(outputFormat: .mp4, exportProgressBlock: { [weak self] in
                self?.videoUploadProgressContainer.sendUploadProgress(status: .compressingVideo, value: $0)
            }) {
                #if DEBUG
                print("Compressed asset size: " + compressedAsset.estimatedFileSizeInMB.description + "MB")
                #endif
                
                await MainActor.run {
                    ToastDisplay.showSuccessToast(
                        title: Strings.ContentCreation.videoCompressionFinalizedAlertTitle,
                        message: Strings.ContentCreation.videoCompressionFinalizedAlertMessage
                    )
                }
                
                try await uploadVideo(assetFileURL: compressedAsset.temporaryURL, publishingShowID: showID, uploadScope: videoSection.videoUploadScope)
            } else {
                try await handleFallbackVideoUpload(showID: showID, videoAsset: videoAsset, uploadScope: videoSection.videoUploadScope)
            }
        }
        await UIApplication.shared.endBackgroundTask(backgroundTaskID)
    }
}

//MARK: - Photo upload
extension PersonalCreatorProfileViewModel {
    
    func handleSelectedImage(_ image: UIImage?) {
        localProfileImage = image
        uploadProfilePicture()
    }
    
    private func uploadProfilePicture() {
        guard let compressedData = localProfileImage?.thumbImageWithMaxPixelSize(UploadImageMaxSize)?
            .jpegData(compressionQuality: JPEGCompressionQuality) else {
            return
        }
        Task(priority: .userInitiated) {
            do {
                let multipart = Multipart(uploadResource: .data(compressedData), fileName: "picture", uploadScope: .profilePicture, owner: nil)
                try await uploadService.uploadData(multipart: multipart, uploadProgress: nil)
                await userRepository.getCurrentUser(loadFromCache: false)
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
}

extension PersonalCreatorProfileViewModel {
    
    enum Action {
        case openSettings
        case openOrders
        case editProfile
        case uploadShow
    }
}

class VideoUploadProgressContainer: ObservableObject {
    
    private(set) var progressPublishers: [ShowStatus: CurrentValueSubject<Int, Never>]
    
    init() {
        self.progressPublishers = [.compressingVideo: CurrentValueSubject(0), .uploadingVideo: CurrentValueSubject(0)]
    }
    
    func sendUploadProgress(status: ShowStatus, value: Double) {
        guard let publisher = progressPublishers[status] else {
            return
        }
        publisher.send(min(value.percentFormatted, 100))
    }
    
    #if DEBUG
    func sendMockUploadProgress() {
        var progress: Double = 0
        _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            for publisher in (self?.progressPublishers ?? [:]) {
                progress += 0.1
                publisher.value.send(Int(progress))
            }
        }
    }
    #endif
}
