//
//  HTTPRequest.swift
//  NetworkLayer
//
//  Created by Sergiu Corbu on 26.07.2022.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol HTTPRequestConfiguration {
    
    var maxRetryCount: UInt { get }
    var currentRetryCount: UInt { get set }
    var isFallbackRequest: Bool { get set }
    
    var method: HTTPMethod { get }
    var path: String { get }
    var queryItems: [String: Any]? { get }
    var bodyParameters: [String: Any]? { get }
    var decodingKeyPath: String? { get }
    var headers: [String: String] { get }
    var encoding: HTTPClient.ParameterEncoding { get }
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
    
    var requiresUserSession: Bool { get }
}

class HTTPRequest: HTTPRequestConfiguration {
    
    let method: HTTPMethod
    let path: String
    var queryItems: [String : Any]?
    var bodyParameters: [String : Any]?
    var headers: [String : String] = [:]
    var encoding: HTTPClient.ParameterEncoding = .json
    
    var decodingKeyPath: String?
    var decoder: JSONDecoder = .default
    var encoder: JSONEncoder = .init()
    
    var requiresUserSession: Bool = true
    var maxRetryCount: UInt = 3
    var currentRetryCount: UInt = 0
    var isFallbackRequest: Bool = false
    
    internal init(maxRetryCount: UInt = 3, isFallbackRequest: Bool = false, method: HTTPMethod, path: String, queryItems: [String : Any]? = nil, bodyParameters: [String : Any]? = nil, headers: [String : String] = [:], encoding: HTTPClient.ParameterEncoding = .json, decodingKeyPath: String? = nil, decoder: JSONDecoder = .default, encoder: JSONEncoder = .init(), requiresUserSession: Bool = true) {
        self.maxRetryCount = maxRetryCount
        self.isFallbackRequest = isFallbackRequest
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.bodyParameters = bodyParameters
        self.headers = headers
        self.encoding = encoding
        self.decodingKeyPath = decodingKeyPath
        self.decoder = decoder
        self.encoder = encoder
        self.requiresUserSession = requiresUserSession
    }
}
