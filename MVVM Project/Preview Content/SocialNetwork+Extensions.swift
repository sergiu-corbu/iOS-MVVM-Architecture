//
//  SocialNetwork+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 23.11.2022.
//

import Foundation

#if DEBUG
extension SocialNetworkHandle {
    
    static let instagram = SocialNetworkHandle(type: .instagram, handle: "@sergiu")
    static let youtube = SocialNetworkHandle(type: .youtube, handle: "sergiu")
    static let website = SocialNetworkHandle(type: .website, websiteUrl: URL(string: "google.com"))
    static let otherSocial = SocialNetworkHandle(type: .other, handle: "@sergiu", platformName: "Twitter")
    
    static var all: [Self] {
        [instagram, youtube, website, otherSocial]
    }
}
#endif
