//
//  UIViewController+NavigationGestures.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.05.2023.
//

import Foundation
import UIKit
import SwiftUI

class InteractivenessHostingController<Content: View>: UIHostingController<Content> {
    
    let statusBarStyle: UIStatusBarStyle
    
    init(rootView: Content, statusBarStyle: UIStatusBarStyle = .default) {
        self.statusBarStyle = statusBarStyle
        super.init(rootView: rootView)
        hidesBottomBarWhenPushed = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}
