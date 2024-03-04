//
//  PaginatedDataStore.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 20.07.2023.
//

import Foundation

protocol StringIdentifiable: Identifiable where ID == String {
    
}

final class PaginatedDataStore<T: StringIdentifiable>: ObservableObject {
    
    typealias LoadPageCall = (T?) async throws -> [T]
    
    let pageSize: Int

    //MARK: Properties
    @Published private(set) var loadingSourceType: LoadingSourceType?
    @Published private(set) var items = [T]()
    private var lastItem: T?
    private(set) var didLoadFirstPage = false
    private var shouldLoadMore = false
    private(set) var currentPage: Int = 1
    private var _loadPage: LoadPageCall?

    init(pageSize: Int = 10) {
        self.pageSize = pageSize
    }
    
    func onLoadPage(_ callback: @escaping LoadPageCall) {
        self._loadPage = callback
    }
    
    private func loadPage() async throws -> [T] {
        guard let loadPage = _loadPage else {
            return []
        }
        let result = try await loadPage(lastItem)
        processResult(result)
        return result
    }
    
    @MainActor
    func loadInitialContent() async throws {
        loadingSourceType = .new
        resetState()
        defer {
            loadingSourceType = nil
        }
        items = try await loadPage()
    }
    
    @MainActor
    func refreshContent(delay: TimeInterval? = nil) async throws {
        resetState()
        let items_ = try await loadPage()
        if let delay {
            DispatchQueue.main.asyncAfter(seconds: delay) { [weak self] in
                self?.items = items_
            }
        } else {
            items = items_
        }
    }
    
    @MainActor
    func loadMoreIfNeeded(_ lastItem: T?) async throws {
        guard shouldLoadMore(lastItem: lastItem), loadingSourceType == nil else {
            return
        }
        defer {
            loadingSourceType = nil
        }
        loadingSourceType = .paged
        items.append(contentsOf: try await loadPage())
    }
    
    func update(_ element: T) {
        guard let index = find(id: element.id) else {
            return
        }
        items[index] = element
    }
    
    func insert(element: T?, at index: Int = 0) {
        guard let element, find(id: element.id) == nil else {
            return
        }
        items.insert(element, at: index)
    }
    
    func remove(id: String) {
        guard let index = find(id: id) else {
            return
        }
        items.remove(at: index)
    }
    
    func find(id: String) -> Int? {
        return items.firstIndex(where: { $0.id == id })
    }
    
    func findValue(id: String) -> T? {
        guard let index = find(id: id) else {
            return nil
        }
        return items[safe: index]
    }
    
    private func processResult(_ result: [T]) {
        lastItem = result.last
        shouldLoadMore = result.count == pageSize
        didLoadFirstPage = true
        if shouldLoadMore {
            currentPage += 1
        }
    }
    
    private func shouldLoadMore(lastItem: T?) -> Bool {
        if let itemID = lastItem?.id {
            return shouldLoadMore && itemID == self.lastItem?.id
        }
        return shouldLoadMore
    }
    
    private func resetState() {
        lastItem = nil
        didLoadFirstPage = false
        shouldLoadMore = false
        currentPage = 1
    }
}
