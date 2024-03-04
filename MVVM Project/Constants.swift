//
//  Constants.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import Foundation

struct Constants {
    
    #if PRODUCTION
    static let SERVER_URL = URL(string: "")!
    static let APP_ID = ""
    static let URL_SCHEME = "prod"
    #elseif STAGING
    static let SERVER_URL = URL(string: "")!
    static let APP_ID = ""
    static let URL_SCHEME = "stage"
    #elseif DEVELOPMENT
    static let SERVER_URL = URL(string: "")!
    static let APP_ID = ""
    static let URL_SCHEME = "dev"
    #endif
    
    static let APPLE_TEAM_ID = ""
    static let APP_VERSION = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
    static let APP_APPSTORE_URL = URL(string: "https://apps.apple.com/app/")
    
    static let PRIVACY_POLICY = URL(string: "https://www.google.com")!
    static let TERMS_AND_CONDITIONS = URL(string: "https://www.google.com")!
    static let COMMUNITY_GUIDELINES = URL(string: "https://www.google.com")!
    
    static let EMAIL_ADDRESS = "support@google.com"
    static let WEBSITE_URL = URL(string: "https://www.google.com/")!
    static let LANDING_PAGE_URL = URL(string: "https://www.google.com")!
    
    static let SENTRY_DSN = ""
    
    struct ApplePay {
        #if PRODUCTION
        static let MERCHANT_IDENTIFIER = "merchant.com.prod"
        static let STRIPE_KEY = ""
        #else
        static let MERCHANT_IDENTIFIER = "merchant.com.dev"
        static let STRIPE_KEY = ""
        #endif
        
        static let DEFAULT_REGION: String = "US"
        static let DEFAULT_CURRENCY: String = "USD"
    }
    
    struct AppsFlyer {
        static let DEV_KEY = ""
        #if PRODUCTION
        static let ONE_LINK_ID = ""
        static let REDIRECT_URL = URL(string: "")
        #elseif STAGING
        static let ONE_LINK_ID = ""
        static let REDIRECT_URL = URL(string: "")
        #elseif DEVELOPMENT
        static let ONE_LINK_ID = ""
        static let REDIRECT_URL = URL(string: "")
        #endif
    }
    
    struct LiveStreaming {
        static let APP_ID = ""
    }
    
    struct PushNotifications {
        #if PRODUCTION
        static let APP_ID = ""
        static let GCM_SENDER_ID = ""
        static let API_KEY = ""
        #elseif STAGING
        static let APP_ID = ""
        static let GCM_SENDER_ID = ""
        static let API_KEY = ""
        #elseif DEVELOPMENT
        static let APP_ID = ""
        static let GCM_SENDER_ID = ""
        static let API_KEY = ""
        #endif
        
        static let PROJECT_ID = ""
    }
    
    struct SocialMedia {
        static let instagram = URL(string: "instagram://")
        static let tiktok = URL(string: "tiktok://")
        static let youtube = URL(string: "youtube://")
        
        static func createSocialMediaURL(from socialMediaType: SocialMediaType) -> URL? {
            return URL(string: "https://\(socialMediaType.rawValue).com/")
        }
    }
    
    struct Analytics {
        static let UXCAM_KEY = ""
        #if PRODUCTION
        static let SEGMENT_KEY = ""
        #else
        static let SEGMENT_KEY = ""
        #endif
    }
}
