//
//  CheckoutService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.08.2023.
//

import Foundation

typealias ShippingMethodUpdateDetail = (paymentIntentID: Int, shippingMethodID: String)

protocol CheckoutServiceProtocol {
    
    func getCurrentCart(cartID: UInt?) async throws -> CheckoutCart?
    func createCart(creatorId: String?, showId: String?, skuId: UInt) async throws -> CheckoutCart
    func applyDiscount(cartId: UInt, code: String, merchantId: UInt) async throws -> CheckoutCart
    func removeDiscount(cartId: UInt, discountId: UInt) async throws -> CheckoutCart
    func addProductToCart(cartId: UInt, skuId: UInt) async throws -> CheckoutCart
    func removeProductFromCart(cartId: UInt, skuId: UInt) async throws -> CheckoutCart
    func createPaymentIntent(cartId: UInt, shippingAddress: ShippingAddress?) async throws -> PaymentIntentResponse
    func getShippingMethods(cartId: UInt) async throws -> [ShippingMethodsResponse]
    func updateShippingMethod(cartId: UInt, _ shippingDetails: [ShippingMethodUpdateDetail]) async throws -> CheckoutCart
    func updateCartDetails(cartId: UInt, shippingAddress: ShippingAddress?, saveShippingAddress: Bool?, billingAddress: BillingAddress?, customer: Customer?) async throws -> CheckoutCart
    func submitCart(_ productCartId: UInt, shippingAddress: ShippingAddress?, billingAddress: BillingAddress?, customer: Customer?) async throws -> CheckoutCart
    func deleteCart(cartId: UInt) async throws
}

class CheckoutService: CheckoutServiceProtocol {
    
    let client: HTTPClient
    private let encoder = JSONEncoder()
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func getCurrentCart(cartID: UInt?) async throws -> CheckoutCart? {
        let request = HTTPRequest(
            method: .get,
            path: "v2/checkout/\(cartID?.description ?? " ")",
            decodingKeyPath: "data"
        )
        return try await client.sendRequest(request)
    }
    
