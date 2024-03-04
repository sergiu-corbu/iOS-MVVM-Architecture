//
//  PushNotificationsService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 12.04.2023.
//

import Foundation

protocol PushNotificationsServiceProtocol {
    
    func registerPushNotifications(token: String) async throws
    
    func unregisterPushNotifications(token: String) async throws
}

class PushNotificationsService: PushNotificationsServiceProtocol {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func registerPushNotifications(token: String) async throws {
        let request = HTTPRequest(method: .post, path: "v1/notifications/fcm", bodyParameters: ["fcmToken": token])
        return try await client.sendRequest(request)
    }
    
    func unregisterPushNotifications(token: String) async throws {
        let request = HTTPRequest(method: .delete, path: "v1/notifications/fcm", bodyParameters: ["fcmToken": token])
        return try await client.sendRequest(request)
    }
}

#if DEBUG
struct MockPushNotificationsService: PushNotificationsServiceProtocol {
    
    func registerPushNotifications(token: String) async throws {
        
    }
    
    func unregisterPushNotifications(token: String) async throws {
        
    }
}
#endif
