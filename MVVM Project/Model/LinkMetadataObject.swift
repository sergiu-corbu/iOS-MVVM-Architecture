//
//  LinkMetadataObject.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 31.01.2023.
//

import Foundation
import LinkPresentation
import UIKit

class LinkMetadataObject: NSObject, UIActivityItemSource {
    
    let title: String
    let linkDescription: String?
    
    private(set) var linkMetadata = LPLinkMetadata()
    private let appIconResource: URL? = Bundle.main.url(forResource: "AppIcon", withExtension: nil)
    
    init(title: String, linkDescription: String?) {
        self.title = title
        self.linkDescription = linkDescription
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        linkMetadata.title = title
        linkMetadata.iconProvider = NSItemProvider(contentsOf: appIconResource)
        return linkMetadata
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return linkDescription
    }
}

class ShareLinkActivityViewController: UIActivityViewController {
    
    override init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
        excludedActivityTypes = [.print, .assignToContact, .saveToCameraRoll, .addToReadingList]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.darkContent
    }
    
    override func loadView() {
        super.loadView()
        if let sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = false
            sheetPresentationController.preferredCornerRadius = 20
        }
    }
}
