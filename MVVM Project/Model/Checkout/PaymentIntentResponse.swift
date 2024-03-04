//
//  PaymentIntent.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 21.02.2023.
//

import Foundation
import Stripe

struct PaymentIntentResponse: Decodable {
    
    let productCart: CheckoutCart
    let shippingMethods: [ShippingMethodsResponse]?
    
    enum CodingKeys: String, CodingKey {
        case productCart = "data"
        case shippingMethods
    }
}

struct PaymentIntent: Decodable {
    
    let intentID: Int
    let customer: Customer
    let shippingAddress: ShippingAddress
    let billingAddress: BillingAddress
    let itemsPrice: Double
    let shippingPrice: Double
    let totalPrice: Double
    let taxes: Double
    let currency: String
    let clientSecret: String
    
    enum CodingKeys: String, CodingKey {
        case intentID = "violetCartId"
        case customer
        case shippingAddress = "shippingAddress"
        case billingAddress
        case itemsPrice = "subTotal"
        case shippingPrice = "shippingTotal"
        case totalPrice = "total"
        case taxes = "taxTotal"
        case currency
        case clientSecret = "paymentIntentClientSecret"
    }
}

#if DEBUG
extension PaymentIntent {
    
    static let sampleIntent = PaymentIntent(
        intentID: 1, customer: .sampleCustomer, shippingAddress: .sampleAddress, billingAddress: .sampleAddress,
        itemsPrice: 120, shippingPrice: 29, totalPrice: 149, taxes: 10, currency: "USD",
        clientSecret: ""
    )
}
#endif

struct PurchaseableProduct {
    let productID: String
    let skuID: UInt
    let merchantID: UInt
    let name: String
    let brandName: String
    let price: Double
}

extension PurchaseableProduct {
    
    init(checkoutProduct: CheckoutProduct, price: Double) {
        self.productID = checkoutProduct.id
        self.skuID = checkoutProduct.sku.id
        self.merchantID = checkoutProduct.merchantID
        self.name = checkoutProduct.name
        self.brandName = checkoutProduct.brandName
        self.price = price
    }
}
