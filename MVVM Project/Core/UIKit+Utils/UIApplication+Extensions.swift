//
//  UIApplication+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 25.11.2022.
//

import Foundation
import UIKit

extension UIApplication {
    
    @discardableResult
    func tryOpenURL(_ url: URL?) -> Bool {
        guard let url, canOpenURL(url) else {
            return false
        }
        open(url)
        return true
    }
    
    var rootViewController: UIViewController? {
        return keyWindow?.rootViewController
    }
    
    var keyWindow: UIWindow? {
        return connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first(where: \.isKeyWindow)
    }
    
    var foregroundActiveScene: UIWindowScene? {
        return connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
}
