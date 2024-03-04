//
//  Shareable.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.06.2023.
//

import Foundation
import AppsFlyerLib

struct ShareLinkChannelType {
    static let mobileShare = "mobile_share"
}

enum ShareableType: CaseIterable {
    
    case show, creator, brand, product, giftInvite, promotedProducts
    
    var afDecodingKey: String {
        switch self {
        case .show: return AFEventParam1
        case .creator: return AFEventParam2
        case .brand: return AFEventParam3
        case .product: return AFEventParam4
        case .giftInvite: return AFEventParam5
        case .promotedProducts: return AFEventParam6
        }
    }
}

struct ShareableObject {
    
    let objectID: String
    let type: ShareableType
    var shareParameters: [ShareParameter: String]?
    var shareName: String?
    var shareBrand: String?
    var redirectURL: URL?
    
    var shareMessage: String {
        guard let shareName else {
            return "N/A"
        }
        switch type {
        case .show: return Strings.ShowDetail.shareMessage(sender: shareName)
        case .brand, .creator, .promotedProducts: return Strings.Profile.shareMessage(sender: shareName)
        case .product: return Strings.ProductsDetail.shareMessage(product: shareName, brand: shareBrand ?? "N/A")
        case .giftInvite: return "N/A"
        }
    }
    
    enum ShareParameter: String {
        case creatorUsername
        case creatorID
    }
}

typealias ShareParameters = [ShareableObject.ShareParameter: String]

extension ShareableObject {
    
    init?(data: [String : Any]?) {
        guard let data else { return nil }
        
        for shareType in ShareableType.allCases {
            if let objectID = data[shareType.afDecodingKey] as? String {
                self.init(objectID: objectID, type: shareType)
                return
            }
        }
        
        return nil
    }
}

class ShareableProvider {
    
    let onPresentShareLink: (ShareLinkActivityViewController) -> Void
    private let deeplinkProvider: DeeplinkProvider
    private var task: Task<Void, Never>?
    
    init(deeplinkProvider: DeeplinkProvider, onPresentShareLink: @escaping (ShareLinkActivityViewController) -> Void) {
        self.deeplinkProvider = deeplinkProvider
        self.onPresentShareLink = onPresentShareLink
    }
    
    deinit {
        task?.cancel()
    }
    
    @discardableResult
    private func generateShareURL(shareableObject: ShareableObject) async -> URL? {
        guard let shareURL = await deeplinkProvider.generateShareURL(shareableObject: shareableObject) else {
            return nil
        }
        let shareMessage = shareableObject.shareMessage
        let shareLinkMetadata = LinkMetadataObject(title: shareMessage, linkDescription: shareMessage)
        
        await MainActor.run {
            onPresentShareLink(ShareLinkActivityViewController(activityItems: [shareLinkMetadata, shareURL], applicationActivities: nil))
        }
        return shareURL
    }
    
    func generateShareURL(_ shareableObject: ShareableObject) {
        task?.cancel()
        
        task = Task(priority: .utility) { [weak self] in
            guard let self else { return }
            await self.generateShareURL(shareableObject: shareableObject)
        }
    }
}
