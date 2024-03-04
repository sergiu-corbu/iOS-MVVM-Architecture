//
//  CheckoutSectionType.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 30.12.2023.
//

import Foundation

enum CheckoutSectionType: Int {
    case shippingAddress
    case billingAddress
    case paymentDetails
    
    var title: String {
        switch self {
        case .shippingAddress: Strings.Payment.shippingAddress.capitalized
        case .billingAddress: Strings.Payment.billingAddress.capitalized
        case .paymentDetails: Strings.Payment.paymentDetails.capitalized
        }
    }
    
    var editableTitle: String {
        return "Edit " + title
    }
    
    var subtitle: String? {
        if case .paymentDetails = self {
            return Strings.Payment.transactionSecurityInformation
        }
        return nil
    }
}

enum CheckoutProgressSection: Int, CaseIterable {
    case customerInfoAndShipping
    case paymentAndBilling
    case orderReview
}
