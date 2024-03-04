//
//  EditSocialNetworksViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.11.2022.
//

import Foundation
import Combine

class EditSocialNetworksViewModel: ObservableObject {
    
    @Published var socialNetworks: [SocialNetworkType: SocialNetworkHandle] = [:] {
        willSet {
            guard !socialNetworks.isEmpty else {
                return
            }
            isShowButtonVisible = newValue.values.first(where: \.hasValue) != nil
        }
    }
    var socialNetworksErrors: [SocialNetworkType: Error] = [:]
    
    private var user: User?
    
    private(set) var isShowButtonVisible = false
    @Published var isLoading = false
    @Published var backendError: Error?
    
    let userRepository: UserRepository
    
    let onClose = PassthroughSubject<Void, Never>()
    let onShowOtherPlatform = PassthroughSubject<Void, Never>()
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
        let currentUser = userRepository.currentUser
        self.user = currentUser
        self.socialNetworks = Dictionary(uniqueKeysWithValues: (currentUser?.socialNetworks ?? []).map { ($0.type, $0) })
    }
    
    @MainActor
    func updateSocialNetworks() {
        Task(priority: .userInitiated) {
            do {
                var validatedSocialNetworks = [SocialNetworkHandle]()
                var invalidateRequest = false
                socialNetworks.forEach { (type: SocialNetworkType, socialNetwork: SocialNetworkHandle) in
                    do {
                        if let _socialNetwork = try validateSocialNetwork(socialNetwork) {
                            validatedSocialNetworks.append(_socialNetwork)
                        }
                    } catch {
                        invalidateRequest = true
                        socialNetworksErrors[type] = error
                    }
                }
                objectWillChange.send()
                guard !validatedSocialNetworks.isEmpty, !invalidateRequest else {
                    return
                }
                isLoading = true
                try await userRepository.updateUser(bio: nil, socialNetworks: validatedSocialNetworks)
                onClose.send()
            } catch {
                backendError = error
            }
            isLoading = false
        }
    }
    
    private func validateSocialNetwork(_ socialNetwork: SocialNetworkHandle) throws -> SocialNetworkHandle? {
        let type: SocialNetworkType = socialNetwork.type
        
        switch type {
        case .instagram, .tiktok:
            if let handle = socialNetwork.handle {
                try handle.isValidSocial()
                return SocialNetworkHandle(type: type, handle: handle)
            }
        case .website:
            if let websiteUrl = socialNetwork.websiteUrl {
                try websiteUrl.absoluteString.isValidWebsite()
                return SocialNetworkHandle(type: type, websiteUrl: websiteUrl)
            }
        case .other:
            if let platformName = socialNetwork.platformName,
               let websiteUrl = socialNetwork.websiteUrl {
                return SocialNetworkHandle(type: type, websiteUrl: websiteUrl, platformName: platformName)
            }
        case .youtube:
            if let youtubeChannel = socialNetwork.handle {
                return SocialNetworkHandle(type: type, handle: youtubeChannel)
            }
        }
        return nil
    }
}
