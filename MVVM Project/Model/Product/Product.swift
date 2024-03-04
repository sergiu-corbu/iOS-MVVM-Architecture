//
//  Product.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.12.2022.
//

import Foundation

struct Product: Decodable, Hashable, StringIdentifiable, ImageDownloadable {
    
    let id: String
    let name: String
    let type: EccomerceType?
    let brand: Brand
    let isFavorite: Bool
    let seller: String?
    let description: String
    let maxPrice: Double
    let minPrice: Double
    let mediaAlbums: [MediaAlbum]?
    let variants: [ProductVariant]
    
    //Nil for affiliate product
    let skus: [ProductSKU]?
    let merchantID: UInt?
    
    // Affiliate product properties
    var externalLink: URL?
    private var customDiscount: Double? // Is set in admin
    
    // This method "bumps" the real price to simulate a fake discount. 
    func inflatedSalePrice(basePrice: Double) -> Double? {
        guard let discount = customDiscount, discount > .zero else {
            return nil
        }
        return basePrice / (1 - discount)
    }
    
    var discountPercentage: Double? {
        if let customDiscount = customDiscount {
            return customDiscount * 100
        } else if salePrice != retailPrice {
            return (1 - salePrice / retailPrice) * 100
        }
        return nil
    }
    
    var shopifyDiscountValue: Double? {
        salePrice != retailPrice ? salePrice : nil
    }
    
    var imageSize: CGSize = .zero
    var imageAspectRatio: CGFloat? {
        return imageSize.height == .zero ? nil : imageSize.width / imageSize.height
    }
    
    var primaryMediaImageURL: URL? {
        mediaAlbums?.sorted(by: <).first?.imageURL
    }
    var sortedMediaAlbumURLs: [URL]? {
        return mediaAlbums?.sorted(by: <).compactMap(\.imageURL)
    }
    
    var downloadURL: URL? {
        return primaryMediaImageURL
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case merchantID = "merchantId"
        case name
        case type
        case externalLink
        case brand = "brandCache"
        case seller
        case maxPrice
        case minPrice
        case albums
        case variants
        case description
        case skus
        case isFavorite
        case customDiscount
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    var shareableObject: ShareableObject {
        ShareableObject(
            objectID: id, type: .product,
            shareName: name,
            shareBrand: brandName, redirectURL: Constants.AppsFlyer.REDIRECT_URL?.appendingPathComponent("products/\(id)")
        )
    }
    
    static var sampleProduct: Product {
        Product(id: UUID().uuidString, name: "Relaxed Jeans", type: .contracted, brand: .init(name: "Gucci"), isFavorite: true, seller: "Gucci Store", description: "Some description", maxPrice: 10, minPrice: .random(in: 10..<1000), mediaAlbums: [.init(id: 0, imageURL: .sampleImageURL, displayOrder: 0)], variants: [], skus: [], merchantID: nil)
    }
}

enum EccomerceType: String, Codable {
    case affiliate // should open externally
    case contracted
  }

extension Product {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.merchantID = try container.decodeIfPresent(UInt.self, forKey: .merchantID)
        self.name = try container.decode(String.self, forKey: .name)
        if let productTypeString = try container.decodeIfPresent(String.self, forKey: .type) {
            self.type = EccomerceType(rawValue: productTypeString)
            self.externalLink = try container.decodeIfPresent(URL.self, forKey: .externalLink)
        } else {
            self.type = .contracted
        }
        self.seller = try container.decodeIfPresent(String.self, forKey: .seller)
        self.maxPrice = try container.decode(Double.self, forKey: .maxPrice)
        self.minPrice = try container.decode(Double.self, forKey: .minPrice)
        self.customDiscount = try container.decodeIfPresent(Double.self, forKey: .customDiscount)
        self.brand = try container.decode(Brand.self, forKey: .brand)
        self.description = try container.decode(String.self, forKey: .description)
        self.variants = (try? container.decode([ProductVariant].self, forKey: .variants)) ?? []
        self.skus = try container.decodeIfPresent([ProductSKU].self, forKey: .skus)
        self.isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        var albumsContainer = try container.nestedUnkeyedContainer(forKey: .albums)
        self.mediaAlbums = try albumsContainer.decodeIfPresent(MediaAlbumsResponse.self)?.mediaAlbums
    }
}

