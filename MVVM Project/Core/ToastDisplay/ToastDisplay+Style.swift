//
//  ToastDisplay+Style.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.11.2022.
//

import SwiftUI

extension ToastDisplay {
    
    enum Style {
        
        case success
        case error
        case informative
        
        var tint: Color {
            switch self {
            case .success: return .feldgrau
            case .informative: return .ebony
            case .error: return .firebrick
            }
        }
        
        var image: ImageResource {
            switch self {
            case .success: return .successIcon
            case .informative: return .informativeIcon
            case .error: return .errorIcon
            }
        }
    }
}
