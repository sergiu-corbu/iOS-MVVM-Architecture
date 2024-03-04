//
//  MediaAlbum.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.12.2022.
//

import Foundation

struct MediaAlbum: Decodable, Hashable, Comparable {

    let id: UInt
    let imageURL: URL?
    let displayOrder: UInt
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "sourceUrl"
        case displayOrder
    }
    
    static func >(lhs: Self, rhs: Self) -> Bool {
        return lhs.displayOrder > rhs.displayOrder
    }
    
    static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.displayOrder < rhs.displayOrder
    }
}

struct MediaAlbumsResponse: Decodable {
    let id: UInt
    let mediaAlbums: [MediaAlbum]
    
    enum CodingKeys: String, CodingKey {
        case id
        case mediaAlbums = "media"
    }
}
