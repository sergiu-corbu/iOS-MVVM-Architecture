//
//  LiveStreamResponse.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 20.03.2023.
//

import Foundation

protocol LiveStreamConnectable {
    var token: String { get }
    var userID: UInt { get }
    var channelName: String { get }
}

struct LiveStreamResponse: Decodable, LiveStreamConnectable {
    
    let show: Show
    let liveStreamToken: String
    let liveStreamUserID: UInt
    
    enum CodingKeys: String, CodingKey {
        case show
        case liveStreamToken = "token"
        case liveStreamUserID = "uid"
    }
    
    var userID: UInt {
        return liveStreamUserID
    }
    var token: String {
        return liveStreamToken
    }
    var channelName: String {
        return show.channelName ?? ""
    }
}

struct LiveStreamConnectingData: Decodable, LiveStreamConnectable {
    
    let liveStreamToken: String
    let liveStreamUserID: UInt
    let channelName: String
    
    enum CodingKeys: String, CodingKey {
        case channelName
        case liveStreamToken = "token"
        case liveStreamUserID = "uid"
    }
    
    var token: String {
        return liveStreamToken
    }
    var userID: UInt {
        return liveStreamUserID
    }
}
