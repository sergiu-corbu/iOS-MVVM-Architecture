//
//  UserService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation

protocol UserServiceProtocol {
    
    @discardableResult
    func updateUser(values: [User.UpdateKey: String]) async throws -> User
    
    func getCurrentUser() async throws -> User
}

class UserService: UserServiceProtocol {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }

    @discardableResult
    func updateUser(values: [User.UpdateKey : String]) async throws -> User {
        let parameters = Dictionary(uniqueKeysWithValues: values.map { (key, value) in (key.rawValue, value)})
        let request = HTTPRequest(
            method: .patch,
            path: "v1/users/me",
            bodyParameters: parameters,
            decodingKeyPath: "user"
        )
        
        let user: User = try await client.sendRequest(request)
        return user
    }
    
    func getCurrentUser() async throws -> User {
        let request = HTTPRequest(method: .get, path: "v1/users/me", decodingKeyPath: "user")
        let user: User = try await client.sendRequest(request)
        return user
    }
}

#if DEBUG
struct MockUserService: UserServiceProtocol {
    
    func getCurrentUser() async throws -> User {
        return User.creator
    }
    
    func updateUser(values: [User.UpdateKey : String]) async throws -> User {
        return User.creator
    }
}
#endif
