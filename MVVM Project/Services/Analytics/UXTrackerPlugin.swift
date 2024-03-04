//
//  AnalyticsUXTrackerPlugin.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.07.2023.
//

import Foundation
import Segment
import UXCam
import UXCamSwiftUI

class AnalyticsUXTrackerPlugin: EventPlugin {
    let type: PluginType = .destination
    var analytics: Analytics? = nil
    
    init(analytics: Analytics? = nil) {
        self.analytics = analytics
        
        UXCamCore.optIntoSchematicRecordings()
        let config = Configuration(appKey: Constants.Analytics.UXCAM_KEY)
        config.enableNetworkLogging = true
        UXCamSwiftUI.start(with: config)
    }
    
    func identify(event: IdentifyEvent) -> IdentifyEvent? {
        UXCamCore.setUserIdentity(UIDevice.current.identifierForVendor?.uuidString ?? UIDevice.current.name)
        
        if case let .object(dict) = event.traits {
            dict.forEach { (key: String, value: JSON) in
                UXCamCore.setUserProperty(key, value: value.toString())
            }
        }
        
        return event
    }
    
    func alias(event: AliasEvent) -> AliasEvent? {
        UXCamCore.setUserIdentity(UIDevice.current.identifierForVendor?.uuidString ?? UIDevice.current.name)
        
        return event
    }
    
    func track(event: TrackEvent) -> TrackEvent? {
        if case let .object(dict) = event.properties {
            let properties = dict.reduce(into: [String: String]()) { (partialResult, value) in
                let (key, value) = value
                partialResult["\(key)"] = "\(value.toString())"
            }
            
            UXCamCore.logEvent(event.event, withProperties: properties)
        }
        
        return event
    }
    
    func screen(event: ScreenEvent) -> ScreenEvent? {
        if let name = event.name {
            UXCamCore.tagScreenName(name)
        }
        
        return event
    }
    
    func toggleUXOcclusion(_ on: Bool) {
            UXCamCore.occludeSensitiveScreen(on)
        }
}
