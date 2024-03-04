//
//  Encodable+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 14.03.2023.
//

import Foundation

extension JSONEncoder {
    
    func encodeToHashMap<T: Encodable>(_ object: T, readingOptions: JSONSerialization.ReadingOptions = []) throws -> [String : Any]? {
        let jsonData = try encode(object)
        let result = try JSONSerialization.jsonObject(with: jsonData, options: readingOptions) as? [String : Any]
        return result
    }
}
