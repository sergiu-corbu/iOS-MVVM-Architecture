//
//  ImageSelectionCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.11.2022.
//

import Foundation
import UIKit
import Combine
import Mantis

class ImageSelectionCoordinator: NSObject {
    
    weak var navigationController: UINavigationController?
    
    private var mediaLoader: MediaLoader?
    private var allowsCropping: Bool!
    
    let onImageLoaded = PassthroughSubject<UIImage?, Error>()
    
    private var fixedAspectRatio: Double?
    private lazy var cropConfiguration: Config = {
        var configuration = Config()
        if let fixedAspectRatio {
            configuration.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: fixedAspectRatio)
        }
        return configuration
    }()
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func start(allowsCropping: Bool, fixedRatio: Double? = 3/4, animated: Bool = true) {
        self.fixedAspectRatio = fixedRatio
        self.allowsCropping = allowsCropping
        showMediaLoader(animated: animated)
    }
    
    private func showMediaLoader(animated: Bool) {
        self.mediaLoader = MediaLoader(
            presentationController: navigationController,
            selectionLimit: 1,
            delegate: self
        )
        mediaLoader?.present()
    }
    
    private func showImageCropper(_ image: UIImage, animated: Bool = true) {
        let cropViewController = Mantis.cropViewController(image: image, config: cropConfiguration)
        cropViewController.delegate = self
        navigationController?.present(cropViewController, animated: animated)
    }
}

extension ImageSelectionCoordinator: MediaLoaderDelegate {
    
    func didLoadMediaTypes(_ mediaTypes: [MediaType]) {
        guard case .image(let selectedImage) = mediaTypes.first, let selectedImage else {
            return
        }
        if allowsCropping {
            showImageCropper(selectedImage)
        } else {
            onImageLoaded.send(selectedImage)
        }
    }
    
    func didReceiveError(_ error: Error) {
        onImageLoaded.send(completion: .failure(error))
    }
    
    func didCancelOperation() {
        onImageLoaded.send(nil)
    }
}

extension ImageSelectionCoordinator: CropViewControllerDelegate {
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
        onImageLoaded.send(cropped)
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        onImageLoaded.send(original)
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: Mantis.CropViewController) {}
    func cropViewControllerDidEndResize(_ cropViewController: Mantis.CropViewController, original: UIImage, cropInfo: Mantis.CropInfo) {}
    func cropViewControllerDidImageTransformed(_ cropViewController: Mantis.CropViewController) {}
}
