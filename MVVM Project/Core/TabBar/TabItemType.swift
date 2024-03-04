//
//  TabItemType.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.11.2022.
//

import Foundation
import UIKit

extension TabBarController {
    
    enum TabBarItemType: Int {
        
        case discover
        case search
        case profile
        
        var image: UIImage? {
            let imageName: String
            switch self {
            case .discover: imageName = "discover_icon"
            case .search: imageName = "search_icon"
            case .profile: imageName = "user_icon"
            }
            
            return UIImage(named: imageName)
        }
        
        var selectedImage: UIImage? {
            let imageName: String
            switch self {
            case .discover: imageName = "discover_icon_selected"
            case .search: imageName = "search_icon_selected"
            case .profile: imageName = "user_icon_selected"
            }
            
            return UIImage(named: imageName)?.withTintColor(.darkGreen, renderingMode: .alwaysOriginal)
        }
    }
}
