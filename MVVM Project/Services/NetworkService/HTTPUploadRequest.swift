//
//  HTTPUploadRequest.swift
//  NetworkLayer
//
//  Created by Sergiu Corbu on 03.10.2022.
//

import Foundation

enum UploadScope: String {
    
    case profilePicture = "userProfilePicture"
    case videoShow
    case thumbnailShow
    case teaserShow
    
    var mimeType: MimeType {
        switch self {
        case .profilePicture, .thumbnailShow: return .jpegImage
        case .videoShow, .teaserShow: return .video
        }
    }
}

enum MimeType: String {
    case jpegImage = "image/jpg"
    case video = "video/mp4"
}

let UploadImageMaxSize: UInt = 1600 // pixel
let JPEGCompressionQuality = 0.8

struct UploadRequest: Codable {
    let url: URL
    let fields: [String:String]
}
