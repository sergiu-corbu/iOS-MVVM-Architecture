//
//  LinkSocialNetworksViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.11.2022.
//

import Foundation
import Combine

class LinkSocialNetworksViewModel: ObservableObject {
    
    @Published private(set) var selectedNetworkHandles = [SocialNetworkType : SocialNetworkHandle]() {
        willSet {
            if newValue.isEmpty {
                progressStates[3] = .idle
            } else if selectedNetworkHandles.isEmpty {
                progressStates[3] = .progress(1)
            }
        }
    }
    
    @Published var isLoading = false
    @Published var backendError: Error? {
        willSet {
            progressStates[3] = .idle
        }
    }
    
    @Published private(set) var progressStates: [ProgressState]
    
    let onBack = PassthroughSubject<Void, Never>()
    let onContinue = PassthroughSubject<String, Never>()
    
    let creatorService: CreatorServiceProtocol
    let userRepository: UserRepository
    
    init(creatorService: CreatorServiceProtocol, userRepository: UserRepository) {
        self.creatorService = creatorService
        self.userRepository = userRepository
        self.progressStates = ProgressState.createStaticStates(currentIndex: 3)
    }
    
    func addSocialNetworkHandle(_ socialNetwork: SocialNetworkHandle) {
        selectedNetworkHandles.updateValue(socialNetwork, forKey: socialNetwork.type)
    }
    
    func addSocialNetworks() {
        guard !selectedNetworkHandles.isEmpty else {
            return
        }
        isLoading = true
        Task(priority: .userInitiated) { @MainActor in
            do {
                try await creatorService.addSocialNetworks(selectedNetworkHandles.values.map({$0}))
                let user = try await userRepository.getCurrentUser()
                onContinue.send(user.firstName ?? "")
            } catch {
                backendError = error
            }
            isLoading = false
        }
    }
}
