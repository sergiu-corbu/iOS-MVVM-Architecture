//
//  UINavigationController+HostingController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.02.2023.
//

import UIKit
import SwiftUI

extension UINavigationController {
    
    func pushHostingController<Content>(_ content: Content, animated: Bool = true) where Content: View {
        self.pushViewController(UIHostingController(rootView: content), animated: animated)
    }

    func presentHostingView<Content>(
        _ content: Content,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) where Content: View {
        self.present(UIHostingController(rootView: content), animated: animated, completion: completion)
    }
}

extension UINavigationController {
    
    func dismissPresentedViewControllerIfNeeded(animated: Bool, completion: (() -> Void)? = nil) {
        if self.presentedViewController != nil {
            self.dismiss(animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
}
