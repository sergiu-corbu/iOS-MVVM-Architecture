//
//  SocialNetworkHandle.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 14.11.2022.
//

import Foundation

struct SocialNetworkHandle: Hashable, Encodable {
    
    let type: SocialNetworkType
    var handle: String?
    var platformName: String?
    var websiteUrl: URL?
    
    var hasValue: Bool {
        switch type {
        case .instagram, .tiktok, .youtube:
            return handle?.isEmpty == false
        case .website, .other:
            return websiteUrl?.absoluteString.isEmpty == false
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case websiteUrl = "url"
        case handle
        case platformName
    }
}

extension SocialNetworkHandle {
    
    init(type: SocialNetworkType, websiteUrl: URL?, platformName: String? = nil) {
        self.type = type
        self.handle = nil
        self.platformName = platformName
        self.websiteUrl = websiteUrl
    }
    
    init(type: SocialNetworkType, websiteUrl: URL) {
        self.type = type
        self.websiteUrl = websiteUrl
        self.platformName = nil
        self.handle = nil
    }
    
    init?(data: [String:String]) {
        guard let socialNetworkType = data[CodingKeys.type.rawValue],
              let type = SocialNetworkType(rawValue: socialNetworkType) else {
            return nil
        }
        self.type = type
        self.handle = data[CodingKeys.handle.rawValue]
        self.platformName = data[CodingKeys.platformName.rawValue]
        if let webisiteUrlString = data[CodingKeys.websiteUrl.rawValue] {
            self.websiteUrl = URL(string: webisiteUrlString)
        } else {
            self.websiteUrl = nil
        }
    }
}

extension SocialNetworkHandle {
    
    static func initFromCollection(_ collection: SocialNetworkCollection?) -> [Self] {
        guard let collection else {
            return []
        }
        
        var socialNetworks = [Self]()
        collection.forEach { socialNetworkData in
            if let socialNetwork = SocialNetworkHandle(data: socialNetworkData) {
                socialNetworks.append(socialNetwork)
            }
        }
        return socialNetworks
    }
}
