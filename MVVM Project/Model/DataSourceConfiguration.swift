//
//  DataSourceConfiguration.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.12.2022.
//

import Foundation

enum DataSourceType: Int {
    case new
    case paged
}

//MARK: - DataSource
protocol DataSourceConfiguration {
    
    var pageSize: Int { get }
    var lastItemID: String? { get set }
    var additionalLastItemProperty: Any? { get set }
    var shouldLoadMore: Bool { get set }
    var didLoadFirstPage: Bool { get set }
    
    mutating func reset()
}

protocol DataSourceTypeConfiguration: DataSourceConfiguration {
    
    var type: DataSourceType { get set }
    
    mutating func reset(type: DataSourceType, lastItemID: String?)
}

//MARK: - Common extensions
extension DataSourceConfiguration {
    
    mutating func reset() {
        lastItemID = nil
        additionalLastItemProperty = nil
        didLoadFirstPage = false
        shouldLoadMore = false
    }
    
    mutating func processResult<Item>(results: Array<Item>, additionalValue: Any? = nil) where Item: Identifiable {
        lastItemID = results.last?.id as? String
        additionalLastItemProperty = additionalValue
        shouldLoadMore = results.count == pageSize
        didLoadFirstPage = true
    }
    
    func shouldLoadMore(itemID: String?) -> Bool {
        if let itemID {
            return shouldLoadMore && itemID == lastItemID
        }
        return shouldLoadMore
    }
}

//MARK: - Concrete implementation
struct PaginatedDataSourceConfiguration: DataSourceConfiguration {
    
    let pageSize: Int
    var lastItemID: String? = nil
    var additionalLastItemProperty: Any? = nil
    var didLoadFirstPage = false
    var shouldLoadMore = false
    
    init(pageSize: Int) {
        self.pageSize = pageSize
    }
}

struct DataSourceTypeConfigurationDecorator: DataSourceTypeConfiguration {
    
    private var decoratee: DataSourceConfiguration
    
    init(decoratee: DataSourceConfiguration) {
        self.decoratee = decoratee
        self.pageSize = decoratee.pageSize
    }
    
    var type: DataSourceType = .paged
    let pageSize: Int
    
    var lastItemID: String? {
        get { return decoratee.lastItemID }
        set { decoratee.lastItemID = newValue }
    }
    var additionalLastItemProperty: Any? {
        get { return decoratee.additionalLastItemProperty }
        set { decoratee.additionalLastItemProperty = newValue }
    }
    var didLoadFirstPage: Bool {
        get { return decoratee.didLoadFirstPage }
        set { decoratee.didLoadFirstPage = newValue }
    }
    var shouldLoadMore: Bool {
        get { return decoratee.shouldLoadMore }
        set { decoratee.shouldLoadMore = newValue }
    }
    
    mutating func reset(type: DataSourceType, lastItemID: String?) {
        decoratee.reset()
        self.type = type
        self.shouldLoadMore = type == .paged
        self.lastItemID = lastItemID
    }
}
