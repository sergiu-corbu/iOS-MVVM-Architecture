//
//  ProductVariantsSelectionViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.08.2023.
//

import Foundation
import SwiftUI

class ProductVariantsSelectionViewModel: ObservableObject {
    
    private var product: Product
    private var productVariantProvider: ProductVariantProvider
    
    @Published private(set) var availableVariantSections: [ProductVariantSection] = []
    @Published private(set) var selectedVariantValues: [ProductVariantValue] = []
    var currentProductSKU: ProductSKU? {
        if product.skus?.count == 1, let uniqueSKU = product.skus?.first {
            return uniqueSKU
        }
        
        let skuIds = productVariantProvider.availableSKUIds(selectedVariantValues: selectedVariantValues)
        if skuIds.count == 1, let currentProductSKUId = skuIds.first {
            return productVariantProvider.skusById[currentProductSKUId]
        } else {
            return nil
        }
    }
    var selectedVariantMediaURLs: [URL]? {
        if selectedVariantValues.isEmpty {
            return nil
        }
        
        let skuIds = productVariantProvider.availableSKUIds(selectedVariantValues: selectedVariantValues)
        if let firstSKUId = skuIds.first {
            let sku = productVariantProvider.skusById[firstSKUId]
            return sku?.mediaUrls
        }
        
        return nil
    }
    
    var didSelectAllVariants: Bool {
        return selectedVariantValues.count == availableVariantSections.count
    }
    var availableVariants: [ProductVariant] {
        return productVariantProvider.productVariants
    }
    var customPrices: CustomPrices? {
        return (currentProductSKU?.salePrice, currentProductSKU?.retailPrice)
    }
    
    init(product: Product) {
        self.product = product
        productVariantProvider = ProductVariantProvider(product: product)
        configureVariantSections()
    }
    
    func configureVariantSections() {
        resetDefaultVariantSelection()
        setupVariantSections()
    }
    
    func setupVariantSections() {
        if productVariantProvider.productVariants.isEmpty {
            availableVariantSections = []
            return
        }
        var sections = [ProductVariantSection]()
        for (index, variant) in productVariantProvider.productVariants.enumerated() {
            let section = computeSectionItem(variant: variant, variantIndex: index, sortOrder: index == 0 ? nil : .reverse)
            sections.append(section)
        }
        availableVariantSections = sections
    }
    
    func resetDefaultVariantSelection() {
        guard let topVariant = productVariantProvider.productVariants.first else {
            return
        }
        
        var variantValues = topVariant.values
        if topVariant.isPrimary == false {
            variantValues = variantValues.sortedByVariantType()
        }
        
        if let firstValue = variantValues.first {
            selectedVariantValues = [firstValue]
        }
    }
    
    func computeSectionItem(variant: ProductVariant, variantIndex: Int, sortOrder: SortOrder? = nil) -> ProductVariantSection {
        let skuIds = productVariantProvider.availableSKUIDs(for: variant, selectedVariantValues: selectedVariantValues)
        let skuIdValueMap = productVariantProvider.skuIdValueMaps[variantIndex]
        let availableValues = OrderedSet(skuIds.compactMap({ skuIdValueMap[$0] }))
        let sectionValues: OrderedSet<ProductVariantValue>
        if let sortOrder {
            sectionValues = OrderedSet(availableValues.sorted(using: KeyPathComparator(\.name, order: sortOrder)))
        } else { // make sure we display items in the order they are received from the backend
            sectionValues = OrderedSet(variant.values.filter({ availableValues.contains($0) }))
        }
        let sectionItems = sectionValues.map({ ProductVariantSection.SectionItem(variantValue: $0) })
        
        return ProductVariantSection(id: variant.id, sectionTitle: variant.name.capitalized, sectionItems: sectionItems)
    }
    
    // MARK: - Value Selection
    
    func updateSelectedValues(_ selectedValueId: UInt, at index: Int) {
        guard let variant = productVariantProvider.valueVariantMap[selectedValueId] else {
            return
        }
        
        guard let selectedValue = productVariantProvider.variantValuesByID[selectedValueId] else {
            return
        }
        
        if index == 0 { // reset selection
            selectedVariantValues = [selectedValue]
            setupVariantSections()
        } else {
            var strippedVariantValues = selectedVariantValues.filter { variant.id != productVariantProvider.valueVariantMap[$0.id]?.id }
            strippedVariantValues.append(selectedValue)
            selectedVariantValues = strippedVariantValues
            setupVariantSections()
        }
    }
    
    func getSelectedVariantValueID(at index: Int) -> UInt? {
        let selectedVariantValue = selectedVariantValues.first { availableVariants[safe: index]?.id == productVariantProvider.valueVariantMap[$0.id]?.id }
        return selectedVariantValue?.id
    }
}
