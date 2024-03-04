//
//  HTTPClient.swift
//  NetworkLayer
//
//  Created by Sergiu Corbu on 26.07.2022.
//

import Foundation
import Combine

class HTTPClient {
    
    let configuration: HTTPClientConfiguration
    private var middlewares = [any HTTPMiddleware]()
    private(set) var session: URLSession
    
    private lazy var decoder = JSONDecoder()
    
    init(configuration: HTTPClientConfiguration) {
        self.configuration = configuration
        self.session = URLSession(configuration: configuration.urlConfiguration)
    }
    
    init(session: URLSession, configuration: HTTPClientConfiguration) {
        self.session = session
        self.configuration = configuration
    }
    
    private func sendRequest(_ httpRequest: HTTPRequest) async throws -> HTTPResponse {
        let processedRequest = processedRequest(request: httpRequest)
        let response = try await fetch(processedRequest)
        let validatedResponse = try await validate(response)
        return validatedResponse
    }
    
    func sendRequest<T: Decodable>(_ httpRequest: HTTPRequest) async throws -> T {
        let response: HTTPResponse = try await sendRequest(httpRequest)
        return try await response.decoded()
    }
    
    func sendRequest(_ httpRequest: HTTPRequest) async throws {
        do {
            let _: HTTPResponse = try await sendRequest(httpRequest)
            return
        } catch (let error as CancellationError) {
            print(error.localizedDescription)
        }
    }
}

extension HTTPClient {
    
    private func makeURLRequest(with httpRequest: HTTPRequest) throws -> URLRequest {
        
        var url = configuration.serverURL.appendingPathComponent(httpRequest.path)
        
        // adding query items
        if let queryParameters = httpRequest.queryItems,
           var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            urlComponents.queryItems = createQueryItems(from: queryParameters)
            url = urlComponents.url ?? url //update the url with the added query items
        }
        
        // create the url request
        var request = URLRequest(url: url)
        request.httpMethod = httpRequest.method.rawValue
        
        // add configuration headers
        configuration.httpHeaders.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // add custom headers
        httpRequest.headers.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        //set the body of the request
        if let bodyParameters = httpRequest.bodyParameters,
           httpRequest.method != .get {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters)
        }
        
        // header value for body content type
        if httpRequest.bodyParameters?.isEmpty == false {
            request.setValue(
                httpRequest.encoding.headerValue,
                forHTTPHeaderField: HeaderFields.contentType
            )
        }
        
        request.timeoutInterval = configuration.timeoutInterval
        
        return request
    }
    
    private func fetch(_ httpRequest: HTTPRequest) async throws -> HTTPResponse {
        try Task.checkCancellation()
        let urlRequest = try makeURLRequest(with: httpRequest)
        
        do {
            let (data, response): (Data, URLResponse) = try await session.data(for: urlRequest)
            let httpResponse = HTTPResponse(
                request: httpRequest,
                urlRequest: urlRequest,
                urlResponse: response,
                data: data
            )
            
            return httpResponse
        }
    }
}

extension HTTPClient {
    
    func validate(_ response: HTTPResponse) async throws -> HTTPResponse {
        let validatedResponse = response
        // send the response to middlewares for processing, and then evaluate result
        let processingResult = self.processResponse(response: response)
        
        // ignore response validation result on fallback requests
        if validatedResponse.request.isFallbackRequest {
            return response
        }
        
        switch processingResult {
        case .success(let successResponse):
            // default response validation. We could remove this and leave everything on middlewares (we could also implement some default middlewares that has generic error handling)
            guard let statusCode = response.httpURLResponse?.statusCode else {
                throw NetworkError.invalidHTTPStatusCode
            }
            
            guard configuration.isValidStatusCode(statusCode) else {
                print(
                    "\n Request failed: ",
                    response.request.method.rawValue,
                    response.urlResponse.url?.absoluteString ?? "",
                    "\n\tResponse: " + (response.data.dataAsString ?? ""),
                    statusCode.description
                )
                
                let networkError: Error? = try? decoder.decode(NetworkError.self, from: response.data)
                validatedResponse.error = networkError
                
                throw networkError ?? NetworkError.invalidErrorFormat
            }
            
            return successResponse
        case .fail(let error):
            validatedResponse.error = error
            throw error
        case .retry(let retryMethod):
            return try await performRetry(method: retryMethod, for: response)
        }
    }
}

// MARK: - Middleware functionality
extension HTTPClient {
    
    func addMiddleware(_ middleware: any HTTPMiddleware) {
        middlewares.append(middleware)
    }

//    func removeMiddleware(_ middleware: any HTTPMiddleware) {
////        middlewares.remove
//    }

    func clearMiddlewares() {
        middlewares = []
    }

    func processedRequest(request: HTTPRequest) -> HTTPRequest {
        var request = request
        for middleware in middlewares {
            if middleware.shouldProcessRequest(request) {
                request = middleware.processRequest(request)
            }
        }
        return request
    }
    
    internal func processResponse(response: HTTPResponse) -> HTTPResponseProcessingResult {
        var processedResponse = response
        for middleware in middlewares {
            if middleware.shouldProcessResponse(response) {
                let result = middleware.processResponse(response)
                guard case .success(let middlewareResponse) = result else {
                    return result
                }
                    
                processedResponse = middlewareResponse
            }
        }
        
        return .success(processedResponse)
    }
}

// MARK: - Retry Functionality
extension HTTPClient {
    func performRetry(method: HTTPRetryMethod, for response: HTTPResponse) async throws -> HTTPResponse {
        let request = response.request
        
        guard request.currentRetryCount < request.maxRetryCount else {
            throw NetworkError.maxRetryAttemptsReached
        }
        
        switch method {
        case .immediate, .delayed:
            let delay = method.retryDelay(forRequest: request)
            await Task.sleep(seconds: delay)
            
            request.currentRetryCount += 1
            let retryResponse: HTTPResponse = try await sendRequest(request)
            return retryResponse
            
        case .afterRequest(let fallbackRequest, let delay, let fallbackResponseHandler):
            fallbackRequest.currentRetryCount += 1
            fallbackRequest.isFallbackRequest = true
            do {
                let fallbackResponse: HTTPResponse = try await sendRequest(fallbackRequest)
                let _ = fallbackResponseHandler?(fallbackResponse)
            } catch {
                // return initial response if fallback request failed
                // this means that the retry will no longer be performed
                return response
            }
            
            await Task.sleep(seconds: delay)
            request.currentRetryCount += 1
            let retryResponse: HTTPResponse = try await sendRequest(request)
            return retryResponse
            
        case .afterTask(let delay, let task, let errorHandler):
            do {
                try await task(request)
            } catch {
                await errorHandler(error)
                // return initial response if fallback task failed
                // this means that the retry will no longer be performed
                return response
            }
            
            await Task.sleep(seconds: delay)
            request.currentRetryCount += 1
            
            let retryResponse: HTTPResponse = try await sendRequest(request)
            return retryResponse
        }
    }
}

extension HTTPClient {
    
    func validate(_ response: URLResponse, for request: URLRequest, data: Data) throws {
        
    }
}

extension HTTPClient {
    struct HeaderFields {
        static let contentType = "Content-Type"
        static let accessTokenKey = "Authorization"
        static let multipartHeader = "multipart/form-data;"
    }
}
