//
//  JSONDecoder + Keypath.swift
//  NetworkLayer
//
//  Created by Sergiu Corbu on 12.08.2022.
//

import Foundation

extension JSONDecoder {
    
    func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        keyPath: String,
        separator: Character = "."
    ) throws -> T {
        
        self.userInfo[JSONDecoder.keyPaths] = keyPath.split(separator: separator).map { String($0) }
        return try decode(ProxyModel<T>.self, from: data).object
    }
    
    static let keyPaths: CodingUserInfoKey = CodingUserInfoKey(rawValue: "keyPath")!
    
    func decode<T: Decodable>(
        _ type: T.Type,
        from dict: [String : Any],
        keyPath: String? = nil,
        separator: Character = "."
    ) throws -> T {
        
        let data = try JSONSerialization.data(withJSONObject: dict)
        if let keyPath = keyPath {
            return try self.decode(type, from: data, keyPath: keyPath, separator: separator)
        } else {
            return try self.decode(type, from: data)
        }
    }
    
    fileprivate struct ProxyModel<T: Decodable>: Decodable {
        
        var object: T
        
        struct Key: CodingKey {
            let stringValue: String
            let intValue: Int? = nil
            
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
            
            init?(intValue: Int) {
                return nil
            }
        }
        
        init(from decoder: Decoder) throws {
            let stringKeyPaths = decoder.userInfo[JSONDecoder.keyPaths] as! [String]
            var keyPaths = stringKeyPaths.map { Key(stringValue: $0)! }
            var container = try decoder.container(keyedBy: Key.self)
            var key = keyPaths.removeFirst()
            
            try keyPaths.forEach { newKey in
                container = try container.nestedContainer(keyedBy: Key.self, forKey: key)
                key = newKey
            }
            
            object = try container.decode(T.self, forKey: key)
        }
    }
}

extension KeyedDecodingContainer {
    
    func decodeIfPresent(_ type: String.Type, forKey key: Key, fallbackKey: Key) throws -> String? {
        try decodeIfPresent(type, forKey: key) ?? decodeIfPresent(type, forKey: fallbackKey)
    }
}
