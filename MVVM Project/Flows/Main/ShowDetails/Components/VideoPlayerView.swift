//
//  VideoPlayerView.swift
//  Bond
//
//  Created by Sergiu Corbu on 27.03.2023.
//

import SwiftUI

extension View {
    
    func videoStreamGradientView(_ tapAction: (() -> Void)?) -> some View {
        return self.overlay {
            GeometryReader { geometryProxy in
                LinearGradient(gradient: IncreasingGradient().makeGradient(.jet), startPoint: .top, endPoint: .bottom)
                    .frame(height: abs(geometryProxy.size.height / 2 - 20))
                    .highPriorityGesture(TapGesture().onEnded { _ in
                        tapAction?()
                    })
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}

struct VideoPlayerView: View {
    
    @ObservedObject var videoPlayerService: VideoPlayerService
    
    let show: Show
    var useStaticThumbnail: Bool = true
    
    private var showPlaybackPlayIcon: Bool {
        return videoPlayerService.isPaused
    }
    
    var body: some View {
        ZStack {
            AVPlayerView(avPlayer: videoPlayerService.videoPlayer)
            if useStaticThumbnail {
                ShowThumbnailView(showThumbnailURL: show.thumbnailUrl)
                    .opacity(videoPlayerService.isVideoPlayerReadyToPlay ? 0 : 1)
                    .animation(.easeInOut(duration: 0.25), value: videoPlayerService.isVideoPlayerReadyToPlay)
            }
        }
        .overlay {
            if showPlaybackPlayIcon {
                PlayVideoStreamIndicator()
            } else if videoPlayerService.showLoadingIndicator {
                VideoPlayerLoadingIndicator()
            }
        }
        .highPriorityGesture(togglePlaybackStateGesture)
        .animation(.easeInOut(duration: 0.3), value: videoPlayerService.playerStatus?.rawValue)
        .videoStreamGradientView(togglePlaybackState)
        .onDisappear(perform: pauseVideo)
    }
}

//MARK: Functionality
private extension VideoPlayerView {
    
    var togglePlaybackStateGesture: some Gesture {
        TapGesture().onEnded { _ in
            togglePlaybackState()
        }
    }
    
    func togglePlaybackState() {
        videoPlayerService.togglePlaying()
    }
    
    func pauseVideo() {
        videoPlayerService.stopPlaying()
    }
}

#if DEBUG
struct VideoPlayerView_Previews: PreviewProvider {

    static var previews: some View {
        VideoPlayerView(videoPlayerService: .init(videoURL: Show.sample.videoUrl), show: .sample)
    }
}
#endif
