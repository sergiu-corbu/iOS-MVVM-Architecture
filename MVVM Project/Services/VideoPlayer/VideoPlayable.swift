//
//  VideoPlayable.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.01.2023.
//

import Foundation

protocol VideoPlayable {
    
    var preferredBufferDuration: TimeInterval { get }
    var autoplayDelay: TimeInterval? { get }
    var playbackEndTime: TimeInterval? { get }
}

struct DefaultVideoPlayerConfiguration: VideoPlayable {
    
    let preferredBufferDuration: TimeInterval = 5.0
    var autoplayDelay: TimeInterval? = 0.5
    var playbackEndTime: TimeInterval? = nil
}

struct PreviewVideoPlayerConfiguration: VideoPlayable {

    let preferredBufferDuration: TimeInterval = 5
    var autoplayDelay: TimeInterval? = nil
    let playbackEndTime: TimeInterval? = 15
}

#if DEBUG
struct DebugVideoPlayerConfiguration: VideoPlayable {
    var preferredBufferDuration: TimeInterval = 5.0
    var autoplayDelay: TimeInterval? = 1.0
    var playbackEndTime: TimeInterval? = nil
}
#endif
