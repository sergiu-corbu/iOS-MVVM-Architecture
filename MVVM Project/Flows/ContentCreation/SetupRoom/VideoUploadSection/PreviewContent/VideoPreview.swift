//
//  VideoPreview.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.12.2022.
//

import SwiftUI
import AVKit

struct VideoPreview: View {
        
    let avPlayer: AVPlayer
    var autoPlayAfter: TimeInterval? = 0.5
    
    var body: some View {
        AVPreviewPlayerView(avPlayer: avPlayer)
            .ignoresSafeArea(.container, edges: .all)
            .task {
                guard let autoPlayAfter else {
                    return
                }
                await Task.sleep(seconds: autoPlayAfter)
                avPlayer.play()
            }
    }
}

extension VideoPreview {
    
    init(videoAsset: AVAsset, autoPlayAfter: TimeInterval? = 0.5) {
        self.avPlayer = AVPlayer(playerItem: AVPlayerItem(asset: videoAsset))
        self.autoPlayAfter = autoPlayAfter
    }
}

private struct AVPreviewPlayerView: UIViewControllerRepresentable {
    
    let avPlayer: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let avPlayerVC = AVPlayerViewController()
        avPlayerVC.player = avPlayer
        return avPlayerVC
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

#if DEBUG
struct VideoPreview_Previews: PreviewProvider {
    
    static var previews: some View {
        VideoPreview(avPlayer: .init(url: Show.sample.videoUrl!))
    }
}
#endif
