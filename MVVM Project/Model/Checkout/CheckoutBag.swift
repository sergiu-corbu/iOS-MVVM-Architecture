//
//  ProductBag.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 14.08.2023.
//

import Foundation

struct CheckoutBag: Decodable {
    let id: Int
    let skus: [CheckoutBagSKU]
    let subTotal: Int
    var discounts: [Discount]?
    var shippingMethod: ShippingMethod?
}

struct CheckoutBagSKU: Decodable {
    let id: Int
    let name: String
    let brand: String?
    let quantity: Int
    let price: Double
    let linePrice: Double
    let thumbnail: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brand
        case quantity
        case price
        case linePrice
        case thumbnail
    }
}

extension CheckoutBagSKU: ProductDisplayable {
    var productName: String {
        return name
    }
    
    var salePrice: Double {
        return price
    }
    
    var retailPrice: Double {
        return linePrice
    }
    
    var brandName: String {
        return brand ?? "N/A"
    }
    
    var productThumbnailURL: URL? {
        return thumbnail
    }
    var seller: String? {
        return nil
    }
}
