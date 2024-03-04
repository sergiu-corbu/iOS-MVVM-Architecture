//
//  ImageDownloader.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.01.2023.
//

import Foundation
import UIKit
import Kingfisher

protocol ImageDownloadable {
    
    var downloadURL: URL? { get }
    var imageSize: CGSize { get set }
}

protocol ImageDownloader {
    
    func downloadImageSize(_ imageURL: URL?) async throws -> CGSize
}

extension ImageDownloader {

    ///This is a convenience method for prefetching the images and assigning the size to any object that conforms to `ImageDownloadable`
    func prefetchImages<T>(objects imageDownloadables: [T]) async -> [T] where T : ImageDownloadable {
        guard !imageDownloadables.isEmpty else {
            return imageDownloadables
        }
        
        typealias DownloadableImageWithIndex = (downloadable: T, index: Int)
        
        return await withTaskGroup(of: DownloadableImageWithIndex.self, returning: [T].self) { taskGroup in
            for (index, downloadable) in imageDownloadables.enumerated() {
                taskGroup.addTask {
                    var mutableDownloadable = downloadable
                    do {
                        mutableDownloadable.imageSize = try await downloadImageSize(downloadable.downloadURL)
                    } catch {
                        print(error.localizedDescription)
                    }
                    return (mutableDownloadable, index)
                }
            }
            
            return await taskGroup.reduce(into: [DownloadableImageWithIndex]()) { partialResult, element in
                partialResult.append(element)
            }
            .sorted(using: KeyPathComparator(\.index, order: .forward))
            .map(\.downloadable)
        }
    }
}

extension Array where Self.Element: ImageDownloadable {
    
    @discardableResult
    mutating func prefetchImagesMetadata(
        imageDownloader: any ImageDownloader = KFImageDownloader()
    ) async -> Self {
            
        self = await imageDownloader.prefetchImages(objects: self)
        return self
    }
}

struct KFImageDownloader: ImageDownloader {
    
    typealias ObjectType = Product
    
    func downloadImageSize(_ imageURL: URL?) async throws -> CGSize {
        guard let imageURL else {
            throw ImageDownloaderError(imageURL: nil)
        }
        return try await withCheckedThrowingContinuation { continuation in
            KingfisherManager.shared.retrieveImage(
                with: .network(KF.ImageResource(downloadURL: imageURL, cacheKey: imageURL.absoluteString)),
                options: [.backgroundDecode, .retryStrategy(DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(0.1)))]
            ) { result in
                if case .success(let imageResult) = result {
                    continuation.resume(returning: imageResult.image.size)
                } else {
                    continuation.resume(throwing: ImageDownloaderError(imageURL: imageURL))
                }
            }
        }
    }
}

struct ImageDownloaderError: LocalizedError {
    
    let imageURL: URL?
    
    var errorDescription: String? {
        if let imageURL {
            return "Failed to download imageSize. Context: imageURL - \(imageURL.absoluteString)"
        } else {
            return "Failed to download imageSize. Context: Missing or invalid imageURL"
        }
    }
}
