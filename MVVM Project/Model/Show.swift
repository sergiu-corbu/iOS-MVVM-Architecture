//
//  Show.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.12.2022.
//

import Foundation

struct Show: Decodable, Hashable, StringIdentifiable {
    
    let id: String
    let creatorID: String
    let creator: Creator?
    let title: String?
    let publishingDate: Date?
    let productIds: Set<String>
    var status: ShowStatus
    let type: ShowStreamingType
    let views: Int
    let statusOrder: Int
    let isFeatured: Bool
    var featuredProducts: [Product]?
    let isFavorite: Bool
    
    let thumbnailUrl: URL?
    let videoUrl: URL?
    let teaserUrl: URL?
    let channelName: String?
    
    var shouldBeUsedInLiveStream: Bool {
        return type == .liveStream && [.scheduled, .live].contains(status)
    }
    
    var uniqueFeaturedBrands: OrderedSet<Brand> {
        return OrderedSet(featuredProducts?.map(\.brand) ?? [])
    }
    
    /// to be used on discover preview show
    var previewVideoURL: URL? {
        if case .published = status {
            return videoUrl
        }
        return teaserUrl ?? videoUrl
    }
    
    var isProcessingVideo: Bool {
        return [.uploadingVideo, .convertingVideo, .compressingVideo].contains(status)
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case creator = "user"
        case creatorID = "userId"
        case productIds
        case status
        case views
        case title
        case publishingDate
        case videoUrl
        case featuredProducts = "products"
        case thumbnailUrl
        case type
        case channelName
        case teaserUrl
        case statusOrder
        case isFeatured, isFavorite
    }
}

extension Show {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.creatorID = try container.decode(String.self, forKey: .creatorID)
        self.creator = try container.decodeIfPresent(Creator.self, forKey: .creator)
        self.productIds = try container.decode(Set<String>.self, forKey: .productIds)
        self.views = try container.decode(Int.self, forKey: .views)
        self.statusOrder = try container.decode(Int.self, forKey: .statusOrder)
        self.isFeatured = try container.decodeIfPresent(Bool.self, forKey: .isFeatured) ?? false
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.publishingDate = try container.decodeIfPresent(Date.self, forKey: .publishingDate)
        self.videoUrl = try container.decodeIfPresent(URL.self, forKey: .videoUrl)
        self.featuredProducts = try container.decodeIfPresent(Array<Product>.self, forKey: .featuredProducts)
        self.thumbnailUrl = try container.decodeIfPresent(URL.self, forKey: .thumbnailUrl)
        self.teaserUrl = try container.decodeIfPresent(URL.self, forKey: .teaserUrl)
        self.channelName = try container.decodeIfPresent(String.self, forKey: .channelName)
        self.type = try container.decodeIfPresent(ShowStreamingType.self, forKey: .type) ?? .recordedVideo
        self.status = ShowStatus(rawValue: try container.decode(String.self, forKey: .status)) ?? .draft
        self.isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }
}

enum ShowStatus: String, Decodable {
    case published
    case compressingVideo
    case uploadingVideo
    case convertingVideo
    case scheduled
    case draft
    case live
    
    var processingData: (label: String, description: String)? {
        switch self {
        case .compressingVideo: return (Strings.ContentCreation.videoIsCompressing, "Step 1/2")
        case .uploadingVideo: return (Strings.ContentCreation.videoIsUploading, "Step 2/2")
        case .convertingVideo: return (Strings.ContentCreation.videoIsProcessing, "")
        default: return nil
        }
    }
}

extension Show {
    
    var shareableObject: ShareableObject {
        var shareParameters: ShareParameters {
            var parameters = ShareParameters()
            parameters[.creatorID] = creatorID
            parameters[.creatorUsername] = creator?.formattedUsername
            return parameters
        }
        
        return ShareableObject(
            objectID: self.id, type: .show, shareParameters: shareParameters, shareName: creator?.fullName
        )
    }
    
    var baseAnalyticsProperties: AnalyticsProperties {
        var properties = AnalyticsProperties()
        properties[.show_name] = title
        properties[.show_id] = id
        properties[.creator_username] = creator?.formattedUsername
        properties[.creator_id] = creator?.id
        properties[.show_type] = type.rawValue
        properties[.is_teaser] = status == .scheduled
        
        return properties
    }
}
