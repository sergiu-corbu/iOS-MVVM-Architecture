//
//  SearchViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation
import UIKit
import SwiftUI

class SearchViewController: UIHostingController<SearchView> {
    
    let viewModel: SearchViewModel
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(rootView: SearchView(viewModel: viewModel))
        configureTabBarItem(.search)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
