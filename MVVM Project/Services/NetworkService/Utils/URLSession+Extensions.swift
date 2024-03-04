//
//  URLSession+Extensions.swift
//  NetworkLayer
//
//  Created by Sergiu Corbu on 08.08.2022.
//

import Foundation

extension URLSession {
    
    @discardableResult
    func upload(for request: URLRequest, with data: Data) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let uploadTask = self.uploadTask(with: request, from: data) { (data, response, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: NetworkError.unknown)
                }
            }
            uploadTask.resume()
        }
    }
}
