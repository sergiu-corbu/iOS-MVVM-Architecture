//
//  CheckoutProduct.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.08.2023.
//

import Foundation

struct CheckoutProduct: Decodable {
    
    let id: String
    let showID: String?
    let creatorID: String?
    let brandID: String
    let merchantID: UInt
    
    let name: String
    let description: String
    let price: Double
    let customDiscount: Double?
    
    let currency: String
    let sku: ProductSKU
    let albums: [MediaAlbumsResponse]
    let vendor: String

    enum CodingKeys: String, CodingKey {
        case id
        case showID = "showId"
        case creatorID = "creatorId"
        case brandID = "brandId"
        case merchantID = "merchantId"
        case customDiscount
        case name, description, price, currency, sku, albums, vendor
    }
    
    var baseAnalyticsProperties: AnalyticsProperties {
        var properties = AnalyticsProperties()
        properties[.product_id] = id
        properties[.name] = name
        properties[.brand] = vendor
        properties[.product_image_url] = albums.first?.mediaAlbums.first?.imageURL?.absoluteString
        properties[.quantity] = 1
        return properties
    }
}

extension CheckoutProduct: ProductDisplayable {
    
    var productName: String {
        return name
    }
    var productVariant: String? { //Temporary solution
        guard let variantName = sku.name,
              let separatorIndex = variantName.firstIndex(of: "-") else {
            return nil
        }
        return String(variantName.suffix(from: separatorIndex).dropFirst(2))
    }
    var brandName: String {
        return vendor
    }
    var productThumbnailURL: URL? {
        return sku.mediaUrls.first ?? albums.first?.mediaAlbums.first?.imageURL
    }
    var salePrice: Double {
        return sku.salePrice
    }
    var retailPrice: Double {
        return sku.retailPrice
    }
    var seller: String? {
        return vendor
    }
    var shopifyDiscountValue: Double? {
        salePrice != retailPrice ? salePrice : nil
    }
    
    func inflatedSalePrice(basePrice: Double) -> Double? {
        guard let discount = customDiscount, discount > .zero else {
            return nil
        }
        return basePrice / (1 - discount)
    }
}
