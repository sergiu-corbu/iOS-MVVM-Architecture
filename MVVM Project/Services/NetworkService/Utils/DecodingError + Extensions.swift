//
//  DecodingError + Extensions.swift
//  Imobiliare
//
//  Created by Sergiu Corbu on 07.10.2022.
//

import Foundation

extension DecodingError {
    
    var debugDescription: String {
        switch self {
        case .dataCorrupted(let context):
            return context.debugDescription
        case .keyNotFound(_, let context):
            return context.debugDescription
        case .typeMismatch(_, let context):
            return context.debugDescription
        case .valueNotFound(_, let context):
            return context.debugDescription
        default:
            return self.localizedDescription
        }
    }
}
