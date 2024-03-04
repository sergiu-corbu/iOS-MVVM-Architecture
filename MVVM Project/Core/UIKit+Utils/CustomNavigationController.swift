//
//  CustomNavigationController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.01.2023.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        navigationBar.isHidden = true
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        navigationBar.isHidden = true
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return presentedViewController ?? topViewController
    }
}
