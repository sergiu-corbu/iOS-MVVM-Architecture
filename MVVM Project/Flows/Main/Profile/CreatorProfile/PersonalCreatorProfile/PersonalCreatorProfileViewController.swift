//
//  PersonalCreatorProfileViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.11.2022.
//

import SwiftUI
import UIKit

class PersonalCreatorProfileViewController: BaseCreatorProfileViewController<PersonalCreatorProfileView> {
    
    let personalViewModel: PersonalCreatorProfileViewModel
    
    init(viewModel: PersonalCreatorProfileViewModel) {
        self.personalViewModel = viewModel
        super.init(rootView: PersonalCreatorProfileView(viewModel: viewModel), viewModel: viewModel)
        configureTabBarItem(.profile)
    }
    
    override var viewModel: BaseCreatorProfileViewModel {
        get {
            return personalViewModel
        } set {
            super.viewModel = newValue
        }
    }
        
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
