//
//  OrdersView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 10.11.2022.
//

import SwiftUI

struct OrdersView: View {
    
    @ObservedObject var viewModel: OrdersViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            NavigationBar(inlineTitle: Strings.NavigationTitles.orders, onDismiss: {
                viewModel.ordersAction(.back)
            })
            
            if viewModel.showNoOrders {
                noOrdersView
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    ordersListView
                        .transition(.opacity)
                        .padding(.vertical, 8)
                }
                .overlayLoadingIndicator(viewModel.isLoading)
                .overlayLoadingIndicator(viewModel.showLoadMoreIndicator, alignment: .bottom)
                .refreshable {
                    await viewModel.reloadOrders()
                }
            }
        }
        .primaryBackground()
        .errorToast(error: $viewModel.error)
        .animation(.easeInOut, value: viewModel.orders)
    }
}

//MARK: Components
private extension OrdersView {
    
    var ordersListView: some View {
        LazyVStack(spacing: 12) {
            PaginatedFeedView(items: viewModel.orders) { order in
                Button {
                    viewModel.ordersAction(.selectOrder(order))
                } label: {
                    OrderPreviewCellView(order: order)
                }
                .buttonStyle(.scaled)
            } onLoadMore: { lastId in
                viewModel.loadMoreOrdersIfNeeded(lastId)
            }
        }
        .padding(.horizontal, 16)
    }
}

//MARK: No orders
private extension OrdersView {
    
    var noOrdersView: some View {
        VStack(spacing: 16) {
            Image(.shoppingBagIcon)
                .renderingMode(.template)
                .resizedToFit(size: CGSize(width: 42, height: 42))
                .foregroundColor(.ebony.opacity(0.55))
            Text(Strings.Orders.emptyOrders)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 16)
        .transition(.opacity.animation(.easeInOut))
    }
}

#if DEBUG
struct OrdersView_Previews: PreviewProvider {
    
    static var previews: some View {
        OrdersViewPreview()
        EmptyOrdersViewPreview()
            .previewDisplayName("Empty orders")
    }
    
    private struct OrdersViewPreview: View {
        
        @StateObject var viewModel = OrdersViewModel(orderService: MockOrderService(), analyticsService: MockAnalyticsService())
        
        var body: some View {
            OrdersView(viewModel: viewModel)
        }
    }
    
    private struct EmptyOrdersViewPreview: View {
        
        @StateObject var viewModel = OrdersViewModel(orderService: MockOrderService())
        
        var body: some View {
            OrdersView(viewModel: viewModel)
                .task {
                    await Task.sleep(seconds: 2)
                    viewModel.orders = []
                }
        }
    }
}
#endif
