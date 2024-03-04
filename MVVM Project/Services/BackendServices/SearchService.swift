//
//  SearchService.swift
//  MVVM Project
//
//  Created by Doru Cojocaru on 19.07.2023.
//

import Foundation


protocol SearchServiceProtocol {
    func search(filter: SearchFilter) async throws -> SearchResult
}

class SearchService: SearchServiceProtocol {
    
    let client: HTTPClient
    private lazy var encoder = JSONEncoder()
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func search(filter: SearchFilter) async throws -> SearchResult {
        let request = HTTPRequest(method: .get, path: "v1/search", queryItems: try encoder.encodeToHashMap(filter))
        return try await client.sendRequest(request)
    }
}

struct SearchFilter: Encodable {
    
    let query: String
    let searchTag: SearchTag
    var currentPage: Int
    let pageSize: Int
    
    var brands: [String]?
    var categories: [String]?
    var sizes: [String]?
    var priceSorting: PriceSortingType?
    
    var didLoadLastPage = false
    
    var activeFiltersCount: Int {
        return (brands?.count ?? 0) + (categories?.count ?? 0) + (sizes?.count ?? 0) + (priceSorting != nil ? 1 : 0)
    }
    
    static let initialProductsFilter = SearchFilter(query: "", searchTag: .products, currentPage: 1, pageSize: 20, priceSorting: .lowToHigh)
    
    mutating func applyFiltersAndSorting(facets: [FilterSectionType: Set<FilterFacet.FacetValue>], sorting: PriceSortingType?) {
        for facet in facets {
            let facetValues = facets[facet.key]?.map(\.value)
            switch facet.key {
            case .brands: brands = facetValues
            case .categories: categories = facetValues
            case .sizes: sizes = facetValues
            }
        }
        priceSorting = sorting
    }
    
    mutating func resetFiltersAndSorting() {
        brands = nil
        categories = nil
        sizes = nil
        priceSorting = nil
        currentPage = 1
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        //base request
        try container.encode(query, forKey: .query)
        try container.encode(searchTag.rawValue.lowercased(), forKey: .searchTag)
        try container.encode(currentPage, forKey: .currentPage)
        try container.encode(pageSize, forKey: .pageSize)
        
        //filter
        try container.encodeIfPresent(brands?.joined(separator: ","), forKey: .brands)
        try container.encodeIfPresent(categories?.joined(separator: ","), forKey: .categories)
        try container.encodeIfPresent(sizes?.joined(separator: ","), forKey: .sizes)
        
        //sort
        if let sortDirection = priceSorting?.sortDirection {
            try container.encode(sortDirection, forKey: .priceSorting)
            try container.encode("minPrice", forKey: .sortField) //hardcoded for now
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case query = "search"
        case searchTag = "filter"
        case pageSize = "length"
        case currentPage = "page"
        case priceSorting = "sortDirection"
        case sortField
        case brands, sizes, categories
    }
}

#if DEBUG
struct MockSearchService: SearchServiceProtocol {
    
    func search(filter: SearchFilter) async throws -> SearchResult {
        await Task.debugSleep()
        return SearchResult(brands: [SearchResult.Brand.mocked],
                            creators: [SearchResult.Creator.mocked],
                            products: [SearchResult.Product.mocked],
                            shows: [SearchResult.Show.mocked], facets: nil)
    }
}
#endif
