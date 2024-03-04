//
//  UserSessionMiddleware.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.12.2022.
//

import Foundation
import Combine
import FirebaseMessaging

enum SessionRefreshResult {
    case success
    case failure(Error)
}

class UserSessionMiddleware: HTTPMiddleware {
    private let userSession: UserSession
    private let authenticationService: AuthenticationServiceProtocol
    private var isRefreshingUserSession = false
    private var retryFinished = PassthroughSubject<SessionRefreshResult, Never>()
    private var disposeBag = [AnyCancellable]()
    
    init(_ userSession: UserSession, authenticationService: AuthenticationServiceProtocol) {
        self.userSession = userSession
        self.authenticationService = authenticationService
    }
    
    func shouldProcessRequest(_ httpRequest: HTTPRequest) -> Bool {
        return httpRequest.requiresUserSession
    }
    
    func processRequest(_ request: HTTPRequest) -> HTTPRequest {
        if let accessToken = userSession.accessToken {
            request.headers[HTTPClient.HeaderFields.accessTokenKey] = "Bearer " + accessToken
        }
        return request
    }
    
    func shouldProcessResponse(_ response: HTTPResponse) -> Bool {
        /// We want to make sure that we only handle requests that require a user session
        /// This way we are avoiding the edge case where the token refresh request returns 401/403 and gets stuck, waiting for itself to finish
        guard response.request.requiresUserSession else {
            return false
        }
        /// This ensures us that only responses with Unauthenticated/Unauthorized responses are processed
        guard let statusCode = response.httpURLResponse?.statusCode else {
            return false
        }
        return [401, 403].contains(statusCode)
    }
    
    func processResponse(_ response: HTTPResponse) -> HTTPResponseProcessingResult {
        guard !isRefreshingUserSession else { // if there is an active session refresh operation, wait for a response
            let retryMethod = HTTPRetryMethod.afterTask(1) { originalRequest in
                try await withCheckedThrowingContinuation({ [weak self] continuation in
                    guard let self else {
                        return
                    }
                    
                    #warning("we should probably add and handle timeouts for this publisher.")
                    self.retryFinished
                        .sink(receiveValue: { result in
                            switch result {
                            case .success:
                                continuation.resume()
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        })
                        .store(in: &self.disposeBag)
                })
            } _: { error in
                // Ignore error.
                // It has been already caught if it reaches this point,
                // and will cause the retry cycle to be stopped
                // The session invalidation is handled by the first request that responded with 401/403
            }
            
            return .retry(retryMethod)
        }
        
        isRefreshingUserSession = true
        let retryMethod = HTTPRetryMethod.afterTask(1, {[weak self] originalRequest in
            guard let self else {
                return
            }
            try await self.refreshUserSession()
            self.retryFinished.send(.success)
            self.disposeBag.removeAll()
            self.isRefreshingUserSession = false
        }) { [weak self] error in
            guard let self else {
                return
            }
            // failure to refresh the access token will cause the current user session to be invaliated.
            self.retryFinished.send(.failure(error))
            self.disposeBag.removeAll()
            self.isRefreshingUserSession = false
            self.invalidateUserSession(error: error)
        }
        
        return .retry(retryMethod)
    }
    
    private func refreshUserSession() async throws {
        // if we don't have a refresh token, we will fail the refresh
        guard let refreshToken = userSession.refreshToken else {
            throw NetworkError.unknown
        }
        
        // make sure that the refreshToken request does not require a user session
        let refreshTokenResponse = try await authenticationService.refreshToken(refreshToken)
        userSession.refresh(tokenInfo: refreshTokenResponse)
    }
    
    private func invalidateUserSession(error: Error?) {
        Task { @MainActor in
            if let refreshToken = userSession.refreshToken {
                try? await authenticationService.logOut(refreshToken: refreshToken, fcmToken: PushNotificationsManager.fcmToken)
            }
            userSession.close(error: error)
        }
    }
}
