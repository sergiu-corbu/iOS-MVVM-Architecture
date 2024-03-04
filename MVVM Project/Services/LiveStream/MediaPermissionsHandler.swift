//
//  MediaPermissionsHandler.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 24.03.2023.
//

import Foundation
import AVFoundation

struct MediaPermissionsHandler {
    
    func checkForAudioVideoPermissions() async -> Bool {
        var permissionsGranted = await getOrRequestMediaAuthorizationStatus(for: .audio)
        
        if !permissionsGranted {
            return false
        }
        permissionsGranted = await getOrRequestMediaAuthorizationStatus(for: .video)
        return permissionsGranted
    }
    
    func getOrRequestMediaAuthorizationStatus(for mediaType: AVMediaType) async -> Bool {
        let mediaAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch mediaAuthorizationStatus {
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: mediaType)
        case .restricted, .denied:
            return false
        case .authorized:
            return true
        @unknown default:
            return false
        }
    }
}