    func createCart(creatorId: String?, showId: String?, skuId: UInt) async throws -> CheckoutCart {
        var parameters: [String:Any] = ["skuId": skuId]
        parameters["creatorId"] = creatorId
        parameters["showId"] = showId
        let request = HTTPRequest(method: .post, path: "v2/checkout/cart", bodyParameters: parameters, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func applyDiscount(cartId: UInt, code: String, merchantId: UInt) async throws -> CheckoutCart {
        let parameters: [String:Any] = ["code": code,
                                        "merchantId": merchantId]
        let request = HTTPRequest(method: .post, path: "v2/checkout/\(cartId)/discounts", bodyParameters: parameters, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func removeDiscount(cartId: UInt, discountId: UInt) async throws -> CheckoutCart {
        let request = HTTPRequest(method: .delete, path: "v2/checkout/\(cartId)/discounts/\(discountId)", decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func addProductToCart(cartId: UInt, skuId: UInt) async throws -> CheckoutCart {
        let parameters: [String:Any] = ["skuId": skuId]
        let request = HTTPRequest(method: .post, path: "v2/checkout/\(cartId)/add-product", bodyParameters: parameters, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func removeProductFromCart(cartId: UInt, skuId: UInt) async throws -> CheckoutCart {
        let parameters: [String:Any] = ["skuId": skuId]
        let request = HTTPRequest(method: .delete, path: "v2/checkout/\(cartId)/remove-product", bodyParameters: parameters, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func createPaymentIntent(cartId: UInt, shippingAddress: ShippingAddress?) async throws -> PaymentIntentResponse {
        var params = [String: Any]()
        if let shippingAddress {
            params = try encoder.encodeToHashMap(shippingAddress) ?? [:]
        }
        let request = HTTPRequest(method: .post, path: "v2/checkout/\(cartId)/payment", bodyParameters: params)
        return try await client.sendRequest(request)
    }
    
    func getShippingMethods(cartId: UInt) async throws -> [ShippingMethodsResponse] {
        let request = HTTPRequest(method: .get, path: "v2/checkout/\(cartId)/shipping-methods", decodingKeyPath: "shippingMethods")
        return try await client.sendRequest(request)
    }
    
    func updateCartDetails(
        cartId: UInt,
        shippingAddress: ShippingAddress?,
        saveShippingAddress: Bool?,
        billingAddress: BillingAddress?,
        customer: Customer?
    ) async throws -> CheckoutCart {
        
        var parameters = [String: Any]()
        if let shippingAddress {
            parameters["shippingAddress"] = try encoder.encodeToHashMap(shippingAddress)
        }
        if let billingAddress {
            parameters["billingAddress"] = try encoder.encodeToHashMap(billingAddress)
        }
        if let customer {
            parameters["customer"] = try encoder.encodeToHashMap(customer)
        }
        parameters["saveAddress"] = saveShippingAddress
        let request = HTTPRequest(
            method: .put, path: "v2/checkout/\(cartId)/addresses",
            bodyParameters: parameters,
            decodingKeyPath: "data"
        )
        
        return try await client.sendRequest(request)
    }
    
    func updateShippingMethod(cartId: UInt, _ shippingDetails: [ShippingMethodUpdateDetail]) async throws -> CheckoutCart {
        var shippingParameters: [[String:Any]] = []
        for shippingDetail in shippingDetails {
            shippingParameters.append(["bagId": shippingDetail.paymentIntentID, "shippingMethodId": shippingDetail.shippingMethodID])
        }
        
        let request = HTTPRequest(
            method: .put, path: "v2/checkout/\(cartId)/shipping-methods",
            bodyParameters: ["shippingMethods": shippingParameters],
            decodingKeyPath: "data"
        )
        
        return try await client.sendRequest(request)
    }
    
    func submitCart(_ productCartId: UInt, shippingAddress: ShippingAddress?, billingAddress: BillingAddress?, customer: Customer?) async throws -> CheckoutCart {
        var addressParameters = [String: Any]()
        if let shippingAddress {
            addressParameters["shippingAddress"] = try encoder.encodeToHashMap(shippingAddress)
        }
        if let billingAddress {
            addressParameters["billingAddress"] = try encoder.encodeToHashMap(billingAddress)
        }
        if let customer {
            addressParameters["customer"] = try encoder.encodeToHashMap(customer)
        }
        
        let request = HTTPRequest(method: .post, path: "v2/checkout/\(productCartId)/submit", bodyParameters: addressParameters, decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
    
    func deleteCart(cartId: UInt) async throws {
        let request = HTTPRequest(method: .delete, path: "v2/checkout/\(cartId)")
        return try await client.sendRequest(request)
    }
}

#if DEBUG
struct MockCheckoutService: CheckoutServiceProtocol {
    
    func getCurrentCart(cartID: UInt?) async throws -> CheckoutCart? {
        await Task.debugSleep()
        return .sampleCart
    }
    
    func createCart(creatorId: String?, showId: String?, skuId: UInt) async throws -> CheckoutCart {
        await Task.debugSleep()
        return .sampleCart
    }
    
    func applyDiscount(cartId: UInt, code: String, merchantId: UInt) async throws -> CheckoutCart {
        await Task.debugSleep()
        return .sampleCart
    }
    func removeDiscount(cartId: UInt, discountId: UInt) async throws -> CheckoutCart {
        await Task.debugSleep()
        return .sampleCart
    }
    func updateShippingMethod(cartId: UInt, _ shippingDetails: [ShippingMethodUpdateDetail]) async throws -> CheckoutCart {
        return .sampleCart
    }
    func updateCartDetails(cartId: UInt, shippingAddress: ShippingAddress?, saveShippingAddress: Bool?, billingAddress: BillingAddress?, customer: Customer?) async throws -> CheckoutCart {
        return .sampleCart
    }
    func addProductToCart(cartId: UInt, skuId: UInt) async throws -> CheckoutCart {
        await Task.debugSleep()
        return .sampleCart
    }
    
    func removeProductFromCart(cartId: UInt, skuId: UInt) async throws -> CheckoutCart {
        await Task.debugSleep()
        return .sampleCart
    }
    
    func createPaymentIntent(cartId: UInt, shippingAddress: ShippingAddress?) async throws -> PaymentIntentResponse {
        return .init(productCart: .sampleCart, shippingMethods: [])
    }
    func submitCart(_ productCartId: UInt, shippingAddress: ShippingAddress?, billingAddress: BillingAddress?, customer: Customer?) async throws -> CheckoutCart {
        return .sampleCart
    }
    func getShippingMethods(cartId: UInt) async throws -> [ShippingMethodsResponse] {
        return [.init(bagId: 0, shippingMethods: [])]
    }
    func deleteCart(cartId: UInt) async throws {
        
    }
}
#endif
