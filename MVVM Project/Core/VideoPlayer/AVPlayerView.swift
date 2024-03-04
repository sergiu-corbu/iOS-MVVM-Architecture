//
//  AVPlayerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.01.2023.
//

import Foundation
import SwiftUI
import AVKit

struct AVPlayerView: UIViewControllerRepresentable {
    
    let avPlayer: AVPlayer?
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let avPlayerVC = AVPlayerViewController()
        avPlayerVC.player = avPlayer
        avPlayerVC.videoGravity = .resizeAspectFill
        avPlayerVC.showsPlaybackControls = false
        avPlayerVC.allowsPictureInPicturePlayback = false
        avPlayerVC.updatesNowPlayingInfoCenter = false
        avPlayerVC.view.backgroundColor = .clear
        avPlayerVC.view.layer.backgroundColor = UIColor.clear.cgColor
        return avPlayerVC
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
