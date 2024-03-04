//
//  VideoPlayerService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.01.2023.
//

import Foundation
import AVKit
import Combine

enum VideoPlayerMode {
    case singlePlay
    case loop
}

class VideoPlayerService: ObservableObject {
    
    //MARK: Exposed properties
    private(set) var videoPlayer: AVPlayer?
    @Published private(set) var playerStatus: AVPlayer.Status?
    @Published private(set) var playerItemStatus: AVPlayerItem.Status?
    @Published private(set) var timeControlStatus: AVPlayer.TimeControlStatus
    @Published private(set) var isPlaybackLikelyToKeepUp: Bool = false
    @Published private(set) var isPlaybackBufferEmpty: Bool = true
    
    let currentTimePublisher = CurrentValueSubject<TimeInterval, Never>(0)

    @Published var isPaused: Bool = true
    var playerMode: VideoPlayerMode
    var videoPlayerConfig: VideoPlayable
    var currentPlayerItem: AVPlayerItem? {
        return videoPlayer?.currentItem
    }
    var isVideoPlayerReadyToPlay: Bool {
        return videoPlayer != nil && playerStatus == .readyToPlay && playerItemStatus == .readyToPlay
    }
    var showLoadingIndicator: Bool {
        return !isPaused && currentPlayerItem?.isPlaybackBufferFull == false
        && (timeControlStatus != .playing || isPlaybackBufferEmpty || playerItemStatus != .readyToPlay)
    }
    var currentItemDuration: TimeInterval {
        if let duration = currentPlayerItem?.duration.seconds, !duration.isNaN {
            return duration
        } else {
            return .zero
        }
    }
    
    private var autoPlayEnabled: Bool = false
    
    //MARK: Player observers
    private var playerStatusObservationKey: NSKeyValueObservation?
    private var playerItemStatusObservationKey: NSKeyValueObservation?
    private var playerPlaybackObservationKey: NSKeyValueObservation?
    private var playerBufferEmptyObservationKey: NSKeyValueObservation?
    private var playerBufferFullObservationKey: NSKeyValueObservation?
    private var playerBufferAlmostFullObservationKey: NSKeyValueObservation?
    private var playerStallObservationKey: NSKeyValueObservation?
    private var currentTimeObservationKey: Any?
    
    private let notificationCenter: NotificationCenter = .default
    var cancellables = Set<AnyCancellable>()
    
    init(videoPlayer: AVPlayer?,
         playerMode: VideoPlayerMode,
         autoPlayEnabled: Bool,
         videoPlayerConfiguration: VideoPlayable = DefaultVideoPlayerConfiguration()) {
        
        self.videoPlayer = videoPlayer
        self.playerMode = playerMode
        self.autoPlayEnabled = autoPlayEnabled
        self.timeControlStatus = videoPlayer?.timeControlStatus ?? .paused
        self.playerStatus = videoPlayer?.status
        self.playerItemStatus = videoPlayer?.currentItem?.status ?? .unknown
        self.videoPlayerConfig = videoPlayerConfiguration
        
        currentPlayerItem?.preferredForwardBufferDuration = videoPlayerConfiguration.preferredBufferDuration
        videoPlayer?.automaticallyWaitsToMinimizeStalling = false
        
        setupVideoPlayerItemObservers()
        setupVideoPlayerObservers()
        
        if autoPlayEnabled {
            startPlaying()
        }
    }
    
    deinit {
        cleanup()
    }
    
    //MARK: Functionality
    
    class func setupAudioSessionCategoryPlayback() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .mixWithOthers)
    }
    
    func togglePlaying() {
        if isPaused {
            startPlaying()
        } else {
            stopPlaying()
        }
    }
    
    func startPlaying() {
        isPaused = false
        play()
    }
    
    func setAudioVolume(to value: Float) {
        videoPlayer?.volume = value
    }
    
    func stopPlaying() {
        isPaused = true
        pause()
    }
    
    func pauseIfNeeded() {
        if timeControlStatus == .playing {
            videoPlayer?.pause()
        }
    }
    
    func seek(seconds: TimeInterval, completionHandler: ((Bool) -> Void)? = nil) {
        videoPlayer?.seek(seconds: seconds, completionHandler: { [weak self] completed in
            self?.startPlaying()
            completionHandler?(completed)
        })
    }
    
    private func play() {
        videoPlayer?.play()
    }
    
    private func pause() {
        videoPlayer?.pause()
    }
    
    //MARK: Private functionality
    private func handleVideoDidPlayToEnd() {
        videoPlayer?.seek(seconds: 0)
        if playerMode == .loop {
            startPlaying()
        } else {
            stopPlaying()
        }
    }
    
    private func autoplayAfter(delay: TimeInterval?) {
        DispatchQueue.main.asyncAfter(seconds: delay ?? .zero) {
            self.play()
        }
    }
    
    private func cleanup() {
        playerStatusObservationKey?.invalidate()
        playerPlaybackObservationKey?.invalidate()
        playerBufferEmptyObservationKey?.invalidate()
        playerBufferAlmostFullObservationKey?.invalidate()
        playerItemStatusObservationKey?.invalidate()
        playerBufferFullObservationKey?.invalidate()
        playerStallObservationKey?.invalidate()
        currentTimeObservationKey = nil
        
        cancellables.forEach { $0.cancel() }
        pause()
        videoPlayer = nil
    }
}

//MARK: VideoPlayerStatesObserving
private extension VideoPlayerService {
    
