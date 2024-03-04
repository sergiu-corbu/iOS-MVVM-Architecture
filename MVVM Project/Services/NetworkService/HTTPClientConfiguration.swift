//
//  HTTPClientConfiguration.swift
//  NetworkLayer
//
//  Created by Sergiu Corbu on 26.07.2022.
//

import Foundation
import UIKit

typealias HTTPHeaders = [String : String]

protocol HTTPClientConfiguration {
    
    var serverURL: URL { get }
    var urlConfiguration: URLSessionConfiguration { get }
    var validStatusCodes: ClosedRange<Int> { get }
    var httpHeaders: [String: String] { get }
    var timeoutInterval: TimeInterval { get }
}

extension HTTPClientConfiguration {
    
    var timeoutInterval: TimeInterval {
        return 30.0
    }
    
    func isValidStatusCode(_ statusCode: Int) -> Bool {
        return validStatusCodes.contains(statusCode)
    }
}

struct DefaultClientConfiguration: HTTPClientConfiguration {
    
    let serverURL: URL
    let validStatusCodes: ClosedRange<Int> = (200...299)
        
    init(serverURL: URL) {
        self.serverURL = serverURL
    }
    
    init() {
        self.serverURL = Constants.SERVER_URL
    }
    
    var urlConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return config
    }
    
    var httpHeaders: HTTPHeaders {
        var headers = HTTPHeaders()
        headers["App-Agent"] = userAgent
        return headers
    }
    
    private let userAgent: String = {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let osVersion = UIDevice.current.systemVersion
        let appName = "APP"
        return ["ios ", osVersion, " \(appName)/", appVersion].compactMap{ $0 as? String}.joined()
    }()
}
