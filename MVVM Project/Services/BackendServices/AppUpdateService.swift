//
//  AppUpdateService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.05.2023.
//

import Foundation

protocol AppUpdateServiceProtocol {
    
    func isAppUpdateAvailable() async -> Bool
    var latestVersion: String? { get }
}

class AppUpdateService: AppUpdateServiceProtocol {
    
    private let lookUpURL: URL? = {
        guard let appIdentifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String else {
            return nil
        }
        return URL(string: "https://itunes.apple.com/lookup?bundleId=\(appIdentifier)")
    }()
    
    var latestVersion: String?
    
    func isAppUpdateAvailable() async -> Bool {
        guard let currentAppVersion = Constants.APP_VERSION as? String, let lookUpURL else {
            return false
        }
        
        var request = URLRequest(url: lookUpURL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.timeoutInterval = 30.0
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String : Any]
            
            if let result = (jsonObject?["results"] as? [Any])?.first as? [String : Any],
               let lastVersion = result["version"] as? String {
                latestVersion = lastVersion
                return lastVersion > currentAppVersion
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return false
    }
}
