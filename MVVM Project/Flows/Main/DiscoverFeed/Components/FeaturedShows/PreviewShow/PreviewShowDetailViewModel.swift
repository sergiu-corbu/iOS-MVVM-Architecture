//
//  PreviewShowDetailViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.04.2023.
//

import Foundation
import Combine

class PreviewShowDetailViewModel: ObservableObject {
    
    //MARK: Properties
    let show: Show
    var currentUserID: String?
    let videoPlayerService: PreviewVideoPlayerService
    let videoInteractor: VideoInteractor?

    //MARK: Actions
    let onSelectCreator: (Creator) -> Void
    let onSelectBrand: (Brand) -> Void
    
    private var cancellables = Set<AnyCancellable>()
    
    init(show: Show, videoInteractor: VideoInteractor?,
         currentUserPublisher: AnyPublisher<User?, Never>?,
         onSelectCreator: @escaping (Creator) -> Void, onSelectBrand: @escaping (Brand) -> Void) {
        
        self.show = show
        self.videoPlayerService = PreviewVideoPlayerService(previewVideoURL: show.previewVideoURL)
        self.videoInteractor = videoInteractor
        self.onSelectCreator = onSelectCreator
        self.onSelectBrand = onSelectBrand
        
        self.setupVideoPlayerBindings()
        currentUserPublisher?.sink { [weak self] user in
            self?.currentUserID = user?.id
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
    
    //MARK: - Setup
    private func setupVideoPlayerBindings() {
        videoPlayerService.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
        videoInteractor?.onPlayAction = { [weak self] in
            self?.videoPlayerService.startPlaying()
        }
        videoInteractor?.onPauseAction = { [weak self] in
            self?.videoPlayerService.stopPlaying()
        }
    }
    
    func cellScrolledPastMidVisibleBounds(for frame: CGRect) -> Bool {
        let midX = frame.midX
        let spacing = CGFloat(16)
        let width = frame.size.width + (2 * spacing)
        
        if midX < .zero || midX < width {
            return true
        } else {
            return false
        }
    }
}

#if DEBUG
extension PreviewShowDetailViewModel {
    
    static func preview(show: Show) -> PreviewShowDetailViewModel {
        PreviewShowDetailViewModel(
            show: show, videoInteractor: VideoInteractor(),
            currentUserPublisher: nil, onSelectCreator: {_ in}, onSelectBrand: { _ in}
        )
    }
}
#endif
