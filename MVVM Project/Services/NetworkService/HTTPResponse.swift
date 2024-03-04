//
//  HTTPResponse.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.02.2023.
//

import Foundation

class HTTPResponse {
    let request: HTTPRequest
    let urlRequest: URLRequest
    let urlResponse: URLResponse
    let data: Data
    
    var httpURLResponse: HTTPURLResponse? {
        return urlResponse as? HTTPURLResponse
    }
    var error: Error?
    
    init(request: HTTPRequest, urlRequest: URLRequest, urlResponse: URLResponse, data: Data) {
        self.request = request
        self.urlRequest = urlRequest
        self.urlResponse = urlResponse
        self.data = data
    }
    
    func decoded<T: Decodable>() async throws -> T {
        return try await decoded(decoder: request.decoder)
    }
    
    func decoded<T: Decodable>(decoder: JSONDecoder) async throws -> T {
            do {
                if let decodingKeyPath = request.decodingKeyPath {
                    return try decoder.decode(
                        T.self,
                        from: data,
                        keyPath: decodingKeyPath
                    )
                } else {
                    return try decoder.decode(T.self, from: data)
                }
            } catch(let error as DecodingError) {
                print(error.debugDescription)
                throw error
            } catch {
                print("unknown error", error.localizedDescription)
                throw error
            }
        
    }
}