extension Product: Equatable {
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    var baseAnalyticsProperties: AnalyticsProperties {
        var properties = AnalyticsProperties()
        properties[.product_id] = id
        properties[.name] = name
        properties[.brand] = brand.name
        properties[.product_image_url] = primaryMediaImageURL?.absoluteString
        properties[.quantity] = 1
        return properties
    }
}

protocol ProductDisplayable {
    
    var productName: String { get }
    var productVariant: String? { get }
    var salePrice: Double { get }
    var retailPrice: Double { get }
    var brandName: String { get }
    var seller: String? { get }
    var productThumbnailURL: URL? { get }
    
    ///Note: The discount is set in the admin panel, and has lower priority than shopify discount
    func inflatedSalePrice(basePrice: Double) -> Double?
    var shopifyDiscountValue: Double? { get }
}

extension ProductDisplayable {
    
    var productVariant: String? {
        return nil
    }
    func inflatedSalePrice(basePrice: Double) -> Double? {
        return nil
    }
    var shopifyDiscountValue: Double? {
        return nil
    }
}

extension Product: ProductDisplayable {
    
    var productName: String {
        return name
    }
    var brandName: String {
        return brand.name
    }
    var productThumbnailURL: URL? {
        return primaryMediaImageURL
    }
    var salePrice: Double {
        return skus?.first?.salePrice ?? maxPrice
    }
    var retailPrice: Double {
        return skus?.first?.retailPrice ?? maxPrice
    }
}

struct PurchasedProduct: Decodable, Hashable, ProductDisplayable {
    let id: String
    var name: String
    let brand: Brand
    let price: Double
    let albums: [ProductSKU.SKUAlbum]
    var seller: String? = nil
    
    var productVariantImageURL: URL? {
        return albums.first?.imageURLs.first
    }
    var productName: String {
        return name
    }
    var brandName: String {
        return brand.name
    }
    var productThumbnailURL: URL? {
        return productVariantImageURL
    }
    var salePrice: Double {
        return price
    }
    var retailPrice: Double {
        return price
    }
}

struct ProductCategory: Decodable, Hashable {
    
    let id: String
    let violetId: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case violetId
        case name
    }
}

#if DEBUG
extension ProductCategory {
    
    init(name: String) {
        self.id = UUID().uuidString
        self.violetId = UUID().uuidString
        self.name = name
    }
    
    static var mockedCategories: [Self] {
        return [ProductCategory(name: "Dresses"),ProductCategory(name: "Shorts"),ProductCategory(name: "Outware"),ProductCategory(name: "Sunglasses"),ProductCategory(name: "T-shirts")]
    }
}
#endif

struct ProductWrapper: Decodable, Hashable, StringIdentifiable {
    
    let id: String
    let publishDate: Date?
    var product: Product
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case publishDate = "publishingDate"
        case product
    }
}

extension ProductWrapper: ImageDownloadable {
    
    init(product: Product) {
        self.id = product.id
        self.publishDate = nil
        self.product = product
    }
    
    var downloadURL: URL? {
        return product.primaryMediaImageURL
    }
    
    var imageSize: CGSize {
        get {
            return product.imageSize
        }
        set {
            product.imageSize = newValue
        }
    }
}

#if DEBUG
extension ProductWrapper {
 
    static let publishedProduct1 = ProductWrapper(id: UUID().uuidString, publishDate: .now, product: Product.prod1)
    static let publishedProduct2 = ProductWrapper(id: UUID().uuidString, publishDate: .now, product: Product.prod2)
    
    static var all: [Self] {
        [publishedProduct1, publishedProduct2]
    }
}
#endif
