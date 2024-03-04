//
//  VideoUploadSectionViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.12.2022.
//

import Foundation
import UIKit
import Photos
import Combine

class VideoUploadSectionViewModel: ObservableObject {
    
    //MARK: Properties
    
    private weak var presentationController: UINavigationController?
    
    @Published var previewImagesMap: [VideoSectionType: UIImage] = [:]
    @Published var thumbnailImage: UIImage?
    
    @Published var remoteAssetFetchingSection: VideoSectionType?
    @Published var selectedPreviewVideoSection: VideoSectionType?
    
    @Published private(set) var availableVideoSections: [VideoSectionType]
        
    var didUploadAllSectionVideos: Bool {
        return availableVideoSections.count == videoAssetsMap.count
    }
    
    //MARK: Media Content
    let contentCreationType: ContentCreationType
    private(set) var videoAssetsMap: [VideoSectionType: AVAsset] = [:]
    
    //MARK: Notifications
    var onErrorReceived: ((Error) -> Void)?
    var didUploadPhotoNotification: (() -> Void)?
    
    //MARK: Media Objects
    private lazy var imageSelectionCoordinator: ImageSelectionCoordinator = ImageSelectionCoordinator(navigationController: presentationController)
    private lazy var mediaLoader: MediaLoader = MediaLoader(presentationController: presentationController, selectionLimit: 1, filter: .videos, delegate: self)
    
    private let mediaAssetProvider: MediaAssetProviding
    private var cancellables = Set<AnyCancellable>()
    
    private var mediaAssetProviderTask: Task<Void, Never>?
    
    init(contentCreationType: ContentCreationType, mediaAssetProvider: MediaAssetProviding, presentationController: UINavigationController? = nil) {
        self.contentCreationType = contentCreationType
        self.mediaAssetProvider = mediaAssetProvider
        self.presentationController = presentationController
        
        switch contentCreationType {
        case .liveStream:
            availableVideoSections = [.teaser]
        case .recordedVideo:
            availableVideoSections = [.recorded]
        }
    }
    
    deinit {
        mediaAssetProviderTask?.cancel()
    }
    
    //MARK: Functionality
    func presentImageSelection() {
        imageSelectionCoordinator.onImageLoaded
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onErrorReceived?(error)
                }
        }, receiveValue: { [weak self] selectedImage in
            if selectedImage != nil {
                self?.thumbnailImage = selectedImage
            }
        })
        .store(in: &cancellables)
        resignFirstResponder()
        imageSelectionCoordinator.start(allowsCropping: true)
    }
    
    func presentVideoSelection(for videoSection: VideoSectionType) {
        remoteAssetFetchingSection = videoSection
        mediaAssetProviderTask?.cancel()
        resignFirstResponder()
        mediaLoader.present(accessLevel: .readWrite)
    }
    
    func presentVideoPreview(for videoSection: VideoSectionType) {
        resignFirstResponder()
        selectedPreviewVideoSection = videoSection
    }
    
    private func fetchAndGeneratePreviewImage(_ assetIdentifier: String?) {
        guard let assetIdentifier else {
            remoteAssetFetchingSection = nil
            onErrorReceived?(MediaError.missingMediaFile)
            return
        }
        guard let videoSection = remoteAssetFetchingSection else {
            return
        }
        
        mediaAssetProviderTask = Task(priority: .utility) {
            do {
                let asset = try await mediaAssetProvider.loadAsset(identifier: assetIdentifier, withMaximumDuration: videoSection.maximumAssetDuration)
                videoAssetsMap[videoSection] = asset
                let previewImage = try await mediaAssetProvider.generatePreviewImage(from: asset, previewTimestamp: 1)
                await MainActor.run {
                    previewImagesMap[videoSection] = previewImage
                    didUploadPhotoNotification?()
                    remoteAssetFetchingSection = nil
                }
            } catch {
                await MainActor.run {
                    videoAssetsMap.removeValue(forKey: videoSection)
                    if error is MediaError {
                        switch videoSection {
                        case .recorded:
                            onErrorReceived?(MediaError.videoTooLarge)
                        case .teaser:
                            onErrorReceived?(MediaError.teaserTooLarge)
                        }
                    } else {
                        onErrorReceived?(error)
                    }
                    remoteAssetFetchingSection = nil
                }
            }
        }
    }
    
    func updateTeaserVideoSectionIfNeeded(shouldInsert: Bool) {
        guard contentCreationType == .recordedVideo else {
            return
        }
        availableVideoSections = shouldInsert ? [.recorded, .teaser] : [.recorded]
        
        if !shouldInsert {
            videoAssetsMap.removeValue(forKey: .teaser)
            previewImagesMap.removeValue(forKey: .teaser)
        }
    }
}

extension VideoUploadSectionViewModel: MediaLoaderDelegate {

    func didLoadMediaTypes(_ mediaTypes: [MediaType]) {
        guard case .videoAssetIdentifier(let assetID) = mediaTypes.first else {
            remoteAssetFetchingSection = nil
            return
        }
        fetchAndGeneratePreviewImage(assetID)
    }

    func didReceiveError(_ error: Error) {
        onErrorReceived?(error)
        if let remoteAssetFetchingSection {
            previewImagesMap[remoteAssetFetchingSection] = nil
            self.remoteAssetFetchingSection = nil
        }
    }
    
    func didCancelOperation() {
        remoteAssetFetchingSection = nil
    }
}

extension VideoUploadSectionViewModel {
    
    func setupPresentationController(_ presentationController: UINavigationController?) {
        self.presentationController = presentationController
    }
}
