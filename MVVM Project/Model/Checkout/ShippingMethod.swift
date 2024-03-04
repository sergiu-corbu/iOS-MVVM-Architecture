//
//  ShippingMethod.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 21.02.2023.
//

import Foundation

struct ShippingMethodsResponse: Decodable {
    let bagId: Int
    let shippingMethods: [ShippingMethod]
}

struct ShippingMethod: Decodable, Hashable {
    
    let shippingMethodId: String
    let label: String
    let carrier: String
    let price: Double
}

extension ShippingMethod {
    
    static let economy = ShippingMethod(shippingMethodId: UInt.randomID.description, label: "Economy", carrier: "FedEx", price: 320)
    static let standard = ShippingMethod(shippingMethodId: UInt.randomID.description, label: "Standard", carrier: "DHL", price: 120)
}
