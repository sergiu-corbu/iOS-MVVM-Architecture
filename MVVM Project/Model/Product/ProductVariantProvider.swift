//
//  ProductVariantProvider.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.02.2023.
//

import Foundation

struct ProductVariantSection {
    
    let id: UInt
    let sectionTitle: String
    let sectionItems: [SectionItem]
    
    struct SectionItem: Hashable, CustomSortable {
        let valueID: UInt
        let value: String
        
        init(variantValue: ProductVariantValue) {
            self.valueID = variantValue.id
            self.value = variantValue.name.uppercased()
        }
        
    }
}

class ProductVariantProvider {
    
    private(set) var product: Product
    /**
     Contains an array of maps. Each map contains data for one variant of the product.
     In the context of the map, each key represents the sku id of a product that has the associated variant
     [
        [skuID1:  Red, skuID2:  Green, skuID3 :  Blue], // Color map
        [skuID1:  Wool, skuID2:  Wood, skuID3 : Cotton] // Material map
     ]
     */
    
    typealias SKUIdValueMap = [UInt:ProductVariantValue]
    private(set) var skuIdValueMaps: [SKUIdValueMap] = []
    
    /**
     Contains a map. Each key represents the id a value the variant can take
    [redValueID:  Color, blueValueID:  Color, cottonValueID: Material]
     */
    private(set) var valueVariantMap: [UInt : ProductVariant] = [:]
    
    private(set) var productVariants: [ProductVariant] = []
    private(set) var skusById: [UInt : ProductSKU] = [:]
    private(set) var variantValuesByID: [UInt: ProductVariantValue] = [:]

    init(product: Product) {
        self.product = product
        self.processProductData()
    }
    
    func availableSKUIDs(for variant: ProductVariant, selectedVariantValues: [ProductVariantValue]) -> OrderedSet<UInt> {
        var availableSKUIds: OrderedSet<UInt> = OrderedSet(skusById.keys.map({ $0 }))
        selectedVariantValues.forEach { variantValue in
            if variant.id == valueVariantMap[variantValue.id]?.id {
                return
            }
            availableSKUIds = availableSKUIds.intersection(variantValue.skuIds)
        }
        
        return availableSKUIds
    }
    
    func availableSKUIds(selectedVariantValues: [ProductVariantValue]) -> Set<UInt> {
        guard let firstValue = selectedVariantValues.first else {
            return Set()
        }
        
        let initialSet = Set(firstValue.skuIds)
        let skuIDs = selectedVariantValues.dropFirst().reduce(into: initialSet) { partialResult, value in
            partialResult = partialResult.intersection(value.skuIds)
        }
        return skuIDs
    }
}

//MARK: Helpers
private extension ProductVariantProvider {
    
    func processProductData() {
        skusById = Dictionary(uniqueKeysWithValues: (product.skus ?? []).map { ($0.id, $0) })
        
        if product.variants.isEmpty {
            return
        }
        
        let availableVariants = product.variants.sorted(by: { $0.isPrimary && !$1.isPrimary })
        self.productVariants = availableVariants
        
        var maps: [SKUIdValueMap] = []
        availableVariants.forEach { productVariant in
            var valueMap: SKUIdValueMap = [:]
            
            productVariant.values.forEach { variantValue in
                variantValuesByID[variantValue.id] = variantValue
                valueVariantMap[variantValue.id] = productVariant
                variantValue.skuIds.forEach { skuID in
                    valueMap[skuID] = variantValue
                }
            }
            maps.append(valueMap)
        }
        
        skuIdValueMaps = maps
    }
}
