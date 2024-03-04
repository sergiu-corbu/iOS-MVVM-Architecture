//
//  ErrorService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.04.2023.
//

import Foundation
import Sentry

struct ErrorService {
    
    static func setup() {
        SentrySDK.start { options in
            options.dsn = Constants.SENTRY_DSN
            options.attachScreenshot = true
            options.attachViewHierarchy = true
            options.tracesSampleRate = 1
            options.failedRequestStatusCodes = [HttpStatusCodeRange(min: 505, max: 599)]
            #if PRODUCTION
            options.environment = "production"
            #elseif STAGING
            options.environment = "staging"
            #else
            options.environment = "development"
            #endif
        }
    }
    
    static func trackEvent(message: String) {
        SentrySDK.capture(message: message)
    }
}
