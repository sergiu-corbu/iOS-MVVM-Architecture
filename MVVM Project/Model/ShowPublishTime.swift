//
//  ShowPublishTime.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.12.2022.
//

import Foundation
import SwiftUI

enum ShowPublishTime: Int, CaseIterable {
    
    case now
    case later
    
    var image: Image {
        switch self {
        case .now: return Image(.clockIcon)
        case .later: return Image(.calendarIcon)
        }
    }
    
    var text: String {
        switch self {
        case .now: return Strings.ContentCreation.now
        case .later: return Strings.ContentCreation.later
        }
    }
}

extension ShowPublishTime: Segmentable {
    
    var segmentText: String {
        return text
    }
}
