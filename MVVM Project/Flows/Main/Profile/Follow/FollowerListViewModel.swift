//
//  FollowerListViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.08.2023.
//

import Foundation
import UIKit
import Combine

class FollowerListViewModel: ObservableObject {

    //MARK: - Properties
    @Published private(set) var user: User
    let contentType: FollowSectionType
    @Published var selectedFollowType: FollowType = .user
    @Published var backendError: Error?
    private var cancellables = Set<AnyCancellable>()
    private var ongoingTasks = [Task<Void, Never>]()
    
    //MARK: - Computed
    var didLoadFirstPageForFollowType: Bool {
        switch selectedFollowType {
        case .brand: return brandsDataStore.didLoadFirstPage
        case .user: return usersDataStore.didLoadFirstPage
        }
    }
    
    private(set) var followingCounts: (users: Int, brands: Int)
    
    //MARK: - Services
    let usersDataStore = PaginatedDataStore<FollowService.FollowingUserDTO>()
    lazy var brandsDataStore = PaginatedDataStore<FollowService.FollowingBrandDTO>()
    let userRepository: UserRepository
    let followService: FollowServiceProtocol
    let pushNotificationsPermissionHandler: PushNotificationsPermissionHandler
    
    //MARK: - Actions
    enum FollowerListAction {
        case selectUser(User)
        case selectBrand(Brand)
        case back
        case onRequestAuthentication(() -> Void)
    }
    let followerListActionHandler: (FollowerListAction) -> Void
    
    init(user: User, contentType: FollowSectionType,
         userRepository: UserRepository, followService: FollowServiceProtocol,
         pushNotificationsPermissionHandler: PushNotificationsPermissionHandler,
         followerListActionHandler: @escaping (FollowerListAction) -> Void) {
        
        self.user = user
        self.contentType = contentType
        self.userRepository = userRepository
        self.followService = followService
        self.pushNotificationsPermissionHandler = pushNotificationsPermissionHandler
        self.followerListActionHandler = followerListActionHandler
        self.followingCounts = user.followingCounts(isSelfUser: false)
        
        self.setupBindings()
    }
    
    deinit {
        ongoingTasks.forEach { $0.cancel() }
    }
    
    func loadInitialContent(forceRefresh: Bool = false) {
        if didLoadFirstPageForFollowType, !forceRefresh {
            return
        }
        
        let task = Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                if forceRefresh {
                    switch self.selectedFollowType {
                    case .brand:
                        try await self.brandsDataStore.refreshContent()
                    case .user:
                        try await self.usersDataStore.refreshContent()
                    }
                } else {
                    switch self.selectedFollowType {
                    case .brand:
                        try await self.brandsDataStore.loadInitialContent()
                    case .user:
                        try await self.usersDataStore.loadInitialContent()
                    }
                }
            } catch {
                self.backendError = error
            }
        }
        ongoingTasks.append(task)
    }
    
    func viewModel(from user: User) -> FollowViewModel {
        return FollowViewModel(
            followingID: user.id, followType: .user,
            userRepository: userRepository,
            followService: followService,
            pushNotificationsPermissionHandler: pushNotificationsPermissionHandler,
            onRequestAuthentication: { [weak self] completion in
                self?.followerListActionHandler(.onRequestAuthentication(completion))
            }
        )
    }

    private func setupBindings() {
        usersDataStore.onLoadPage { [weak self] lastObject in
            guard let self = self else { return [] }
            let pageSize = self.usersDataStore.pageSize
            let lastID = lastObject?._id
            switch self.contentType {
            case .followers:
                return []
            case .following:
                return try await self.followService.getFollowing(creatorId: self.user.id, followType: .user, pageSize: pageSize, lastId: lastID)
            }
        }
        
        if contentType == .following {
            brandsDataStore.onLoadPage { [weak self] lastObject in
                guard let self = self else { return [] }
                let pageSize = self.brandsDataStore.pageSize
                let lastID = lastObject?._id
                return try await self.followService.getFollowing(creatorId: self.user.id, followType: .brand, pageSize: pageSize, lastId: lastID)
            }
        }
                
        Publishers.MergeMany(usersDataStore.objectWillChange, brandsDataStore.objectWillChange).sink { [weak self] in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
        
        userRepository.currentUserSubject
            .sink { [weak self] updatedUser in
                guard self?.user.id == updatedUser?.id, let updatedUser else {
                    return
                }
                self?.user = updatedUser
                self?.followingCounts = updatedUser.followingCounts(isSelfUser: true)
            }
            .store(in: &cancellables)
    }
}

enum FollowSectionType: Int, Equatable {
    case followers
    case following
    
    var name: String {
        switch self {
        case .followers: return Strings.Profile.followers
        case .following: return Strings.Profile.following
        }
    }
    
    var placeholderMessage: String {
        switch self {
        case .followers: return Strings.Placeholders.followers
        case .following: return Strings.Placeholders.following
        }
    }
}
