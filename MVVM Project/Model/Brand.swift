//
//  Brand.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.12.2022.
//

import Foundation

struct Brand: Decodable, Hashable, Identifiable {
   
    var id: String?
    let name: String
    var logoPictureURL: URL?
    var coverPictureURL: URL?
//    var numberOfShows: Int?
    var followerCount: Int?
    var description: String?
    var city: String?
    var country: String?
    var priority: Int?
    var giftRequestInstruction: String?
    var sizeGuides: String?
    var returnPolicy: String?
    
    var location: String? {
        if let city, let country {
            return [city, country].joined(separator: ", ")
        } else {
            return city ?? country
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case _id = "_id"
        case name
        case logoPictureURL = "logoPictureUrl"
        case coverPictureURL = "coverPictureUrl"
//        case numberOfShows
        case description
        case followerCount = "followers"
        case country
        case city
        case priority
        case giftRequestInstruction, sizeGuides, returnPolicy
    }
}

extension Brand {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id, fallbackKey: ._id)
        self.name = try container.decode(String.self, forKey: .name)
        self.logoPictureURL = try container.decodeIfPresent(URL.self, forKey: .logoPictureURL)
        self.coverPictureURL = try container.decodeIfPresent(URL.self, forKey: .coverPictureURL)
//        self.numberOfShows = try container.decodeIfPresent(Int.self, forKey: .numberOfShows)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.followerCount = try container.decodeIfPresent(Int.self, forKey: .followerCount)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.priority = try container.decodeIfPresent(Int.self, forKey: .priority)
        self.giftRequestInstruction = try container.decodeIfPresent(String.self, forKey: .giftRequestInstruction)
        self.sizeGuides = try container.decodeIfPresent(String.self, forKey: .sizeGuides)
        self.returnPolicy = try container.decodeIfPresent(String.self, forKey: .returnPolicy)
    }
    
    init(name: String) {
        #if DEBUG
        self.id = UUID().uuidString
        #endif
        self.name = name
    }
    
    init(partnershipBrand: PartnershipBrand) {
        self.id = partnershipBrand.id
        self.name = partnershipBrand.name
        self.followerCount = 0
        self.logoPictureURL = partnershipBrand.brandPictureURL
    }
    
    var shareableObject: ShareableObject? {
        guard let brandID = id else {
            return nil
        }
        return ShareableObject(objectID: brandID, type: .brand, shareName: name)
    }
    
    var baseAnalyticsProperties: AnalyticsProperties {
        var properties = AnalyticsProperties()
        properties[.brand_id] = id
        properties[.brand_name] = name
        return properties
    }
}

/// NOTE: - Workaround as the brand id can be nil in creator application flow
struct BrandWrapper: StringIdentifiable, Equatable {
    
    let value: Brand
    
    var id: String {
        return value.id ?? "" + value.name
    }
}

struct PartnershipBrand: Codable, Hashable, Equatable {
    
    let id: String
    let name: String
    let type: EccomerceType
    let brandPictureURL: URL?
    
    var isUsableInContentCreation: Bool {
        return type == .contracted
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "brandId"
        case name = "brandName"
        case brandPictureURL = "logoPictureUrl"
        case type
    }
}

extension PartnershipBrand {
    
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.brandPictureURL = nil
        self.type = .contracted
    }
}
