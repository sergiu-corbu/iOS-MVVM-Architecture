//
//  MediaAssetProvider.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.12.2022.
//

import Foundation
import Photos
import UIKit

protocol MediaAssetProviding {
    
    func loadAsset(identifier: String, withMaximumDuration maximumDuration: TimeInterval) async throws -> AVAsset
    
    func generatePreviewImage(from asset: AVAsset, previewTimestamp: TimeInterval) async throws -> UIImage?
}

protocol MediaAssetExporting {
    
    init(asset: AVAsset)
    
    func exportMediaAsset(outputFormat: AVFileType, exportProgressBlock: MediaAssetExportProgressBlock?) async throws -> CompressedAsset?
    
    func removeTemporaryAsset(temporaryAssetURL: URL) throws
    
    func cancelExportTask()
}

typealias MediaAssetExportProgressBlock = (Double) -> Void

class MediaAssetExporter: MediaAssetExporting {
    
    //MARK: - Properties
    let asset: AVAsset
    private var exportSession: AVAssetExportSession?
    private var progressExportTimer: Timer?
    
    required init(asset: AVAsset) {
        self.asset = asset
    }
    
    deinit {
        cancelExportTask()
        progressExportTimer?.invalidate()
    }
    
    ///Note: this method should be used for exporting a single asset at a time
    func exportMediaAsset(outputFormat: AVFileType, exportProgressBlock: MediaAssetExportProgressBlock?) async throws -> CompressedAsset? {
        defer { exportSession = nil }
        
        let temporaryAssetURL = try generateTemporaryAssetURL()
        let exportPreset = await configureExportPreset(outputFileType: outputFormat)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: exportPreset) else {
            return nil
        }
        
        exportSession.outputURL = temporaryAssetURL
        exportSession.outputFileType = outputFormat
        exportSession.timeRange.duration = try await asset.load(.duration)
        exportSession.shouldOptimizeForNetworkUse = true
        self.exportSession = exportSession

        await startProgressTimer(exportProgressBlock: exportProgressBlock)
        await exportSession.export()
        
        await stopProgressTimer()
        
        switch exportSession.status {
        case .completed:
            let compressedAsset = CompressedAsset(
                estimatedFileSizeInBytes: try await exportSession.estimatedOutputFileLengthInBytes,
                temporaryURL: temporaryAssetURL
            )
            return compressedAsset
        case .failed:
            if let exportError = exportSession.error {
                throw exportError
            } else {
                return nil
            }
        default: return nil
        }
    }
    
    func removeTemporaryAsset(temporaryAssetURL: URL) throws {
        try FileManager.default.removeItem(at: temporaryAssetURL)
    }
    
    @MainActor private func stopProgressTimer() {
        progressExportTimer?.invalidate()
        progressExportTimer = nil
    }
    
    @MainActor private func startProgressTimer(exportProgressBlock: MediaAssetExportProgressBlock?) {
        self.progressExportTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block:  { [weak self] _ in
            guard let exportSession = self?.exportSession else {
                return
            }
            exportProgressBlock?(Double(exportSession.progress))
        })
    }
    
    //MARK: - Helpers
    private func configureExportPreset(_ defaultPreset: String = AVAssetExportPreset1920x1080,
                                       outputFileType: AVFileType) async -> String {
        return await withCheckedContinuation { continuation in
            AVAssetExportSession.determineCompatibility(
                ofExportPreset: defaultPreset,
                with: asset,
                outputFileType: outputFileType
            ) { isCompatible in
                continuation.resume(returning: isCompatible ? defaultPreset : AVAssetExportPresetPassthrough)
            }
        }
    }
    
    func cancelExportTask() {
        exportSession?.cancelExport()
        exportSession = nil
    }
    
    private func generateTemporaryAssetURL() throws -> URL {
        let fileManager: FileManager = .default
        let assetName = (asset as? AVURLAsset)?.url.lastPathComponent ?? "compressed-video-asset"
        
        let temporaryFileURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil, create: true
        ).appendingPathComponent(assetName)
                
        if fileManager.fileExists(atPath: temporaryFileURL.path) {
            try? fileManager.removeItem(at: temporaryFileURL)
        }
        
        return temporaryFileURL
    }
}

class MediaAssetProvider: MediaAssetProviding {
    
    private lazy var phImageManager = PHImageManager()
    
    func loadAsset(identifier: String, withMaximumDuration maximumDuration: TimeInterval) async throws -> AVAsset {
        guard let videoAsset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject,
              videoAsset.mediaType == .video else {
            throw MediaError.accessDeniedForMediaFile
        }
        
        let asset: AVAsset = try await withCheckedThrowingContinuation { continuation in
            let options = PHVideoRequestOptions()
            options.deliveryMode = .fastFormat
            options.isNetworkAccessAllowed = true
            
            phImageManager.requestAVAsset(forVideo: videoAsset, options: options) { asset, _, _ in
                guard let asset else {
                    continuation.resume(throwing: MediaError.missingMediaFile)
                    return
                }
                
                Task(priority: .utility) {
                    do {
                        let assetDuration = try await asset.load(.duration).seconds
                        if assetDuration < 1 || assetDuration > maximumDuration {
                            continuation.resume(throwing: MediaError.assetTooLarge)
                        } else {
                            continuation.resume(returning: asset)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
        
        return asset
    }
    
    func generatePreviewImage(from asset: AVAsset, previewTimestamp: TimeInterval = 1) async throws -> UIImage? {
        let previewTime = CMTime(seconds: previewTimestamp, preferredTimescale: 1)
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = previewTime
        generator.appliesPreferredTrackTransform = true
    
        return try await withCheckedThrowingContinuation { continuation in
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: previewTime)]) { _, cgImage, _, _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let cgImage {
                    continuation.resume(returning: UIImage(cgImage: cgImage))
                }
            }
        }
    }
}
                       
struct CompressedAsset {
    
    let estimatedFileSizeInBytes: Int64
    let temporaryURL: URL
    
    var estimatedFileSizeInMB: Int64 {
        return estimatedFileSizeInBytes.estimatedBytesToMB
    }
}


#if DEBUG
struct MockMediaAssetProvider: MediaAssetProviding {
    
    func loadAsset(identifier: String, withMaximumDuration: TimeInterval) async throws -> AVAsset {
        return AVAsset(url: Bundle.main.url(forResource: "video_sample", withExtension: ".mp4")!)
    }
    
    func generatePreviewImage(from asset: AVAsset, previewTimestamp: TimeInterval) async throws -> UIImage? {
        return nil
    }
    
    func compressAsset(_ asset: AVAsset, outputFormat: AVFileType) async throws -> CompressedAsset? {
        return nil
    }
    
    func cancelCompressureTask() {}
}

struct MockMediaAssetExporter: MediaAssetExporting {
    
    init(asset: AVAsset) {
        
    }
    
    func exportMediaAsset(outputFormat: AVFileType, exportProgressBlock: MediaAssetExportProgressBlock?) async throws -> CompressedAsset? {
        return nil
    }
    
    func cancelExportTask() {
        
    }
    
    func removeTemporaryAsset(temporaryAssetURL: URL) throws {
        
    }
}
#endif
