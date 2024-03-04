//
//  ShowSearchResult.swift
//  MVVM Project
//
//  Created by Doru Cojocaru on 20.07.2023.
//

import Foundation

struct SearchResult: Decodable, Hashable {
    let brands: [Brand]
    let creators: [Creator]
    let products: [Product]
    let shows: [Show]
    let facets: [FilterFacet]?

    var isEmpty: Bool {
        let allFields: [[Any]] = [brands, creators, products, shows]
        let noResults = allFields.allSatisfy{$0.isEmpty}
        return noResults
    }

    var configs: [SearchResultItemView.Config] {
        var data = [SearchResultItemView.Config]()
        data.append(contentsOf: shows.map{SearchResultItemView.Config.show($0)})
        data.append(contentsOf: creators.map{SearchResultItemView.Config.creator($0)})
        data.append(contentsOf: brands.map{SearchResultItemView.Config.brand($0)})
        data.append(contentsOf: products.map{SearchResultItemView.Config.product($0)})
        return data
    }
}

struct FilterFacet: Decodable, Hashable {
    let filterType: FilterSectionType
    var values: [FacetValue]
    
    struct FacetValue: Decodable, Hashable {
        let label: String //used as display data
        let value: String //used as search request parameter
        var count: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case filterType = "name"
        case values = "options"
    }
    
    init(filterType: FilterSectionType, values: [FacetValue]) {
        self.filterType = filterType
        self.values = values
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.filterType = FilterSectionType(rawValue: try container.decode(String.self, forKey: .filterType)) ?? .brands
        self.values = try container.decode([FacetValue].self, forKey: .values)
    }
}

#if DEBUG
extension FilterFacet {
    
    static let sampleBrands = FilterFacet(
        filterType: .brands,
        values: [FacetValue(label: "Baldinini", value: "Baldinini", count: 2), FacetValue(label: "Bali", value: "Bali", count: 10)]
    )
        
    static let sampleCategories = FilterFacet(
        filterType: .categories,
        values: [FacetValue(label: "Shoes", value: "Shoes", count: 3), FacetValue(label: "Hats", value: "Hats", count: 1)]
    )
    
    static let sampleSizes = FilterFacet(
        filterType: .sizes,
        values: [FacetValue(label: "S", value: "S", count: 20), FacetValue(label: "M", value: "M", count: 5), FacetValue(label: "XXL", value: "XXL", count: 9), FacetValue(label: "XXLAAAA", value: "XXLAAAA", count: 1149), FacetValue(label: "XXLLLLA", value: "XXLLLLA", count: 2229), FacetValue(label: "XXLLLL", value: "XXLLLL", count: 119)]
    )
    
    static let mockedFacets = [sampleBrands, sampleCategories, sampleSizes]
}
#endif

extension SearchResult {
    struct Show: Decodable, Hashable {
        private enum CodingKeys: String, CodingKey {
            case id, thumbnailUrl, title, videoUrl, status
            case _publishingDate = "publishingDate"
        }

        let id: String
        let thumbnailUrl: URL?
        let title: String
        let status: ShowStatus
        let videoUrl: URL?
        private let _publishingDate: Double
        var publishingDate: Date {
            Date(timeIntervalSince1970: _publishingDate)
        }

        static var mocked: Show {
            Show(id: "show-id", thumbnailUrl: nil, title: "men", status: .scheduled, videoUrl: nil, _publishingDate: 1690175359)
        }
    }
}

extension SearchResult {
    struct Brand: Decodable, Hashable {
        let id: String
//        let followers: Int Not needed anylonger
        let logoPictureUrl: URL?
        let name: String

        static var mocked: Brand {
            Brand(id: "brand-id", logoPictureUrl: .sampleImageURL, name: "Test Brand")
        }
    }
}

extension SearchResult {
    struct Product: Decodable, Hashable {
        let id: String
        let currency: String
        let minPrice: Double
        let name: String
        let brandName: String
        let pictureUrl: URL?

        static var mocked: Product {
            Product(id: "product-id", currency: "USD", minPrice: 300, name: "Yeezy Jeans", brandName: "Bottega Venetta", pictureUrl: .sampleImageURL)
        }
        
        enum CodingKeys: String, CodingKey {
            case id, currency, minPrice, name
            case brandName = "brand", pictureUrl
        }
    }
}

extension SearchResult {
    struct Creator: Decodable, Hashable {
        let id: String
        let fullName: String
        let username: String
        let profilePictureUrl: URL?

        var formattedName: String {
            "@" + username
        }

        static var mocked: Creator {
            Creator(id: "creator-id", fullName: "Test Creator", username: "testCreator", profilePictureUrl: .sampleImageURL)
        }
    }
}
