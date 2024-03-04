//
//  PromotionalBanner.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 05.10.2023.
//

import Foundation

struct PromotionalBanner: Hashable, Decodable {
    
    let id: String
    let title: String
    let message: String
    let imageURL: URL?
    let isNew: Bool
    let type: PromotionalBannerType
    
    let products: [Product]?
    let brandID: String?
    let creatorID: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case title
        case isNew
        case message = "buttonText"
        case imageURL = "imageUrl"
        case products = "products"
        case brandID = "brandId"
        case creatorID = "creatorId"
    }
}

extension PromotionalBanner {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.isNew = try container.decode(Bool.self, forKey: .isNew)
        self.message = try container.decode(String.self, forKey: .message)
        self.imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
        self.products = try container.decodeIfPresent([Product].self, forKey: .products)
        self.brandID = try container.decodeIfPresent(String.self, forKey: .brandID)
        self.creatorID = try container.decodeIfPresent(String.self, forKey: .creatorID)
        
        if let bannerType = PromotionalBannerType(rawValue: try container.decode(String.self, forKey: .type)) {
            self.type = bannerType
        } else {
            throw DecodingError.valueNotFound(String.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: ""))
        }
    }
}

enum PromotionalBannerType: String {
    case brandProfile
    case creatorProfile
    case productList
}

#if DEBUG
extension PromotionalBanner {
    
    static let promotionalBrandBanner = PromotionalBanner(id: "brand-banner", title: "Check out the products from Gucci that have just been released from our store", message: "Shop Now", imageURL: .sampleImageURL(width: 280, height: 114), isNew: true, type: .brandProfile, products: nil, brandID: "brandID", creatorID: nil)
    static let promotionalUserBanner = PromotionalBanner(id: "creator-banner", title: "Check out the latest shows from Allysa Lynch", message: "Shop Now", imageURL: .sampleImageURL(width: 279, height: 114), isNew: false, type: .creatorProfile, products: nil, brandID: nil, creatorID: "user")
    static let promotionalProductsBanner = PromotionalBanner(id: "products-banner", title: "New coats for winter season", message: "Shop Now", imageURL: .sampleImageURL(width: 281, height: 114), isNew: .random(), type: .productList, products: [.sampleProduct], brandID: nil, creatorID: nil)

    static let mockedBanners = [promotionalUserBanner, promotionalBrandBanner, promotionalProductsBanner]
}
#endif
