//
//  AnalyticsService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 25.04.2023.
//

import Foundation
import Segment
import SegmentAmplitude
import StoreKit

typealias AnalyticsProperties = [AnalyticsService.EventProperty: Any]

protocol AnalyticsServiceProtocol {
    
    func setup()
    func identify(user: User?)
    func identifyAlias(temporaryID: String)
    func reset()
    
    func trackScreenEvent(_ screenEventType: AnalyticsService.ScreenEvent, properties: AnalyticsProperties?)
    func trackActionEvent(_ actionEventType: AnalyticsService.ActionEvent, properties: AnalyticsProperties?)
    func trackCustomEvent(_ eventName: String, properties: AnalyticsProperties?)
    
    func toggleUXOcclusion(_ on: Bool)
}

class AnalyticsService: AnalyticsServiceProtocol {
    
    static let shared = AnalyticsService()
    
    private var analytics: Analytics?
    private var didSetup = false
    private var currentUserTraits: [String:Any]?
    
    lazy private var screenTrackerPlugin = AnalyticsUXTrackerPlugin()
    
    @UserDefault(key: UserSession.StorageKeys.notificationsPermissionEnabled, defaultValue: false)
    static var notificationsPermissionEnabled: Bool
    
    //MARK: - Setup and Configuration
    func setup() {
        guard !didSetup else {
            return
        }
        
        let config = Configuration(writeKey: Constants.Analytics.SEGMENT_KEY)
        config.trackApplicationLifecycleEvents(true)
        self.analytics = Analytics(configuration: config)
        analytics?.add(plugin: AmplitudeSession())
        #if PRODUCTION
        analytics?.add(plugin: screenTrackerPlugin)
        #endif
        
        didSetup = true
    }
    
    func identify(user: User?) {
        guard let user else {
            return
        }
        
        analytics?.identify(userId: user.id, traits: mapUserTraits(user: user))
    }
    
    func identifyAlias(temporaryID: String) {
        analytics?.alias(newId: temporaryID)
        mapAliasTraits(aliasID: temporaryID)
    }
    
    func reset() {
        analytics?.reset()
    }
    
    //MARK: - Tracking
    func trackScreenEvent(_ screenEventType: AnalyticsService.ScreenEvent, properties: AnalyticsProperties?) {
        analytics?.screen(title: screenEventType.rawValue.capitalized, properties: mergeUserTraits(with: properties))
    }
    
    func trackActionEvent(_ actionEventType: AnalyticsService.ActionEvent, properties: AnalyticsProperties?) {
        analytics?.track(name: actionEventType.rawValue.capitalized, properties: mergeUserTraits(with: properties))
        updateSKAdEventConversionValue(conversionValue: actionEventType.skadEventValue)
    }
    
    func trackCustomEvent(_ eventName: String, properties: AnalyticsProperties?) {
        analytics?.screen(title: eventName.capitalized, properties: mergeUserTraits(with: properties))
    }
    
    //MARK: - UX Tracking
     func toggleUXOcclusion(_ on: Bool) {
         screenTrackerPlugin.toggleUXOcclusion(on)
     }
    
    //MARK: - SKAd Event handling
    private func updateSKAdEventConversionValue(conversionValue: Int?) {
        guard let conversionValue else {
            return
        }
        SKAdNetwork.updatePostbackConversionValue(conversionValue)
    }
    
    class func mappedProperties(_ properties: AnalyticsProperties?) -> Dictionary<String, Any> {
        guard let properties else {
            return [:]
        }
        return Dictionary(
            uniqueKeysWithValues: properties.map { ($0.key.rawValue, $0.value) }
        )
    }
}

fileprivate extension AnalyticsService {
    
    func mapProperties<EventType: RawRepresentable>(
        _ properties: [EventType : Any]?
    ) -> Dictionary<String, Any>? where EventType.RawValue == String {
        return Dictionary(uniqueKeysWithValues: properties?.compactMap { ($0.key.rawValue, $0.value)} ?? [])
    }
    
    func mapUserTraits(user: User) -> Dictionary<String, Any>? {
        var userTraits = [UserTrait : Any]()
        userTraits[.user_id] = user.id
        userTraits[.username] = user.username
        userTraits[.email] = user.email
        userTraits[.createdAt] = user.createdAt
        userTraits[.account_type] = user.role.rawValue
        userTraits[.total_orders] = user.numberOfOrders
        userTraits[.notification_permission] = Self.notificationsPermissionEnabled
        userTraits[.app_locale] = Locale.current.language.region?.identifier
        
        self.currentUserTraits = self.mapProperties(userTraits)
        return currentUserTraits
    }
    
    @discardableResult
    func mapAliasTraits(aliasID: String) -> Dictionary<String, Any>? {
        var userTraits = [UserTrait : Any]()
        userTraits[.user_id] = ""
        userTraits[.account_type] = User.Role.shopper.rawValue
        userTraits[.app_locale] = Locale.current.language.region?.identifier
        
        self.currentUserTraits = self.mapProperties(userTraits)
        return currentUserTraits
    }
    
    func mergeUserTraits(with otherProperties: AnalyticsProperties?) -> Dictionary<String, Any>? {
        var mappedProperties = mapProperties(otherProperties)
        if let currentUserTraits {
            mappedProperties?.merge(other: currentUserTraits)
        }
        return mappedProperties
    }
}

#if DEBUG
struct MockAnalyticsService: AnalyticsServiceProtocol {
    
    func reset() {}
    func identify(user: User?) {}
    func identifyAlias(temporaryID: String) {}
    func trackActionEvent(_ actionEventType: AnalyticsService.ActionEvent, properties: AnalyticsProperties?) {}
    func trackCustomEvent(_ eventName: String, properties: AnalyticsProperties?) {}
    func trackScreenEvent(_ screenEventType: AnalyticsService.ScreenEvent, properties: AnalyticsProperties?) {}
    func setup() {}
    func toggleUXOcclusion(_ on: Bool) {}
}
#endif