    func setupVideoPlayerItemObservers() {
        playerItemStatusObservationKey = currentPlayerItem?.observe(\.status) { [weak self] playerItem, observedValue in
            DispatchQueue.main.async {
                self?.handlePlayerItemStatusChange(playerItem.status)
            }
        }
        
        playerBufferFullObservationKey = currentPlayerItem?.observe(\.isPlaybackBufferFull, options: [.old, .new]) { [weak self] videoPlayer, observedValue in
            guard observedValue.oldValue != observedValue.newValue else {
                return
            }
            DispatchQueue.main.async {
                self?.handleBufferIsFullChange(videoPlayer.isPlaybackBufferFull)
            }
        }
        
        playerBufferEmptyObservationKey = currentPlayerItem?.observe(\.isPlaybackBufferEmpty, options: [.old, .new]) { [weak self] videoPlayer, observedValue in
            guard observedValue.oldValue != observedValue.newValue else {
                return
            }
            DispatchQueue.main.async {
                self?.handleBufferIsEmptyChange(videoPlayer.isPlaybackBufferEmpty)
            }
        }
        
        playerBufferAlmostFullObservationKey = currentPlayerItem?.observe(\.isPlaybackLikelyToKeepUp, options: [.old, .new]) { [weak self] _, observedValue in
            guard observedValue.oldValue != observedValue.newValue else {
                return
            }
//            print("*** playback is likely to keep up: \(observedValue.newValue ?? false)")
            if let newValue = observedValue.newValue {
                DispatchQueue.main.async {
                    self?.handlePlaybackIsLikelyToKeepUpChange(newValue)
                }
            }
        }
        
        notificationCenter.publisher(for: .AVPlayerItemPlaybackStalled, object: currentPlayerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
//                print("*** video stalled")
                self?.handleStall()
            }
            .store(in: &cancellables)
    }
    
    func setupVideoPlayerObservers() {
        playerStatusObservationKey = videoPlayer?.observe(\.status) { [weak self] videoPlayer, observedValue in
            DispatchQueue.main.async {
                self?.handlePlayerStatusChange(videoPlayer.status)
            }
        }
        playerPlaybackObservationKey = videoPlayer?.observe(\.timeControlStatus, options: [.old, .new]) { [weak self] videoPlayer, observedValue in
            DispatchQueue.main.async {
                self?.handleTimeControlStatusChange(videoPlayer.timeControlStatus)
            }
        }
        currentTimeObservationKey = videoPlayer?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.2, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main, using: { [weak self] time in
                self?.currentTimePublisher.send(time.seconds)
        })
        
        notificationCenter.publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                if !self.isPaused {
                    self.play()
                }
            }
            .store(in: &cancellables)
        notificationCenter.publisher(for: UIApplication.didEnterBackgroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.pause()
            }
            .store(in: &cancellables)
        notificationCenter.publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                self?.handleVideoPlayerInterruption(notification: notification as NSNotification)
            }
            .store(in: &cancellables)
        
        notificationCenter.publisher(for: .AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleVideoDidPlayToEnd()
            }
            .store(in: &cancellables)
    }
    
    private func handlePlayerItemStatusChange(_ status: AVPlayerItem.Status) {
        guard status != playerItemStatus else {
            return
        }
        playerItemStatus = status
        switch status {
        case .unknown:
            return
        case .readyToPlay:
            if !isPaused {
                play()
            }
        //TODO: handle video player errors
        case .failed:
            print("error")
        @unknown default:
            print("error")
        }
    }
    
    private func handlePlayerStatusChange(_ status: AVPlayer.Status) {
        if status != playerStatus {
            playerStatus = status
        }
    }
    
    private func handleTimeControlStatusChange(_ status: AVPlayer.TimeControlStatus) {
//        print("*** time control status: \(status)")
        timeControlStatus = status
    }
    
    private func handleBufferIsEmptyChange(_ isEmpty: Bool) {
//        print("*** buffer is empty: \(isEmpty)")
        isPlaybackBufferEmpty = isEmpty
    }
    
    private func handleBufferIsFullChange(_ isFull: Bool) {
        if !isPaused {
//          print("*** buffer is full: \(isFull)")
            play()
        }
    }
    
    private func handlePlaybackIsLikelyToKeepUpChange(_ isLikelyToKeepUp: Bool) {
        self.isPlaybackLikelyToKeepUp = isLikelyToKeepUp
    }
    
    private func handleStall() {
        DispatchQueue.main.asyncAfter(seconds: 3) { //TODO: refactor this - add delay logic
            if !self.isPaused {
                self.play()
            }
        }
    }
    
    //MARK: VideoPlayer interruption
    func handleVideoPlayerInterruption(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        switch type {
            case .began:
                pause()
            case .ended:
                guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
                }
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    play()
                }
            @unknown default:
                break
        }
    }
}

//MARK: Convenience initializers
extension VideoPlayerService {
    
    convenience init(videoURL: URL?, autoPlayEnabled: Bool = true, playerMode: VideoPlayerMode = .loop, configuration: VideoPlayable = DefaultVideoPlayerConfiguration()) {
        if let videoURL {
            self.init(videoPlayer: AVPlayer(url: videoURL), playerMode: playerMode, autoPlayEnabled: autoPlayEnabled, videoPlayerConfiguration: configuration)
        } else {
            self.init(videoPlayer: nil, playerMode: playerMode, autoPlayEnabled: autoPlayEnabled, videoPlayerConfiguration: configuration)
        }
    }
}
