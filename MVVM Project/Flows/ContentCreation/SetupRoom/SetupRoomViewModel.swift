//
//  SetupRoomViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.12.2022.
//

import Foundation
import Combine
import UIKit

class SetupRoomViewModel: ObservableObject {
    
    //MARK: ShowProperties
    @Published var showTitle: String = ""
    @Published var publishTime: ShowPublishTime
    @Published var showPublishTimePicker = false {
        didSet {
            resignFirstResponder()
            if !showPublishTimePicker, laterPublishDate == nil, contentCreationType == .recordedVideo {
                publishTime = .now
            }
        }
    }
    private(set) var laterPublishDate: Date?
    private var draftShow: Show?
    let selectedProductsForCollaboration: Set<Product>
    
    let contentCreationType: ContentCreationType
    
    //MARK: HelperStates
    @Published private(set) var loadingScope: LoadingScope? = .draftShowLoading
    @Published var error: Error?
    
    let videoUploadSectionViewModel: VideoUploadSectionViewModel
    
    //MARK: Actions
    let onBack = PassthroughSubject<Void, Never>()
    let onCancel = PassthroughSubject<Void, Never>()
    let onShowPublished = PassthroughSubject<Show, Never>()
    
    //MARK: Services
    let contentCreationService: ContentCreationServiceProtocol
    let uploadService: AWSUploadServiceProtocol
    let mediaAssetProvider = MediaAssetProvider()
    
    private var publishContentTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    var customSegmentsLabel: SegmentTexts? {
        guard let laterPublishDate else {
            if case .liveStream = contentCreationType {
                return [ShowPublishTime.later.hashValue : Strings.Buttons.schedule] 
            }
            return nil
        }
        return [ShowPublishTime.later.hashValue: laterPublishDate.dateString(formatType: .compactDateAndTime)]
    }
    var publishButtonEnabled: Bool {
        let didSetVideoAndTitle = videoUploadSectionViewModel.didUploadAllSectionVideos && !showTitle.isEmpty
        if case .liveStream = contentCreationType {
            return didSetVideoAndTitle && laterPublishDate != nil
        }
        return didSetVideoAndTitle
    }
    private lazy var showPublishDate: Date = {
        switch publishTime {
        case .now: return Date.now
        case .later: return laterPublishDate ?? Date.now
        }
    }()
    
    let publishButtonStringLabel: String
    
    init(selectedProductsForCollaboration: Set<Product>,
         contentCreationType: ContentCreationType,
         contentCreationService: ContentCreationServiceProtocol,
         uploadService: AWSUploadServiceProtocol) {
        
        self.selectedProductsForCollaboration = selectedProductsForCollaboration
        self.contentCreationType = contentCreationType
        self.contentCreationService = contentCreationService
        self.uploadService = uploadService
        
        switch contentCreationType {
        case .liveStream:
            publishButtonStringLabel = Strings.Buttons.setupLiveShow
            publishTime = .later
        case .recordedVideo:
            publishButtonStringLabel = Strings.Buttons.publish
            publishTime = .now
        }
        
        videoUploadSectionViewModel = VideoUploadSectionViewModel(contentCreationType: contentCreationType, mediaAssetProvider: mediaAssetProvider)
        videoUploadSectionViewModel.didUploadPhotoNotification = objectWillChange.send
        videoUploadSectionViewModel.onErrorReceived = { [weak self] error in
            self?.error = error
        }
        getDraftShow()
    }
    
    deinit {
        publishContentTask?.cancel()
    }
    
    func saveLaterPublishDate(_ publishDate: Date) {
        laterPublishDate = publishDate
        showPublishTimePicker = false
        videoUploadSectionViewModel.updateTeaserVideoSectionIfNeeded(shouldInsert: true)
    }
    
    private func getDraftShow() {
        Task(priority: .userInitiated) { @MainActor in
            do {
                loadingScope = .draftShowLoading
                self.draftShow = try await contentCreationService.createDraftShow(
                    productIds: Set(selectedProductsForCollaboration.map(\.id)),
                    contentType: contentCreationType
                )
            } catch {
                self.error = error
            }
            loadingScope = nil
        }
    }
    
    //MARK: - ContentPublishing
    func publishContent() {
        guard let draftShow else {
            return
        }
        resignFirstResponder() //TODO: use focus changed instead of this
        loadingScope = .showUploading
        publishContentTask = Task(priority: .userInitiated) {
            do {
                let thumbnailVideoSection: VideoSectionType
                switch contentCreationType {
                case .liveStream: thumbnailVideoSection = .teaser
                case .recordedVideo: thumbnailVideoSection = .recorded
                }
                try await uploadThumbnailImage(draftShowId: draftShow.id, videoSection: thumbnailVideoSection)
                let uploadedShow = try await contentCreationService.completeDraftShow(
                    showId: draftShow.id,
                    title: showTitle,
                    publishingDate: showPublishDate
                )
                
                await MainActor.run {
                    contentCreationService.showDidPublishSubject.send(PublishingShow(uploadedShow, videoUploadSectionViewModel.videoAssetsMap))
                    onShowPublished.send(uploadedShow)
                    loadingScope = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    loadingScope = nil
                }
            }
        }
    }
    
    private func uploadThumbnailImage(draftShowId: String, videoSection: VideoSectionType) async throws {
        let thumbnailImage = videoUploadSectionViewModel.thumbnailImage ?? videoUploadSectionViewModel.previewImagesMap[videoSection]
        guard let compressedImage = thumbnailImage?.thumbImageWithMaxPixelSize(UploadImageMaxSize)?
            .jpegData(compressionQuality: JPEGCompressionQuality) else {
            return
        }
        
        let multipart = Multipart(uploadResource: .data(compressedImage),
                                  fileName: "picture",
                                  uploadScope: .thumbnailShow,
                                  owner: draftShowId)
        
        try await uploadService.uploadData(multipart: multipart, uploadProgress: nil)
    }
}

extension SetupRoomViewModel {
    
    enum LoadingScope: Int {
        case assetLoading = 0
        case draftShowLoading
        case showUploading
    }
}
