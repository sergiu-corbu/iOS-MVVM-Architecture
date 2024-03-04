//
//  CheckoutProduct+MockData.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.08.2023.
//

import Foundation

#if DEBUG
extension CheckoutProduct {
    static let prod1 = CheckoutProduct(
        id: UUID().uuidString,
        showID: UUID().uuidString,
        creatorID: UUID().uuidString,
        brandID: UUID().uuidString,
        merchantID: 1,
        name: "Boots with long description and 2 lines",
        description: "Test Description",
        price: 1999, customDiscount: nil,
        currency: "USD",
        sku: ProductSKU(
            id: 1, name: "Variant name",
            merchantID: 1,
            salePrice: 1000,
            retailPrice: 1999,
            albums: [
                ProductSKU.SKUAlbum(
                    id: 1,
                    imageURLs: [
                        URL(string: "https://n.nordstrommedia.com/id/sr3/abd7fedd-f5d6-433f-b72a-5f38123bbfd3.jpeg?h=365&w=240&dpr=2")!
                    ]
                )
            ],
            inStock: "true"
        ),
        albums: [MediaAlbumsResponse(
            id: 1,
            mediaAlbums: [
                MediaAlbum(
                    id: 1,
                    imageURL: URL(string: "https://n.nordstrommedia.com/id/sr3/abd7fedd-f5d6-433f-b72a-5f38123bbfd3.jpeg?h=365&w=240&dpr=2"),
                    displayOrder: 0
                )
            ]
        )],
        vendor: "Vendor Name")
    
    static let prod2 = CheckoutProduct(
        id: UUID().uuidString,
        showID: UUID().uuidString,
        creatorID: UUID().uuidString,
        brandID: UUID().uuidString,
        merchantID: 2,
        name: "Shoes with 2 lines",
        description: "Test Description",
        price: 399, customDiscount: 0.5,
        currency: "USD",
        sku: ProductSKU(
            id: 1, name: "Variant name",
            merchantID: 1,
            salePrice: 300,
            retailPrice: 399,
            albums: [
                ProductSKU.SKUAlbum(
                    id: 1,
                    imageURLs: [
                        URL(string: "https://n.nordstrommedia.com/id/sr3/abd7fedd-f5d6-433f-b72a-5f38123bbfd3.jpeg?h=365&w=240&dpr=2")!
                    ]
                )
            ],
            inStock: "true"
        ),
        albums: [MediaAlbumsResponse(
            id: 1,
            mediaAlbums: [
                MediaAlbum(
                    id: 1,
                    imageURL: URL(string: "https://n.nordstrommedia.com/id/sr3/abd7fedd-f5d6-433f-b72a-5f38123bbfd3.jpeg?h=365&w=240&dpr=2"),
                    displayOrder: 0
                )
            ]
        )],
        vendor: "Vendor Name")
}
#endif
