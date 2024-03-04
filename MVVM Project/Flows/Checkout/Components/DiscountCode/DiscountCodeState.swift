//
//  DiscountCodeState.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 10.01.2024.
//

import Foundation

enum DiscountCodeState {
    case idle
    case loading
    case validCode(discount: Discount)
    case invalidCode(discount: Discount)
    case error(error: Error)
    
    var fieldState: DiscountFieldState {
        switch self {
        case .idle, .loading:
            return .idle
        case .validCode:
            return .success(Strings.Payment.discountCodeApplied)
        case .invalidCode:
            return .error(Strings.Payment.invalidDiscountCode)
        case .error(let error):
            return .error(error.localizedDescription)
        }
    }
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}
