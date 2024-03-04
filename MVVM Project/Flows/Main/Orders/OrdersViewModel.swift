//
//  OrdersViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 31.03.2023.
//

import Foundation

class OrdersViewModel: ObservableObject {
    
    //MARK: Properties
    @Published var orders: [Order] = []
    @Published var isLoading = true
    @Published var error: Error?
    
    var showLoadMoreIndicator: Bool {
        return isLoading && !orders.isEmpty
    }
    var showNoOrders: Bool {
        return !isLoading && orders.isEmpty
    }
    
    //MARK: Actions
    var ordersAction: (Action) -> Void = { _ in }
    
    private var loadOrdersTask: Task<Void, Never>?
    
    //MARK: Data source
    private var dataSourceConfiguration: any DataSourceConfiguration
    private let orderService: OrderServiceProtocol
    
    //MARK: Services
    private let analyticsService: AnalyticsServiceProtocol
    
    init(orderService: OrderServiceProtocol, analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
         dataSourceConfiguration: any DataSourceConfiguration = PaginatedDataSourceConfiguration(pageSize: 10)) {
        
        self.orderService = orderService
        self.dataSourceConfiguration = dataSourceConfiguration
        self.analyticsService = analyticsService
        
        analyticsService.trackScreenEvent(.orders, properties: nil)
        loadOrdersTask = Task(priority: .userInitiated) { @MainActor in
            await loadOrders(sourceType: .new)
        }
    }
    
    deinit {
        loadOrdersTask?.cancel()
    }
    
    func loadMoreOrdersIfNeeded(_ lastShowID: String) {
        guard dataSourceConfiguration.shouldLoadMore(itemID: lastShowID) else {
            return
        }
        
        Task(priority: .userInitiated) { @MainActor in
            isLoading = true
            await loadOrders(sourceType: .paged)
        }
    }
    
    @MainActor
    func loadOrders(sourceType: DataSourceType) async {
        do {
            if sourceType == .new {
                dataSourceConfiguration.reset()
            }
            
            let fetchedOrders = try await orderService.getOrders(
                pageSize: dataSourceConfiguration.pageSize,
                lastOrderID: dataSourceConfiguration.lastItemID,
                lastOrderCreatedDate: dataSourceConfiguration.additionalLastItemProperty as? Date
            )
            dataSourceConfiguration.processResult(results: fetchedOrders, additionalValue: fetchedOrders.last?.orderDate)
            
            switch sourceType {
            case .paged:
                self.orders.append(contentsOf: fetchedOrders)
            case .new:
                self.orders = fetchedOrders
            }
            
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func reloadOrders() async {
        if isLoading {
            return
        }
        
        await loadOrders(sourceType: .new)
    }
}

extension OrdersViewModel {
    
    enum Action {
        case back
        case selectOrder(Order)
    }
}
