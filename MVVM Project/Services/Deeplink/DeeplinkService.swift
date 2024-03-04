//
//  DeeplinkService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.01.2023.
//

import Foundation
import UIKit
import AppsFlyerLib
import Combine

protocol DeeplinkProvider {
    
    func generateShareURL(shareableObject: ShareableObject) async -> URL?
    func generateGiftingInviteURL() async -> URL?
}

class DeeplinkService: NSObject {
    
    private let appsFlyer: AppsFlyerLib = .shared()
    private var scheduledAppLaunchAction: ShareableObject?
    private var launchOptions: [UIApplication.LaunchOptionsKey:Any]?
    private let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    override init() {
        appsFlyer.appsFlyerDevKey = Constants.AppsFlyer.DEV_KEY
        appsFlyer.appleAppID = Constants.APP_ID
        appsFlyer.appInviteOneLinkID = Constants.AppsFlyer.ONE_LINK_ID
        appsFlyer.disableSKAdNetwork = false
        super.init()
        
        appsFlyer.deepLinkDelegate = self
        appsFlyer.delegate = self
        appsFlyer.start()
    }
    
    //TODO: refactor this
    let onSignUpWithToken = PassthroughSubject<String, Never>()
    let onOpenSharedShow = PassthroughSubject<String, Never>()
    let onOpenBrandProfile = PassthroughSubject<String, Never>()
    let onOpenProductDetails = PassthroughSubject<String, Never>()
    let onOpenCreatorProfile = PassthroughSubject<String, Never>()
    let onOpenGiftRequest = PassthroughSubject<Void, Never>()
    let onOpenPromotedProducts = PassthroughSubject<String, Never>()
    
    //MARK: Deeplinking
    @discardableResult
    func processUserActivity(_ userActivity: NSUserActivity) -> Bool {
        launchOptions = nil
        appsFlyer.continue(userActivity, restorationHandler: nil)
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let activityURL = userActivity.webpageURL,
              let parsedActivityURL = URLComponents(url: activityURL, resolvingAgainstBaseURL: true)?.url else {
            return false
        }
        
        analyticsService.trackActionEvent(.deeplinkOpened, properties: [.deep_link_url: activityURL.absoluteString])
        
        guard let tokenStartIndex = parsedActivityURL.absoluteString.endIndex(of: "token=") else {
            return false
        }
        
        let tokenString = String(parsedActivityURL.absoluteString.suffix(from: tokenStartIndex))
        onSignUpWithToken.send(tokenString)
        
        return true
    }
    
    @discardableResult
    func processURL(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let parsedURL = components.url else {
            return false
        }
        
        if let tokenStartIndex = parsedURL.absoluteString.endIndex(of: "token=") {
            onSignUpWithToken.send(String(parsedURL.absoluteString.suffix(from: tokenStartIndex)))
            return true
        } else {
            for shareableType in ShareableType.allCases {
                if let objectID = parseURLComponents(components, for: shareableType.afDecodingKey) {
                    DispatchQueue.main.asyncAfter(seconds: 0.1) {
                        self.handleShareableType(shareableType, objectID: objectID)
                    }
                    return true
                }
            }
        }
        
        return false
    }
    
    //MARK: - Launch Options
    func setLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey:Any]?) {
        self.launchOptions = launchOptions
    }
    
    func processLaunchOptions() {
        if let url = launchOptions?[.url] as? URL {
            processURL(url)
        }
        self.launchOptions = nil
    }
    
    func processScheduledLaunchAction() {
        guard let scheduledAppLaunchAction else {
            return
        }
        handleShareableType(scheduledAppLaunchAction.type, objectID: scheduledAppLaunchAction.objectID)
    }
    
    private func handleShareableType(_ type: ShareableType, objectID: String) {
        switch type {
        case .show:
            onOpenSharedShow.send(objectID)
        case .creator:
            onOpenCreatorProfile.send(objectID)
        case .brand:
            onOpenBrandProfile.send(objectID)
        case .product:
            onOpenProductDetails.send(objectID)
        case .giftInvite:
            onOpenGiftRequest.send()
        case .promotedProducts:
            onOpenPromotedProducts.send(objectID)
        }
    }
    
    private func parseURLComponents(_ components: URLComponents, for key: String) -> String? {
        return components.queryItems?.first(where: { $0.name == key })?.value
    }
}

extension DeeplinkService: DeepLinkDelegate, AppsFlyerLibDelegate {

    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard let values = result.deepLink?.clickEvent, result.status == .found,
              let deeplinkValue = ShareableObject(data: values) else {
            return
        }
        handleShareableType(deeplinkValue.type, objectID: deeplinkValue.objectID)
    }
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        guard conversionInfo["af_status"] as? String != nil,
              let isFirstLaunch = conversionInfo["is_first_launch"] as? Bool, isFirstLaunch,
              let actionType = ShareableObject(data: conversionInfo as? [String:Any]) else {
            return
        }
        
        self.scheduledAppLaunchAction = actionType
    }
    
    func onConversionDataFail(_ error: Error) {
        print(error.localizedDescription)
    }
}

extension DeeplinkService: DeeplinkProvider {
    
    func generateShareURL(shareableObject: ShareableObject) async -> URL? {
        let shareURL = await AppsFlyerShareInviteHelper.generateInviteUrl { linkGenerator in
            linkGenerator.addParameterValue("true", forKey: "af_force_deeplink")
            linkGenerator.setAppleAppID(Constants.APP_ID)
            linkGenerator.setChannel(ShareLinkChannelType.mobileShare)
            linkGenerator.addParameterValue(shareableObject.objectID, forKey: shareableObject.type.afDecodingKey) // adding object id. Important for debugging
            if var redirectURL = shareableObject.redirectURL?.absoluteString {
                if let creatorID = shareableObject.shareParameters?[.creatorID] {
                    redirectURL.append("?ref=\(creatorID)")
                }
                linkGenerator.addParameterValue(redirectURL, forKey: "af_web_dp")
                linkGenerator.addParameterValue(redirectURL, forKey: "af_ios_url")
                linkGenerator.addParameterValue(redirectURL, forKey: "af_android_url")
            }
            
            if let creatorUsername = shareableObject.shareParameters?[.creatorUsername] {
                linkGenerator.setCampaign(creatorUsername)
            }
            if case .show = shareableObject.type, let creatorID = shareableObject.shareParameters?[.creatorID] {
                linkGenerator.addParameterValue(creatorID + " - " + shareableObject.objectID, forKey: "param_2")
            }
            
            return linkGenerator
        }
        
        return shareURL
    }
    
    func generateGiftingInviteURL() async -> URL? {
        return await AppsFlyerShareInviteHelper.generateInviteUrl { linkGenerator in
            linkGenerator.addParameterValue("true", forKey: "af_force_deeplink")
            linkGenerator.setAppleAppID(Constants.APP_ID)
            linkGenerator.addParameterValue("com.gifting_invite", forKey: ShareableType.giftInvite.afDecodingKey)
            return linkGenerator
        }
    }
}

#if DEBUG
struct MockDeeplinkProvider: DeeplinkProvider {
    
    func generateShareURL(shareableObject: ShareableObject) async -> URL? {
        await Task.sleep(seconds: 2.5)
        return URL(string: "https://join.onelink.me/")
    }
    
    func generateGiftingInviteURL() async -> URL? { nil }
}
#endif
