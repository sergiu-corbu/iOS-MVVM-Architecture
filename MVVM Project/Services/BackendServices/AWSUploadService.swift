//
//  AWSUploadService.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.11.2022.
//

import Foundation

protocol AWSUploadServiceProtocol {
    
    func uploadData(multipart: Multipart, uploadProgress: ((Double) -> Void)?) async throws
}

class AWSUploadService: AWSUploadServiceProtocol {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func uploadData(multipart: Multipart, uploadProgress: ((Double) -> Void)?) async throws {
        let uploadRequest = try await sendUploadRequest(with: multipart)
        return try await client.upload(request: uploadRequest, multipart: multipart, uploadProgress: uploadProgress)
    }
    
    private func sendUploadRequest(with multipart: Multipart) async throws -> UploadRequest {
        var parameters = [
            Multipart.UploadKeys.fileName: multipart.fileName,
            Multipart.UploadKeys.mimeType: multipart.uploadScope.mimeType.rawValue,
            Multipart.UploadKeys.uploadScope: multipart.uploadScope.rawValue
        ]
        parameters[Multipart.UploadKeys.owner] = multipart.owner
        
        let uploadRequest = HTTPRequest(
            method: .post,
            path: "v1/uploads",
            bodyParameters: parameters,
            encoding: .json,
            decodingKeyPath: "upload"
        )
        return try await client.sendRequest(uploadRequest)
    }
}

#if DEBUG
struct MockAWSUploadService: AWSUploadServiceProtocol {
    
    func uploadData(multipart: Multipart, uploadProgress: ((Double) -> Void)?) async throws {
        
    }
}
#endif
