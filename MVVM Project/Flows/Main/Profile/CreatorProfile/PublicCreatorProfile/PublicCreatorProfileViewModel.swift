//
//  PublicCreatorProfileViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.02.2023.
//

import Foundation

class PublicCreatorProfileViewModel: BaseCreatorProfileViewModel {
    
    //MARK: - Actions
    let onBack: () -> Void
    let onRequestAuthentication: NestedCompletionHandler
    var onPresentShareLink: ((ShareLinkActivityViewController) -> Void)?
    
    //MARK: - Services
    let deeplinkProvider: DeeplinkProvider
    lazy private var shareableProvider = ShareableProvider(deeplinkProvider: deeplinkProvider, onPresentShareLink: { [weak self] shareVC in
        self?.onPresentShareLink?(shareVC)
    })
    
    init(creator: Creator, showService: ShowRepositoryProtocol, creatorService: CreatorServiceProtocol,
         deeplinkProvider: DeeplinkProvider, onBack: @escaping () -> Void,
         onRequestAuthentication: @escaping NestedCompletionHandler) {
        self.onBack = onBack
        self.onRequestAuthentication = onRequestAuthentication
        self.deeplinkProvider = deeplinkProvider
        super.init(creator: creator, creatorAccessLevel: .readOnly, showService: showService, creatorService: creatorService, creatorProfileAction: nil)
        
        getPublicCreator()
    }

    func getPublicCreator() {
        Task(priority: .userInitiated) { @MainActor in
            do {
                if let publicCreator = try await self.creatorService.getPublicCreator(id: creator.id) {
                    self.creator = publicCreator
                }
            } catch {
                self.error = error
            }
        }
    }
    
    func handleFollowAction(isFollowing: Bool) {
        if isFollowing {
            creator.followersCount += 1
        } else {
            creator.followersCount = max(0, creator.followersCount - 1)
        }
    }
    
    func generateShareLink() {
        shareableProvider.generateShareURL(creator.shareableObject)
    }
}
