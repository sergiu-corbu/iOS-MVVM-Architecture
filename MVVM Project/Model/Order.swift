//
//  Order.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.04.2023.
//

import Foundation

struct Order: Decodable, Hashable, Identifiable {
    
    let id: String
    let orderNumber: Int
    let orderDate: Date
    let cartEntries: [CartEntry]
    let products: [PurchasedProduct]
    let shippingAddress: ShippingAddress
    
    //only one cart entry supported
    var cartEntry: CartEntry? {
        return cartEntries.first
    }
    var orderedItem: CartEntry.OrderedItem? {
        return cartEntry?.orderedItems.first
    }
    var purchasedProduct: PurchasedProduct? {
        return products.first
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case shippingAddress
        case orderDate = "createdAt"
        case cartEntries = "bags"
        case orderNumber = "violetCartId"
        case products
    }
}

struct CartEntry: Decodable, Hashable {
    
    let orderedItems: [OrderedItem]
    let shippingPrice: Double
    let taxValue: Double
    let itemsPrice: Double
    let totalPrice: Double
    
    
    enum CodingKeys: String, CodingKey {
        case orderedItems = "skus"
        case shippingPrice = "shippingTotal"
        case taxValue = "taxTotal"
        case itemsPrice = "subTotal"
        case totalPrice = "total"
    }
    
    struct OrderedItem: Decodable, Hashable {
        let name: String
        let quantity: Int
        let thumbnail: URL?
        let price: Double
    }
}

#if DEBUG
extension Order {
    
    static let mockOrder = Order(id: UUID().uuidString,
                                 orderNumber: .random(in: 100...1000),
                                 orderDate: Date.now.adding(component: .day, value: .random(in: 1...20)),
                                 cartEntries: [.mockCartEntry],
                                 products: [
                                    PurchasedProduct(id: UUID().uuidString, name: "Test product", brand: .gucci, price: 1003, albums: [ProductSKU.SKUAlbum(id: 0, imageURLs: [.sampleImageURL])]),
                                    PurchasedProduct(id: UUID().uuidString, name: "Random long name", brand: .armani, price: 6000, albums: [], seller: nil)
                                 ], shippingAddress: .sampleAddress
                            )
}

extension CartEntry {
    
    static let mockCartEntry = CartEntry(orderedItems: [CartEntry.OrderedItem.mockOrderedItem], shippingPrice: 29.99, taxValue: 0, itemsPrice: 450, totalPrice: 479.99)
}

extension CartEntry.OrderedItem {
    
    static let mockOrderedItem = CartEntry.OrderedItem(name: "Gucci jeans with smooth material", quantity: 1, thumbnail: .sampleImageURL, price: 450)
}
#endif
