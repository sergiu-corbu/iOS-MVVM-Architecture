//
//  AuthenticationService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation

protocol AuthenticationServiceProtocol {
    
    func requestSignInEmail(_ email: String) async throws
    
    func registerGuestUser(fcmToken: String) async throws -> User
    
    func signIn(authenticationCode: String, guestUserID: String?) async throws -> AuthenticationResponse
    
    func checkUsernameAvailability(_ username: String) async throws
    
    func refreshToken(_ refreshToken: String) async throws -> RefreshTokenResponse
    
    func logOut(refreshToken: String, fcmToken: String?) async throws
    
    func updateCreatorApplication(_ creatorApplication: CreatorApplication) async throws
}

class AuthenticationService: AuthenticationServiceProtocol {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func requestSignInEmail(_ email: String) async throws {
        let request = HTTPRequest(
            method: .post,
            path: "v1/auth/send-sign-in",
            bodyParameters: ["email": email]
        )
        return try await client.sendRequest(request)
    }
    
    func registerGuestUser(fcmToken: String) async throws -> User {
        let request = HTTPRequest(
            method: .post,
            path: "v1/auth/register-guest",
            bodyParameters: ["fcmToken": fcmToken],
            decodingKeyPath: "user"
        )
        return try await client.sendRequest(request)
    }
    
    func signIn(authenticationCode: String, guestUserID: String?) async throws -> AuthenticationResponse {
        var params = ["code": authenticationCode]
        params["guestId"] = guestUserID

        let request = HTTPRequest(
            method: .post,
            path: "v1/auth/sign-in",
            bodyParameters: params
        )
        
        let response: AuthenticationResponse = try await client.sendRequest(request)
        return response
    }
    
    func checkUsernameAvailability(_ username: String) async throws {
        let request = HTTPRequest(method: .post, path: "v1/users/check", bodyParameters: ["username": username])
        return try await client.sendRequest(request)
    }
    
    func refreshToken(_ refreshToken: String) async throws -> RefreshTokenResponse {
        let request = HTTPRequest(
            method: .post,
            path: "v1/auth/refresh-token",
            bodyParameters: ["refreshToken": refreshToken],
            requiresUserSession: false
        )
        let response: RefreshTokenResponse = try await client.sendRequest(request)
        return response
    }
    
    func logOut(refreshToken: String, fcmToken: String?) async throws {
        let request = HTTPRequest(
            method: .post,
            path: "v1/auth/logout",
            bodyParameters: ["refreshToken": refreshToken]
        )
        try await client.sendRequest(request)
    }
    
    func updateCreatorApplication(_ creatorApplication: CreatorApplication) async throws {
        typealias Key = CreatorApplication.Keys
        var parameters = [Key:Any]()
        parameters[.brandWebsite] = creatorApplication.brandWebsite
        parameters[.creatorHasPartnerships] = creatorApplication.creatorHasPartnerships
        parameters[.allowsBrandPromotion] = creatorApplication.allowsBrandPromotion
        parameters[.creartorOwnsBrand] = creatorApplication.creartorOwnsBrand
        
        var selectedBrands = [[String:String]]()
        creatorApplication.brands.forEach { brand in
            var result = [String:String]()
            result[Brand.CodingKeys._id.rawValue] = brand.id
            result[Brand.CodingKeys.name.rawValue] = brand.name
            selectedBrands.append(result)
        }
        parameters[.brands] = selectedBrands
        
        let request = HTTPRequest(
            method: .patch,
            path: "v1/creator-applications",
            bodyParameters: Dictionary(uniqueKeysWithValues: parameters.map { key, value in (key.rawValue, value) })
        )
        
        try await client.sendRequest(request)
    }
}

#if DEBUG
struct MockAuthService: AuthenticationServiceProtocol {
    
    func requestSignInEmail(_ email: String) async throws {
        
    }
    
    func signIn(authenticationCode: String, guestUserID: String?) async throws -> AuthenticationResponse {
        return .init(user: User.customer, accessToken: "", refreshToken: "")
    }
    
    func logOut(refreshToken: String, fcmToken: String?) async throws {
        
    }
    
    func updateCreatorApplication(_ creatorApplication: CreatorApplication) async throws {
        
    }
    
    func refreshToken(_ refreshToken: String) async throws -> RefreshTokenResponse {
        return RefreshTokenResponse(accessToken: "12345", refreshToken: "12345")
    }
    
    func checkUsernameAvailability(_ username: String) async throws {
        throw AuthenticationError.invalidUsername
    }
    func registerGuestUser(fcmToken: String) async throws -> User {
        return User.customer
    }
}
#endif
