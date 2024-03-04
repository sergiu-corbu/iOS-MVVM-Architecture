//
//  CustomVariantSorting.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.12.2023.
//

import Foundation

protocol CustomSortable {
    var value: String { get }
}

enum CustomVariantSortingType {
    
    case us
    case imperial
    case imperialExplicit
    case numeric
    case standard
    
    static let imperialSizePatterns = ["XXS": 0, "XS": 1, "S": 2, "M": 3, "L": 4, "XL": 5, "XXL": 6, "XXXL": 7]
    static let imperialExplicitSizePatterns = ["X-SMALL": 0, "SMALL": 1, "MEDIUM": 2, "LARGE": 3, "X-LARGE": 4]
    
    init(value: String) {
        if Int(value) != nil || Double(value) != nil {
            self = .numeric
        } else if Self.imperialSizePatterns[value] != nil {
            self = .imperial
        } else if Self.imperialExplicitSizePatterns[value] != nil {
            self = .imperialExplicit
        } else if value.numberFromString() != nil {
            self = .us
        } else {
            self = .standard
        }
    }
}

extension Array where Element: CustomSortable {
    
    func sortedByVariantType() -> Self {
        guard self.count > 1 else {
            return self
        }
        
        return sorted(by: { first, second in
            let sortingType = CustomVariantSortingType(value: first.value)
            switch sortingType {
            case .us:
                if let firstIntValue = first.value.numberFromString(),
                   let secondIntValue = second.value.numberFromString() {
                    return firstIntValue < secondIntValue
                }
            case .imperial:
                if let firstIndex = CustomVariantSortingType.imperialSizePatterns[first.value],
                   let secondIndex = CustomVariantSortingType.imperialSizePatterns[second.value] {
                    return firstIndex < secondIndex
                }
            case .imperialExplicit:
                if let firstIndex = CustomVariantSortingType.imperialExplicitSizePatterns[first.value],
                   let secondIndex = CustomVariantSortingType.imperialExplicitSizePatterns[second.value] {
                    return firstIndex < secondIndex
                }
            case .numeric:
                if let firstIntValue = Int(first.value),
                   let secondIntValue = Int(second.value) {
                    return firstIntValue < secondIntValue
                } else {
                    if let firstDoubleValue = Double(first.value),
                       let secondDoubleValue = Double(second.value) {
                        return firstDoubleValue < secondDoubleValue
                    }
                }
            case .standard:
                return first.value < second.value
            }
            return false
        })
    }
}
