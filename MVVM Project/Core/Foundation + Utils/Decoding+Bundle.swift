//
//  Decoding+Bundle.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.02.2023.
//

import Foundation

extension Bundle {
    
    func decode<T: Decodable>(_ type: T.Type, from file: String, keyPath: String? = nil) throws -> T? {
        
        guard let url = self.url(forResource: file, withExtension: nil) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            if let keyPath {
                return try JSONDecoder().decode(T.self, from: data, keyPath: keyPath)
            } else {
                return try JSONDecoder().decode(T.self, from: data)
            }
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
