//
//  DiscoverFeedViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.11.2023.
//

import Foundation
import UIKit
import SwiftUI

class DiscoverFeedViewController: UIHostingController<DiscoverFeedView> {
    
    let viewModel: DiscoverFeedViewModel
    
    init(viewModel: DiscoverFeedViewModel) {
        self.viewModel = viewModel
        super.init(rootView: DiscoverFeedView(viewModel: viewModel))
        configureTabBarItem(.discover)
        
        viewModel.onReceiveError = { [weak self] error in
            ToastDisplay.showErrorToast(from: self, error: error, animated: true)
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
