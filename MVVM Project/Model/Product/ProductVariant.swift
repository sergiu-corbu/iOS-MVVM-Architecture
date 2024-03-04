//
//  ProductVariant.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.02.2023.
//

import Foundation

struct ProductVariant: Hashable, Decodable {
    
    let id: UInt
    let name: String
    let values: [ProductVariantValue]
    
    var isPrimary: Bool {
        let lowercasedName = name.lowercased()
        return lowercasedName == "color" || lowercasedName == "colour"
    }
    
    var allSKUIds: Set<UInt> {
        return Set(values.flatMap(\.skuIds))
    }
}

struct ProductVariantValue: Hashable, Decodable, CustomSortable {
    
    let id: UInt
    let name: String
    let skuIds: [UInt]
    
    var value: String {
        return name
    }
}

struct ProductSKU: Decodable, Hashable {
    let id: UInt
    let name: String?
    let merchantID: UInt
    let salePrice: Double
    let retailPrice: Double
    let albums: [SKUAlbum]
    
    //TODO: refactor this
    let inStock: String
    var isInStock: Bool {
        return inStock == "true"
    }
    var mediaUrls: [URL] {
        return albums.first?.imageURLs.compactMap { $0 } ?? []
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case merchantID = "merchantId"
        case salePrice
        case retailPrice
        case albums
        case inStock
    }
    
    struct SKUAlbum: Decodable, Hashable {
        
        let id: UInt
        let imageURLs: [URL]
        
        enum CodingKeys: String, CodingKey {
            case id
            case imageURLs = "media"
        }
        
        struct MediaURL: Decodable {
            let sourceUrl: URL?
        }
    }
}
extension ProductSKU.SKUAlbum {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UInt.self, forKey: .id)
        let imageURLs = try? container.decode([MediaURL].self, forKey: .imageURLs)
        self.imageURLs = imageURLs?.compactMap(\.sourceUrl) ?? []
    }
}
