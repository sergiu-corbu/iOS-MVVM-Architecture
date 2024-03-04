//
//  UIWindow + Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.05.2021.
//

import Foundation
import UIKit

extension UIWindow {
    
    func mostVisibleViewController() -> UIViewController? {
        guard let rootViewController = self.rootViewController else {
            return nil
        }
        return mostVisibleViewController(from:rootViewController)
    }
    
    func mostVisibleViewController(from viewController:UIViewController) -> UIViewController {
        switch viewController  {
        case let navigationController as UINavigationController:
            guard let top = navigationController.topViewController else {
                return navigationController
            }
            return mostVisibleViewController(from:top)
        case let tabBarController as UITabBarController:
            guard let selectedTab = tabBarController.selectedViewController else {
                return tabBarController
            }
            return mostVisibleViewController(from:selectedTab)
        default:
            break
        }
        guard let presentedViewController = viewController.presentedViewController else {
            return viewController
        }
        return mostVisibleViewController(from:presentedViewController)
    }
}

func resignFirstResponder() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
