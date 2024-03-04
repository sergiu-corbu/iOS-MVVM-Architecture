//
//  SocialNetworkType.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.11.2022.
//

import Foundation
import SwiftUI

enum SocialNetworkType: String, CaseIterable, Encodable, Hashable {
    
    case instagram
    case tiktok
    case youtube
    case website = "personal"
    case other
    
    var label: String {
        switch self {
        case .instagram, .tiktok, .other: return "Handle"
        case .youtube: return "Channel"
        case .website: return "URL"
        }
    }
        
    var image: Image {
        let image: ImageResource
        switch self {
        case .instagram: image = .instagramIcon
        case .youtube: image = .youtubeIcon
        case .tiktok: image = .tiktokIcon
        case .website: image = .globeIcon
        case .other: image = .linkIcon
        }
        return Image(image)
    }
    
    var inputPlaceholder: String {
        switch self {
        case .instagram: return "Instagram handle"
        case .tiktok: return "TikTok username"
        case .youtube: return "Youtube channel"
        case .website: return "Personal website link"
        case .other: return "Other platform"
        }
    }
    
    var isWebsiteType: Bool {
        return [Self.other, .website].contains(self)
    }
}
