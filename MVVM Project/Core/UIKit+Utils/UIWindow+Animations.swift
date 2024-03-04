//
//  UIWindow+Animations.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.11.2022.
//

import UIKit


extension UIWindow {
    
    func transitionRootViewController(
        _ newViewController: UIViewController?,
        duration: TimeInterval = 0.3,
        options: AnimationOptions = .transitionCrossDissolve
    ) {
        
        UIView.transition(with: self, duration: duration, options: options) { [weak self] in
            self?.rootViewController = newViewController
        }
    }
}
