//
//  AVPlayer+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.01.2023.
//

import Foundation
import AVKit

extension AVPlayer {
    
    func playOrPause() {
        guard status == .readyToPlay else {
            return
        }
        switch timeControlStatus {
        case .paused, .waitingToPlayAtSpecifiedRate: play()
        case .playing: pause()
        @unknown default:
            fatalError()
        }
    }
    
    /// a convenience property to read the current time and also to set a new one
    var seconds: TimeInterval? {
        get {
            guard self.status == .readyToPlay else {
                return nil
            }
            return self.currentTime().seconds
        }
        set {
            guard let newValue else {
                return
            }
            seek(seconds: newValue)
        }
    }
    
    /// a convenience method to seek through the audio
    func seek(seconds: TimeInterval, preferredTimescale: CMTimeScale = 1000, completionHandler: @escaping (Bool) -> Void = { _ in }) {
        self.seek(to: CMTime(seconds: seconds, preferredTimescale: preferredTimescale), toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: completionHandler)
    }
}
