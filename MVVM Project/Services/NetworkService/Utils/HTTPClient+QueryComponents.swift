//
//  HTTPClient+QueryComponents.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.12.2022.
//

import Foundation

extension HTTPClient {
    
    func createQueryItems(from parameters: [String: Any]) -> [URLQueryItem] {
        var components = [(String, String)]()
        for (key, value) in parameters {
            components += queryStringComponents(fromKey: key, value: value)
        }
        return components.map { URLQueryItem(name: $0.0, value: $0.1)}
    }
    
    fileprivate func queryStringComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components = [(String, String)]()
        
        switch value {
        case let dictionary as [String: Any]:
            for (nestedKey, value) in dictionary {
                components += queryStringComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        case let array as [Any]:
            let items = array as? [String]
            components.append((key, items?.joined(separator: ",") ?? ""))
        case let intValue as Int:
            components.append((key, String(intValue)))
        case let bool as Bool:
            components.append((key, bool ? "true" : "false"))
        default:
            components.append((key, "\(value)"))
        }
        return components
    }
}
