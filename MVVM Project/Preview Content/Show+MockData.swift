//
//  Show+MockData.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.12.2022.
//

import Foundation

#if DEBUG

fileprivate let showImageURL = URL(string: "https://s3.us-east-1.amazonaws.com/-")
fileprivate let showVideoURL = URL(string: "https://s3.us-east-1.amazonaws.com/-")

extension Show {
    
    //Mock data only
    init(title: String, publishingDate: Date, status: ShowStatus, type: ShowStreamingType = .recordedVideo, views: Int = .random(in: 0..<1_000_000), products: [Product], thumbnailURL: URL? = nil, videoURL: URL? = nil) {
        self.title = title
        self.publishingDate = publishingDate
        self.status = status
        self.views = views
        self.id = UUID().uuidString
        self.creator = User.creator
        self.productIds = Set<String>(arrayLiteral: UUID().uuidString)
        self.featuredProducts = products
        self.thumbnailUrl = thumbnailURL
        self.videoUrl = videoURL
        self.type = type
        self.channelName = nil
        self.teaserUrl = nil
        self.creatorID = "qwerty-"
        self.statusOrder = 1
        self.isFeatured = .random()
        self.isFavorite = .random()
    }
    
    static let sample = Show(title: "Sample Video Show", publishingDate: .now, status: .published, products: [Product.prod1, .prod2, .prod3, .prod5], thumbnailURL: showImageURL, videoURL: showVideoURL)
    static let scheduled = Show(title: "Scheduled Video Show with Products", publishingDate: .now.addingTimeInterval(5), status: .scheduled, products: [Product.prod1, .prod2])
    static let live = Show(title: "Live Video Show with Products", publishingDate: .now.addingTimeInterval(5), status: .scheduled, products: [Product.prod1, .prod2])
    static let uploading = Show(title: "Publishing Video Show", publishingDate: .now, status: .uploadingVideo, products: [Product.prod1, .prod2, .prod3, .prod5])
    static let compressing = Show(title: "Compressing Video Show", publishingDate: .now, status: .compressingVideo, products: [Product.prod1, .prod2, .prod3, .prod5])
    static let convertingVideo = Show(title: "Converting Video Show", publishingDate: .now, status: .convertingVideo, products: [Product.prod1, .prod2, .prod3, .prod5])
    static let published = Show(title: "Publishing Video Show", publishingDate: .now, status: .published, products: [Product.prod1])
    static let sample1 = Show(title: "Publishing Video Show", publishingDate: .now, status: .uploadingVideo, products: [Product.prod1])
    static let loadingProducts = Show(title: "Loading Products Show", publishingDate: .now, status: .uploadingVideo, products: [])
    
    static let liveStream = Show(title: "Live Show", publishingDate: .now, status: .live, type: .liveStream, products: [Product.prod1, .prod2, .prod3, .prod5])
    
    static var allShows: [Self] {
        return [sample, published, scheduled, uploading, compressing, convertingVideo, liveStream]
    }
}

#endif
