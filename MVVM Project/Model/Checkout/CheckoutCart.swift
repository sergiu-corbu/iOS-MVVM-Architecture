//
//  ProductCart.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.08.2023.
//

import Foundation

struct CheckoutCart: Decodable {
    
    let violetCartId: UInt
    let bags: [CheckoutBag]
    let products: [CheckoutProduct]
    let subTotal: Double
    let shippingTotal: Double?
    let discountTotal: Double
    let total: Double?
    let taxTotal: Double?
    let currency: String?
    let paymentIntentClientSecret: String?
    let stripeKey: String?

    let shippingAddress: ShippingAddress?
    let billingAddress: BillingAddress?
    
    var vendorName: String {
        return products.first?.vendor ?? ""
    }
    var merchantID: UInt {
        return products.first?.merchantID ?? 0
    }
    var discount: Discount? {
        let validDiscountCode = bags.first?.discounts?.first(where: { $0.status == .applied })
        return validDiscountCode ?? bags.first?.discounts?.first
    }
    var selectedShippingMethodID: String? {
        return bags.first?.shippingMethod?.shippingMethodId
    }
}

#if DEBUG
extension CheckoutCart {
    static let sampleCart = CheckoutCart(
        violetCartId: 1,
        bags: [CheckoutBag.init(
            id: 1,
            skus: [CheckoutBagSKU.init(
                id: 1,
                name: "test",
                brand: "Brand",
                quantity: 1,
                price: 2423,
                linePrice: 2100,
                thumbnail: URL(string: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c2hvZXN8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=800&q=60")
            )],
            subTotal: 2500)],
        products: [CheckoutProduct.prod1, .prod2],
        subTotal: 4000,
        shippingTotal: 200,
        discountTotal: Double.random(in: 1..<100),
        total: 4800,
        taxTotal: 600,
        currency: "USD",
        paymentIntentClientSecret: nil, stripeKey: nil,
        shippingAddress: .sampleAddress,
        billingAddress: .sampleAddress
    )
}
#endif

