//
//  ProductVariant+MockData.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.02.2023.
//

import Foundation

#if DEBUG
extension ProductVariant {
    
    static func colorVariant(_ maxValues: Int = 4) -> ProductVariant {
        ProductVariant(id: .randomID, name: "Color",values: Array([
           .init(id: .randomID, name: "Red", skuIds: []),
           .init(id: .randomID, name: "Blue", skuIds: []),
           .init(id: .randomID, name: "Dark", skuIds: []),
           .init(id: .randomID, name: "White", skuIds: []),
        ].prefix(maxValues)))
    }
    
    static func euSizeVariant(_ maxValues: Int = 4) -> ProductVariant {
        return ProductVariant(id: .randomID, name: "Size",values: Array([
            .init(id: .randomID, name: "M", skuIds: []),
            .init(id: .randomID, name: "S", skuIds: []),
            .init(id: .randomID, name: "XXL", skuIds: []),
            .init(id: .randomID, name: "XS", skuIds: []),
        ].prefix(maxValues)))
    }
    static let imperialSizeVariant = ProductVariant(id: .randomID, name: "Size", values: [
        .init(id: .randomID, name: "US 9", skuIds: []),
        .init(id: .randomID, name: "US 4", skuIds: []),
        .init(id: .randomID, name: "US 10", skuIds: [])
    ])
    
    static let usSizeVariant = ProductVariant(id: .randomID, name: "Size",values: [
        .init(id: .randomID, name: "ONE SIZE: (14 x 15 x 10 CM)", skuIds: [])
    ])
}
#endif
