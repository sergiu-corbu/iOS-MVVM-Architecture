//
//  Discount.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 14.08.2023.
//

import Foundation

enum DiscountStatus: String, Decodable {
    case pending = "PENDING"
    case applied = "APPLIED"
    case invalid = "INVALID"
    case notSupported = "NOT_SUPPORTED"
    case error = "ERROR"
    case expired = "EXPIRED"
}

struct Discount: Decodable {
    let id: UInt
    let bagID: Int
    let type: String
    let status: DiscountStatus
    let amountTotal: Double?
    let code: String
    let valueType: String?
    let dateCreated: Date
    let dateLastModified: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case bagID = "bagId"
        case type
        case status
        case amountTotal
        case code
        case valueType
        case dateCreated
        case dateLastModified
    }
}
