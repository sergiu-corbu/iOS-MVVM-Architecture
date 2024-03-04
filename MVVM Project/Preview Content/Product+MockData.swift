//
//  Product+MockData.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.12.2022.
//

import Foundation

#if DEBUG
extension Product {
    
    static let prod1 = Product(
        name: "Boots with long description and 2 lines",
        merchantID: 1,
        brand: .bottegaVeneta,
        description: "some description",
        price: 1999,
        imageUrl: URL(string: "https://n.nordstrommedia.com/id/sr3/abd7fedd-f5d6-433f-b72a-5f38123bbfd3.jpeg?h=365&w=240&dpr=2"),
        variants: [ProductVariant.euSizeVariant(3), .colorVariant(2)]
    )
    static let prod2 = Product(
        name: "Shoes",
        merchantID: 2,
        brand: .armani,
        description: "some description",
        price: 390,
        imageUrl: URL(string: "https://www.armani.com/variants/images/17411127375631998/D/w400.jpg"),
        variants: [ProductVariant.euSizeVariant(3), .colorVariant(2)]
    )
    static let prod3 = Product(
        name: "Hat",
        merchantID: 3,
        brand: .baldinini,
        description: "some description",
        price: 99,
        imageUrl: URL(string: "https://img.eobuwie.cloud/eob_product_656w_656h(7/a/8/e/7a8eaff2e438d1715bf58f219f70add4436597bd_0003735690167_4_.jpg,jpg)/palarie-baldinini-l2d102felt4185-feltro-cammello.jpg"),
        variants: [ProductVariant.euSizeVariant(2), .colorVariant(3)]
    )
    static let prod4 = Product(
        name: "Black Jeans with flexible material",
        merchantID: 4,
        brand: .robertoCavalli,
        description: "some description",
        price: 400,
        imageUrl: URL(string: "https://dqzrr9k4bjpzk.cloudfront.net/default-store/0006-1.jpg")
    )
    static let prod5 = Product(
        name: "Blazer",
        merchantID: 5,
        brand: .gucci,
        description: "some description",
        price: 2499,
        imageUrl: URL(string: "https://cdn-images.farfetch-contents.com/17/46/00/03/17460003_36218357_300.jpg")
    )
    static let prod6 = Product(
        name: "Shoes",
        merchantID: 6,
        brand: .ralphLauren,
        description: "some description",
        price: 199,
        imageUrl: URL(string: "https://dqzrr9k4bjpzk.cloudfront.net/default-store/0009-1000.jpg")
    )
    static let prod7 = Product(
        name: "Bag",
        merchantID: 7,
        brand: .gucci,
        description: "some description",
        price: 230,
        imageUrl: URL(string: "https://dqzrr9k4bjpzk.cloudfront.net/default-store/0008-1000.jpg")
    )
    static let prod8 = Product(
        name: "Bag",
        merchantID: 8,
        brand: .armani,
        description: "some description",
        price: 230,
        imageUrl: URL(string: "https://dqzrr9k4bjpzk.cloudfront.net/images/13101742/956637934.jpg")
    )
    
    //used only for mocked data
    init(name: String, merchantID: UInt, brand: Brand, description: String, price: Double, imageUrl: URL?, variants: [ProductVariant] = []) {
        self.id = UUID().uuidString
        self.merchantID = merchantID
        self.name = name
        self.maxPrice = price
        self.minPrice = price - Double.random(in: 0..<price)
        self.brand = brand
        self.description = "Some description"
        self.mediaAlbums = [MediaAlbum(id: UInt.random(in: 0...10), imageURL: imageUrl, displayOrder: 0)]
        self.variants = variants
        self.skus = []
        self.isFavorite = .random()
        self.seller = "Store seller"
        self.type = nil
    }
    
    static var all: [Self] {
        [prod1,prod2,prod3, prod4, prod5, prod6, prod7, prod8]
    }
}

extension ProductCategory {
    
    static let basics = ProductCategory(name: "Basics")
    static let jeans = ProductCategory(name: "Jeans")
    static let sweaters = ProductCategory(name: "Sweaters")
    static let dresses = ProductCategory(name: "Dresses")
    static let outwear = ProductCategory(name: "Outwear")
    
    static var all: [Self] {
        [basics, jeans, sweaters, dresses, outwear]
    }
}
#endif
