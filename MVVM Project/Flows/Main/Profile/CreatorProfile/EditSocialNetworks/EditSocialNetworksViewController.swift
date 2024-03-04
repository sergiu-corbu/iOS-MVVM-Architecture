//
//  EditSocialNetworksViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 23.11.2022.
//

import Foundation
import SwiftUI
import UIKit
import Combine

class EditSocialNetworksViewController: UIHostingController<EditSocialNetworksView> {
    
    let viewModel: EditSocialNetworksViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(userRepository: UserRepository) {
        self.viewModel = EditSocialNetworksViewModel(userRepository: userRepository)
        super.init(rootView: EditSocialNetworksView(viewModel: viewModel))
        isModalInPresentation = true
        setupCancellables()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCancellables() {
        viewModel.onClose.sink { [weak self] in
            self?.navigationController?.dismiss(animated: true)
        }.store(in: &cancellables)
        viewModel.onShowOtherPlatform.sink { [weak self] in
            self?.showEditOtherPlatform()
        }
        .store(in: &cancellables)
    }
    
    private func showEditOtherPlatform() {
        let editOtherPlatformView = AddOtherSocialPlatformView(
            actionType: .edit,
            platformName: viewModel.socialNetworks[.other]?.platformName,
            link: viewModel.socialNetworks[.other]?.websiteUrl?.absoluteString
        ) { [weak self] updatedHandle in
            self?.viewModel.socialNetworks.updateValue(updatedHandle, forKey: .other)
        }
        let editOtherPlatformVC = UIHostingController(rootView: editOtherPlatformView)
        navigationController?.pushViewController(editOtherPlatformVC, animated: true)
    }
}
