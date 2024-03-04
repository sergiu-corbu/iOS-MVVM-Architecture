//
//  ShopperProfileViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.11.2022.
//

import SwiftUI
import UIKit

class ShopperProfileViewController: UIHostingController<ShopperProfileView> {
    
    let viewModel: ShopperProfileViewModel
    
    init(viewModel: ShopperProfileViewModel) {
        self.viewModel = viewModel
        super.init(rootView: ShopperProfileView(viewModel: viewModel))
        configureTabBarItem(.profile)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
        
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
