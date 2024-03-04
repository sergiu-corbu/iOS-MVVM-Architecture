//
//  ForceUpdateMiddleware.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.06.2023.
//
import Foundation
import Combine

class ForceUpdateMiddleware: HTTPMiddleware {
    let forceUpdatePublisher = PassthroughSubject<Void, Never>()
    
    func shouldProcessResponse(_ response: HTTPResponse) -> Bool {
        return response.httpURLResponse?.statusCode == NetworkError.ErrorCode.forceUpdate
    }
    
    func processResponse(_ response: HTTPResponse) -> HTTPResponseProcessingResult {
        forceUpdatePublisher.send()
        return .fail(NetworkError.appUpdateRequired)
    }
    
    func shouldProcessRequest(_ httpRequest: HTTPRequest) -> Bool {
        return false
    }
    func processRequest(_ request: HTTPRequest) -> HTTPRequest {
        return request
    }
}

