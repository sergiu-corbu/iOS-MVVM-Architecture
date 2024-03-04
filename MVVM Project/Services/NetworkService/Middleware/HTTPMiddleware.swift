//
//  HTTPMiddleware.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.12.2022.
//

import Foundation

enum HTTPResponseProcessingResult {
    case fail(Error)
    case retry(HTTPRetryMethod)
    case success(HTTPResponse)
}

protocol HTTPMiddleware: AnyObject, Identifiable {
    
    func processRequest(_ request: HTTPRequest) -> HTTPRequest
        
    func processResponse(_ response: HTTPResponse) -> HTTPResponseProcessingResult
    
    func shouldProcessRequest(_ httpRequest: HTTPRequest) -> Bool
    
    func shouldProcessResponse(_ response: HTTPResponse) -> Bool
}
