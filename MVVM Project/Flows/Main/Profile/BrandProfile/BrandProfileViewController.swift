//
//  BrandProfileViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 24.05.2023.
//

import UIKit
import SwiftUI

class BrandProfileViewController: UIHostingController<BrandProfileView> {
    
    let viewModel: BrandProfileViewModel
    
    init(viewModel: BrandProfileViewModel) {
        self.viewModel = viewModel
        super.init(rootView: BrandProfileView(viewModel: viewModel))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
