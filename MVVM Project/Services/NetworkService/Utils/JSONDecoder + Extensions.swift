//
//  JSONDecoder + Extensions.swift
//  NetworkLayer
//
//  Created by Sergiu Corbu on 08.08.2022.
//

import Foundation

extension JSONDecoder {
    
    static var `default`: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter().defaultDateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

extension Data {
    /// useful for debugging
    var dataAsString: String? {
        String(data: self, encoding: .utf8)
    }
}
