//
//  BaseCreatorProfileViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.02.2023.
//

import SwiftUI
import UIKit

class BaseCreatorProfileViewController<Content: View>: UIHostingController<Content> {
    
    var viewModel: BaseCreatorProfileViewModel
    
    init(rootView: Content, viewModel: BaseCreatorProfileViewModel) {
        self.viewModel = viewModel
        super.init(rootView: rootView)
        
        setupBaseProfileActions()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch viewModel.creatorAccessLevel {
        case .readWrite:
            return viewModel.creatorHasImage ? UIStatusBarStyle.lightContent : .darkContent
        case .readOnly:
            return UIStatusBarStyle.lightContent
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBaseProfileActions() {
        viewModel.baseProfileAction.onPresentShareLink = { [weak self] shareViewController in
            self?.present(shareViewController, animated: true)
        }
    }
}
