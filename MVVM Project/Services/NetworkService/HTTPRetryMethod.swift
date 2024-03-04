//
//  HTTPRetryStrategy.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.02.2023.
//

import Foundation

enum HTTPRetryMethod {
    case immediate
    case delayed(_ delay: TimeInterval)
    case afterRequest(_ request: HTTPRequest, _ delay: TimeInterval, fallbackResponseHandler: ((HTTPResponse)->HTTPResponse)?)
    case afterTask(_ delay: TimeInterval, _ task: (_ originalRequest: HTTPRequest) async throws -> Void, _ errorHandler: (_ error: Error) async -> Void)
    
    func retryDelay(forRequest request: HTTPRequest) -> TimeInterval {
        switch self {
        case .immediate:
            return 0
            
        case .delayed(let delay):
            return delay
            
        case .afterRequest:
            return 0
            
        case .afterTask:
            return 0
        }
    }
}
