//
//  EditCreatorProfileViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 23.11.2022.
//

import UIKit
import Combine
import SwiftUI

class EditCreatorProfileViewController: UIHostingController<EditCreatorProfileView> {
    
    let viewModel: EditCreatorProfileViewModel
    private var imageSelectionCoordinator: ImageSelectionCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    let profileImageDidChangeSubject = PassthroughSubject<UIImage?, Never>()
    
    init(user: User, localProfileImage: UIImage?, userRepository: UserRepository, uploadService: AWSUploadServiceProtocol) {
        self.viewModel = EditCreatorProfileViewModel(
            user: user, localProfileImage: localProfileImage,
            userRepository: userRepository, uploadService: uploadService
        )
        viewModel.profileImageDidChangeSubject = profileImageDidChangeSubject
        super.init(rootView: EditCreatorProfileView(viewModel: viewModel))
        setupCancellables()
    }
    
    private func setupCancellables() {
        viewModel.onAddProfilePicture.sink { [unowned self] in
            self.imageSelectionCoordinator = ImageSelectionCoordinator(navigationController: navigationController)
            imageSelectionCoordinator?.onImageLoaded
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.viewModel.error = error
                    }
                }, receiveValue: { [weak self] selectedImage in
                    self?.viewModel.handleSelectedImage(selectedImage)
                })
                .store(in: &cancellables)
            imageSelectionCoordinator?.start(allowsCropping: true)
        }.store(in: &cancellables)
        viewModel.onAddSocial.sink { [unowned self] in
            self.showEditSocialNetwoks()
        }.store(in: &cancellables)
        viewModel.onBack.sink { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.store(in: &cancellables)
    }
    
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func showEditSocialNetwoks(animated: Bool = true) {
        let editSocialNetworksVC = EditSocialNetworksViewController(userRepository: viewModel.userRepository)
        let navVC = UINavigationController(rootViewController: editSocialNetworksVC)
        navVC.navigationBar.isHidden = true
        navigationController?.present(navVC, animated: animated)
    }
}
