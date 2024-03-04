//
//  LiveStreamService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.03.2023.
//

import Foundation

protocol LiveStreamServiceProtocol {
    
    func prepareLiveStream(showID: String) async throws -> LiveStreamResponse
    
    func startLiveStream(showID: String) async throws -> Show
    
    func getAudienceLiveStreamToken(showID: String) async throws -> LiveStreamConnectingData
    
    func endLiveStream(showID: String) async throws
}

class LiveStreamService: LiveStreamServiceProtocol {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func prepareLiveStream(showID: String) async throws -> LiveStreamResponse {
        let request = HTTPRequest(method: .post, path: "v1/shows/\(showID)/preparingLive")
        return try await client.sendRequest(request)
    }
    
    func getAudienceLiveStreamToken(showID: String) async throws -> LiveStreamConnectingData {
        let request = HTTPRequest(method: .post, path: "v1/shows/\(showID)/generateToken")
        return try await client.sendRequest(request)
    }
    
    func startLiveStream(showID: String) async throws -> Show {
        let request = HTTPRequest(method: .post, path: "v1/shows/\(showID)/startLive", decodingKeyPath: "show")
        return try await client.sendRequest(request)
    }
    
    func endLiveStream(showID: String) async throws {
        let request = HTTPRequest(method: .post, path: "v1/shows/\(showID)/endLive")
        return try await client.sendRequest(request)
    }
}

#if DEBUG
struct MockLiveStreamService: LiveStreamServiceProtocol {
    
    func prepareLiveStream(showID: String) async throws -> LiveStreamResponse {
        await Task.debugSleep()
        return .init(show: .live, liveStreamToken: "token", liveStreamUserID: 0)
    }
    
    func getAudienceLiveStreamToken(showID: String) async throws -> LiveStreamConnectingData {
        await Task.debugSleep()
        return .init(liveStreamToken: "token", liveStreamUserID: 0, channelName: "")
    }
    
    func startLiveStream(showID: String) async throws -> Show {
        await Task.debugSleep()
        return Show.live
    }
    
    func endLiveStream(showID: String) async throws {
        await Task.debugSleep()
    }
}
#endif
