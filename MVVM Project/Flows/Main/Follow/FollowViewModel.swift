//
//  FollowViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.05.2023.
//

import Foundation
import Combine

enum FollowState {
    
    case notFollowing
    case following
    
    var labelString: String {
        switch self {
        case .notFollowing: return Strings.Buttons.follow
        case .following: return Strings.Buttons.unfollow
        }
    }
    
    func toggle() -> Self {
        switch self {
        case .notFollowing:
            return .following
        case .following:
            return .notFollowing
        }
    }
}

typealias NestedCompletionHandler = (_ completion: @escaping () -> Void) -> Void

class FollowViewModel: ObservableObject {
    
    // Dependencies
    let followingID: String
    let userRepository: UserRepository
    let followService: FollowServiceProtocol
    let pushNotificationsPermissionHandler: PushNotificationsPermissionHandler
    let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    // State
    @Published var isLoading: Bool = true
    @Published var followState: FollowState = .notFollowing
    @Published var showPushNotificationsPermission = false
    
    let onRequestAuthentication: NestedCompletionHandler?
    
    // Internal
    let followType: FollowType
    private var disposeBag = [AnyCancellable]()
    
    init(followingID: String, followType: FollowType, userRepository: UserRepository,
         followService: FollowServiceProtocol, pushNotificationsPermissionHandler: PushNotificationsPermissionHandler,
         onRequestAuthentication: NestedCompletionHandler?) {
        
        self.followingID = followingID
        self.followType = followType
        self.userRepository = userRepository
        self.followService = followService
        self.pushNotificationsPermissionHandler = pushNotificationsPermissionHandler
        self.onRequestAuthentication = onRequestAuthentication
        
        setupBindings()
    }
    
    // Computed
    var isFollowing: Bool {
        return followState == .following
    }
    var isFollowActionEnabled: Bool {
        guard let currentUser = userRepository.currentUser else {
            return false
        }
        switch followType {
        case .user:
            return currentUser.id != followingID
        case .brand:
            return true
        }
    }
    var followingLabel: String {
        return isFollowing ? Strings.Buttons.following : Strings.Buttons.follow
    }
    
    private func setupBindings() {
        userRepository.currentUserSubject.sink { [weak self] newUser in
            guard let self = self else { return }
            if let user = newUser {
                switch self.followType {
                case .user:
                    self.followState = user.followingUserIds.contains(self.followingID) ? .following : .notFollowing
                case .brand:
                    self.followState = user.followingBrandIds.contains(self.followingID) ? .following : .notFollowing
                }
            }
            self.isLoading = false
        }
        .store(in: &disposeBag)
    }
    
    //MARK: - Follow Action
    func handleFollowAction(completionHandler: (() -> Void)? = nil) {
        if isFollowActionEnabled {
            followAction()
            presentNotificationsPermission()
            completionHandler?()
        } else {
            let followCompletion = { [weak self] in
                if self?.isFollowing == false {
                    self?.followAction()
                    self?.presentNotificationsPermission()
                    completionHandler?()
                }
            }
            onRequestAuthentication?(followCompletion)
        }
    }
    
    private func followAction() {
        if isLoading, !isFollowActionEnabled { return }
        let newValue = followState.toggle()
        self.followState = newValue
        switch self.followState {
        case .following:
            self.userRepository.addToFollowers(followingID: followingID, type: followType)
        case .notFollowing:
            self.userRepository.removeFromFollowers(followingID: followingID)
        }
        
        Task(priority: .userInitiated) { [weak self] in
            guard let self else {
                return
            }
            
            do {
                switch followState {
                case .notFollowing:
                    try await self.followService.unfollow(id: self.followingID, type: self.followType)
                case .following:
                    try await self.followService.follow(id: self.followingID, type: self.followType)
                }
                trackFollowEvent(for: followState)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func presentNotificationsPermission() {
        guard followState == .following else {
            return
        }
        Task(priority: .utility) {
            if await pushNotificationsPermissionHandler.shouldRequestPermission() {
                await MainActor.run {
                    showPushNotificationsPermission = true
                }
            }
        }
    }
    
    func trackFollowEvent(for followState: FollowState) {
        var properties = AnalyticsProperties()
        properties[.follow_type] = followType.rawValue.capitalized
        properties[.followed_id] = followingID
        
        switch followState {
        case .following:
            analyticsService.trackActionEvent(followType == .brand ? .follow_brand : .follow_creator, properties: properties)
        case .notFollowing:
            analyticsService.trackActionEvent(followType == .brand ? .unfollow_brand : .unfollow_brand, properties: properties)
        }
    }
}

extension FollowViewModel {
    
    #if DEBUG
    static func mocked(followType: FollowType) -> FollowViewModel {
        return FollowViewModel(
            followingID: User.creator.id, followType: followType,
            userRepository: MockUserRepository(), followService: MockFollowService(),
            pushNotificationsPermissionHandler: MockPushNotificationsHandler(), onRequestAuthentication: nil
        )
    }
    #endif
}
