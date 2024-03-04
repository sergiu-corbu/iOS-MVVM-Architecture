//
//  UserRepository.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 14.11.2022.
//

import Foundation
import Combine

protocol UserProvider {
    
    func saveUser(_ user: User?) async
    
    func getCurrentUser(loadFromCache: Bool) async -> User?
}

class UserRepository {
    
    let currentUserSubject = CurrentValueSubject<User?, Never>(nil)
    
    private let userService: UserServiceProtocol
    private let creatorService: CreatorServiceProtocol
    
    private let currentUserStorageKey = "com.currentUser"
    
    private var currentUserCache: CodableCaching<User> {
        return CodableCaching(resourceID: currentUserStorageKey)
    }
    
    var currentUser: User? {
        return currentUserSubject.value
    }
    var isUserProfileCompleted: Bool {
        get async {
            return await currentUserCache.loadFromFile()?.username != nil
        }
    }
    
    init(userService: UserServiceProtocol, creatorService: CreatorServiceProtocol) {
        self.userService = userService
        self.creatorService = creatorService
    }
    
    @discardableResult
    func updateUser(values: [User.UpdateKey : String]) async throws -> User {
        let user = try await userService.updateUser(values: values)
        await currentUserCache.saveToFile(user)
        await MainActor.run {
            currentUserSubject.send(user)
        }
        return user
    }
    
    func updateUser(bio: String?, socialNetworks: Array<SocialNetworkHandle>?) async throws {
        let updatedUser = try await creatorService.updateCreator(bio: bio, socialNetworks: socialNetworks)
        await currentUserCache.saveToFile(updatedUser)
        await MainActor.run {
            currentUserSubject.send(updatedUser)
        }
    }
    
    func addToFollowers(followingID: String, type: FollowType) {
        Task {
            guard var user = self.currentUser else {
                return
            }
            switch type {
            case .brand:
                user.followingBrandIds.insert(followingID)
            case .user:
                user.followingUserIds.insert(followingID)
            }
            user.followingCount += 1
            await saveUser(user)
        }
    }
    
    func removeFromFollowers(followingID: String) {
        Task {
            guard var user = self.currentUser else {
                return
            }
            user.followingBrandIds.remove(followingID)
            user.followingUserIds.remove(followingID)
            user.followingCount -= 1
            await saveUser(user)
        }
    }
    
    
    func getCurrentUser() async throws -> User {
        let updatedUser = try await userService.getCurrentUser()
        await currentUserCache.saveToFile(updatedUser)
        await MainActor.run {
            currentUserSubject.send(updatedUser)
        }
        return updatedUser
    }
}

extension UserRepository: UserProvider {
    
    func saveUser(_ user: User?) async {
        await currentUserCache.saveToFile(user)
        await MainActor.run {
            currentUserSubject.send(user)
        }
    }
    
    @discardableResult
    func getCurrentUser(loadFromCache: Bool) async -> User? {
        if loadFromCache {
            return await currentUserCache.loadFromFile()
        }
        return try? await getCurrentUser()
    }
}

#if DEBUG
class MockUserRepository: UserRepository {
    
    override init(
        userService: UserServiceProtocol = MockUserService(),
        creatorService: CreatorServiceProtocol =  MockCreatorService()
    ) {
        super.init(userService: userService, creatorService: creatorService)
    }
}

struct MockUserProvider: UserProvider {
    
    func getCurrentUser(loadFromCache: Bool) async -> User? {
        await Task.sleep(seconds: 1)
        return User.creator
    }
    
    func saveUser(_ user: User?) async {
        
    }
}
#endif
