//
//  LiveStreamManager.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.03.2023.
//

import Foundation
import AVFoundation
import UIKit
import AgoraRtcKit

final class LiveStreamManager {
    
    //MARK: Properties
    let userRole: AgoraClientRole
    
    weak var delegate: AgoraRtcEngineDelegate?
    
    private var liveStreamEngine: AgoraRtcEngineKit!
    private let mediaPermissionsHandler = MediaPermissionsHandler()
    
    init(userRole: AgoraClientRole) {
        self.userRole = userRole
    }
    
    deinit {
        clearLiveStreamEngineResources()
    }
    
    //MARK: Functionality
    func setupLiveStreamEngine(delegate: AgoraRtcEngineDelegate) {
        let liveStreamConfig = AgoraRtcEngineConfig()
        liveStreamConfig.appId = Constants.LiveStreaming.APP_ID
        self.liveStreamEngine = AgoraRtcEngineKit.sharedEngine(with: liveStreamConfig, delegate: delegate)
    }
    
    func prepareBroadcasterPreviewCanvas(localStreamView: UIView?, liveStreamConnectable: any LiveStreamConnectable) async throws {
        guard userRole == .broadcaster else {
            return
        }
        guard await mediaPermissionsHandler.checkForAudioVideoPermissions() else {
            throw LiveStreamError.mediaPermissionsDenied
        }
        
        configureVideoEncodingConfiguration()
        setupVideoCanvas(in: localStreamView, uid: liveStreamConnectable.userID)
    }
    
    func joinChannel(liveStreamConnectable: any LiveStreamConnectable) async throws {
        let channelMediaOptions = AgoraRtcChannelMediaOptions()
        channelMediaOptions.clientRoleType = userRole
        channelMediaOptions.channelProfile = .liveBroadcasting
        channelMediaOptions.audienceLatencyLevel = .ultraLowLatency
        
        liveStreamEngine.setClientRole(userRole)
        liveStreamEngine.joinChannel(byToken: liveStreamConnectable.token,
                                     channelId: liveStreamConnectable.channelName,
                                     uid: liveStreamConnectable.userID,
                                     mediaOptions: channelMediaOptions)
    }
    
    func setupVideoCanvas(in localStreamView: UIView?, uid: UInt) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localStreamView
        videoCanvas.uid = uid
        
        liveStreamEngine.enableVideo()
        liveStreamEngine.enableAudio()
        
        switch userRole {
        case .broadcaster:
            liveStreamEngine.startPreview()
            liveStreamEngine.setupLocalVideo(videoCanvas)
        case .audience:
            liveStreamEngine.setupRemoteVideo(videoCanvas)
        @unknown default:
            break
        }
    }
    
    func leaveChannel() {
        if userRole == .broadcaster {
            liveStreamEngine.stopPreview()
        }
        liveStreamEngine.disableAudio()
        liveStreamEngine.disableVideo()
        liveStreamEngine.leaveChannel()
    }
    
    func setAudioVolume(to value: Float) {
        liveStreamEngine.muteAllRemoteAudioStreams(value == .zero)
    }
    
    private func configureVideoEncodingConfiguration() {
        let videoEncoderConfig = AgoraVideoEncoderConfiguration(
            size: CGSize(width: 1920, height: 1080),
            frameRate: .fps30, bitrate: 6300,
            orientationMode: .fixedPortrait, mirrorMode: .auto
        )
        liveStreamEngine.setVideoEncoderConfiguration(videoEncoderConfig)
    }
    
    private func clearLiveStreamEngineResources() {
        DispatchQueue.global(qos: .userInitiated).async {
            AgoraRtcEngineKit.destroy()
        }
    }
}

typealias VideoStreamUserRole = AgoraClientRole
