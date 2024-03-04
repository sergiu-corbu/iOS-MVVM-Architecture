//
//  ShippingMethodSelectionState.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.01.2024.
//

import Foundation

enum ShippingMethodSelectionState {
    
    case calculatedAtNextStep
    case enterShippingAddress
    case calculating
    case shippingMethodSelected(Double)
    
    var description: String {
        switch self {
        case .calculatedAtNextStep: Strings.Payment.howTaxesAreCalculated
        case .enterShippingAddress: Strings.Payment.enterShipping
        case .calculating: Strings.Payment.calculatingShippingCost
        case .shippingMethodSelected(let shippingPrice): shippingPrice.currencyFormatted(isValueInCents: true) ?? "N/A"
        }
    }
    
    var isCalculatingShipping: Bool {
        if case .calculating = self {
            return true
        }
        return false
    }
}
