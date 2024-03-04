//
//  HTTPClient + ParameterEncoding.swift
//  NetworkLayer
//
//  Created by Sergiu Corbu on 11.08.2022.
//

import Foundation

extension HTTPClient {
    
    enum ParameterEncoding {
        case json
        case url
        
        var headerValue: String {
            switch self {
            case .url:
                return "application/x-www-form-urlencoded; charset=utf-8"
            case .json:
                return "application/json"
            }
        }
    }
}
