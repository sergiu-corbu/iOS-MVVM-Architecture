//
//  OrderService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.04.2023.
//

import Foundation

protocol OrderServiceProtocol {
    
    func getOrders(pageSize: Int, lastOrderID: String?, lastOrderCreatedDate: Date?) async throws -> [Order]
    
    func getOrderByID(_ orderID: String) async throws -> Order?
}

class OrderService: OrderServiceProtocol {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func getOrders(pageSize: Int, lastOrderID: String?, lastOrderCreatedDate: Date?) async throws -> [Order] {
        var parameters: [String:Any] = ["length": pageSize]
        parameters["lastId"] = lastOrderID
        parameters["lastPropName"] = "createdAt"
        parameters["lastPropValue"] = lastOrderCreatedDate?.dateString(formatType: .defaultDate, timeZone: TimeZone(secondsFromGMT: 0)!)
        let request = HTTPRequest(method: .get, path: "v1/orders", queryItems: parameters, decodingKeyPath: "data")
        
        return try await client.sendRequest(request)
    }
    
    func getOrderByID(_ orderID: String) async throws -> Order? {
        let request = HTTPRequest(method: .get, path: "v1/orders:/\(orderID)", decodingKeyPath: "data")
        return try await client.sendRequest(request)
    }
}

#if DEBUG
struct MockOrderService: OrderServiceProtocol {
    
    func getOrderByID(_ orderID: String) async throws -> Order? {
        await Task.sleep(seconds: 1)
        return Order.mockOrder
    }
    
    func getOrders(pageSize: Int, lastOrderID: String?, lastOrderCreatedDate: Date?) async throws -> [Order] {
        await Task.sleep(seconds: 1)
        var result = [Order]()
        for _ in 0..<5 {
            result.append(.mockOrder)
        }
        return result
    }
}
#endif
