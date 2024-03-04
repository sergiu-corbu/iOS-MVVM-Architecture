//
//  User.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import Foundation
import Combine

typealias Creator = User

struct User: Codable, Hashable, StringIdentifiable {
    
    let id: String
    var email: String
    var fullName: String?
    var username: String?
    var profilePictureUrl: URL?
    let createdAt: String?
    
    let role: Role
    var bio: String?
    var socialNetworks: [SocialNetworkHandle]?
    var partnershipBrands: [PartnershipBrand]?
    var addresses: [CustomerAddress]
    var phoneNumber: String?
    
    var wasRecentlyApprovedAsCreator: Bool?
    var appliedAsCreator: Bool?
    
    let livestreamUserID: Int?
    
    var firstName: String? {
        if let firstName = fullName?.split(separator: " ").first {
            return String(firstName)
        }
        return nil
    }
    var lastName: String? {
        if let firstName = fullName?.split(separator: " ").last {
            return String(firstName)
        }
        return nil
    }
    var isProfileCompleted: Bool {
        return username != nil && fullName != nil
    }
    var formattedUsername: String {
        return "@" + (username ?? "")
    }
    
    //Followers
    var followersCount: Int = 0
    
    //Following
    var followingUserIds = Set<String>()
    var followingBrandIds = Set<String>()
    var followingCount: Int = 0 //NOTE: check if getter only is required after backend update! best solution would be to sum up the ids
    var brandsFollowingCount: Int = 0
    var userFollowingCount: Int = 0
    
    var views: Int?
    
    let numberOfOrders: Int?
    
    func followingCounts(isSelfUser: Bool) -> (users: Int, brands: Int) {
        if isSelfUser {
            return (followingUserIds.count, followingBrandIds.count)
        } else {
            return (userFollowingCount, brandsFollowingCount)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case fullName
        case username
        case role = "type"
        case bio
        case createdAt
        case partnershipBrands = "partnerships"
        case appliedAsCreator
        case socialNetworks = "socials"
        case profilePictureUrl
        case wasRecentlyApprovedAsCreator = "firstLoginAfterApprove"
        case livestreamUserID = "agoraUid"
        case followingUserIds = "followingIds"
        case followingBrandIds = "followingBrandIds"
        case followersCount = "followers"
        case followingCount = "following"
        case numberOfOrders
        case addresses, phoneNumber
        case views
        case brandsFollowingCount = "brandsFollowing"
        case userFollowingCount = "creatorsFollowing"
    }
}

extension User {
    
    enum Role: String, Codable {
        case shopper
        case creator
    }
    
    enum UpdateKey: String {
        case email
        case fullName
        case username
        case phoneNumber
    }
    
    var shareableObject: ShareableObject {
        var parameters = ShareParameters()
        parameters[.creatorID] = id
        parameters[.creatorUsername] = formattedUsername
        
        return ShareableObject(
            objectID: id, type: .creator, shareParameters: parameters,
            shareName: fullName, redirectURL: Constants.AppsFlyer.REDIRECT_URL?.appendingPathComponent("creators/\(id)")
        )
    }
    
    var baseAnalyticsProperties: AnalyticsProperties {
        var properties = AnalyticsProperties()
        properties[.creator_id] = id
        properties[.creator_username] = formattedUsername
        return properties
    }
}

extension User {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.role = try container.decodeIfPresent(Role.self, forKey: .role) ?? .shopper
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.socialNetworks = SocialNetworkHandle.initFromCollection(
            try container.decodeIfPresent(Array<[String:String]>.self, forKey: .socialNetworks)
        )
        self.partnershipBrands = try container.decodeIfPresent(Array<PartnershipBrand>.self, forKey: .partnershipBrands)
        self.profilePictureUrl = try container.decodeIfPresent(URL.self, forKey: .profilePictureUrl)
        self.wasRecentlyApprovedAsCreator = try container.decodeIfPresent(Bool.self, forKey: .wasRecentlyApprovedAsCreator)
        self.appliedAsCreator = try container.decodeIfPresent(Bool.self, forKey: .appliedAsCreator)
        self.livestreamUserID = try container.decodeIfPresent(Int.self, forKey: .livestreamUserID)
        self.followingUserIds = (try? container.decodeIfPresent(Set<String>.self, forKey: .followingUserIds)) ?? []
        self.followingBrandIds = (try? container.decodeIfPresent(Set<String>.self, forKey: .followingBrandIds)) ?? []
        self.followersCount = (try? container.decodeIfPresent(Int.self, forKey: .followersCount)) ?? 0
        self.followingCount = (try? container.decodeIfPresent(Int.self, forKey: .followingCount)) ?? 0
        self.brandsFollowingCount = (try? container.decodeIfPresent(Int.self, forKey: .brandsFollowingCount)) ?? 0
        self.userFollowingCount = (try? container.decodeIfPresent(Int.self, forKey: .userFollowingCount)) ?? 0
        self.numberOfOrders = try container.decodeIfPresent(Int.self, forKey: .numberOfOrders)
        self.addresses = try container.decodeIfPresent([CustomerAddress].self, forKey: .addresses) ?? []
        self.phoneNumber = try? container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.views = try? container.decodeIfPresent(Int.self, forKey: .views)
    }
}
