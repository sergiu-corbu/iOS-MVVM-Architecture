//
//  Checkout+Errors.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.01.2024.
//

import Foundation

struct EmptyInputFieldError: LocalizedError {
    var errorDescription: String? {
        return "Required field"
    }
}

enum CheckoutError: LocalizedError {
    
    case missingCart
    case invalidClientSecret
    case submitOrderFailed
    
    var errorDescription: String? {
        switch self {
        case .missingCart:
            return "The checkout cart is missing or invalid"
        case .invalidClientSecret:
            return "Client Secret is missing or invalid"
        case .submitOrderFailed:
            return "Failed to submit order. Please try again."
        }
    }
}
