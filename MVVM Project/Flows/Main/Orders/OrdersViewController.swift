//
//  OrdersViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 31.03.2023.
//

import Foundation

import SwiftUI
import UIKit

class OrdersViewController: UIHostingController<OrdersView> {

    let viewModel: OrdersViewModel

    init(orderService: OrderServiceProtocol) {
        self.viewModel = OrdersViewModel(orderService: orderService)
        super.init(rootView: OrdersView(viewModel: viewModel))
        
        setupNavigation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNavigation(animated: Bool = true) {
        viewModel.ordersAction = { [weak self] orderActionType in
            switch orderActionType {
            case .back:
                self?.navigationController?.popViewController(animated: animated)
            case .selectOrder(let order):
                self?.showOrderDetailView(order, animated: animated)
            }
        }
    }
    
    private func showOrderDetailView(_ order: Order, animated: Bool) {
        let orderDetailView = OrderDetailView(order: order, onBack: { [weak self] in
            self?.navigationController?.popViewController(animated: animated)
        })
        navigationController?.pushHostingController(orderDetailView, animated: animated)
    }
}
