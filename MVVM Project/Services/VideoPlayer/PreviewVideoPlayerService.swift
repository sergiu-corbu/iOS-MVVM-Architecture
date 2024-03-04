//
//  PreviewVideoPlayer.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 12.04.2023.
//

import Foundation
import AVKit

class PreviewVideoPlayerService: VideoPlayerService {
    
    private var didConfigure = false
    
    init(previewVideoURL: URL?, previewConfiguration: any VideoPlayable = PreviewVideoPlayerConfiguration()) {
        var previewVideoPlayer: AVPlayer? = nil
        if let previewVideoURL {
            previewVideoPlayer = AVPlayer(url: previewVideoURL)
            previewVideoPlayer?.isMuted = true
        }
        super.init(videoPlayer: previewVideoPlayer, playerMode: .loop, autoPlayEnabled: false, videoPlayerConfiguration: previewConfiguration)
        
        self.$playerStatus.sink { [weak self] updatedStatus in
            self?.configurePreviewVideoPlayer(playerStatus: updatedStatus)
        }
        .store(in: &cancellables)
    }
    
    final func configurePreviewVideoPlayer(playerStatus: AVPlayer.Status?) {
        guard let playbackEndTime = videoPlayerConfig.playbackEndTime,
              playerStatus == .readyToPlay, didConfigure == false else {
            return
        }
        
        currentPlayerItem?.forwardPlaybackEndTime = CMTime(seconds: playbackEndTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        didConfigure = true
    }
}
