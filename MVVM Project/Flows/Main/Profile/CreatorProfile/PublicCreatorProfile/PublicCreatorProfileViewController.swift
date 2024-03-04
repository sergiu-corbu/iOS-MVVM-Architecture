//
//  PublicCreatorProfileViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.02.2023.
//

import SwiftUI
import UIKit

class PublicCreatorProfileViewController: BaseCreatorProfileViewController<AnyView> {
    
    init(viewModel: PublicCreatorProfileViewModel, showVideoStreamBuilder: ShowVideoStreamBuilder) {
        let followViewModel = FollowViewModel(followingID: viewModel.creator.id, followType: .user, userRepository: showVideoStreamBuilder.userRepository, followService: showVideoStreamBuilder.followService, pushNotificationsPermissionHandler: showVideoStreamBuilder.pushNotificationsHandler, onRequestAuthentication: { completion in
            viewModel.onRequestAuthentication(completion)
        })
        let creatorProfileView = PublicCreatorProfileView(viewModel: viewModel, showVideoStreamBuilder: showVideoStreamBuilder)
            .environmentObject(followViewModel)
        super.init(
            rootView: creatorProfileView.eraseToAnyView(),
            viewModel: viewModel
        )
        viewModel.onPresentShareLink = { [weak self] shareVC in
            self?.present(shareVC, animated: true)
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
