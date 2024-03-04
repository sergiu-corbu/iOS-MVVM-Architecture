//
//  HotDealsFeedView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.11.2023.
//

import SwiftUI

struct HotDealsFeedView: View {
    
    @ObservedObject var viewModel: HotDealsFeedViewModel
    let viewportSize: CGSize
    var spacing: CGFloat
    
    let onSelectProduct: (Product) -> Void
    
    var body: some View {
        let showPlaceholder = viewModel.products.isEmpty == true
        let viewportSize = CGSize(width: viewportSize.width - 2 * spacing, height: UIScreen.main.bounds.height)
        return DiscoverFeedContainerSectionView(
            title: DiscoverProductsFeedType.hotDeals.title, content: {
                if showPlaceholder {
                    DiscoverProductsPlaceholderView(viewportSize: viewportSize)
                        .padding(.horizontal, spacing)
                } else {
                    PinterestGridView(gridItems: viewModel.products, viewportSize: viewportSize,
                        configuration: .triple, cellContent: { product in
                            Button {
                                onSelectProduct(product)
                            } label: {
                                DiscoverFeedProductView(product: product)
                            }.buttonStyle(.plain)
                        }, onReachedLastPage: { lastProduct in
                            Task(priority: .userInitiated) {
                                await viewModel.handleLoadMore(for: lastProduct)
                            }
                        }
                    ).padding(.horizontal, spacing)
                }
            }
        )
        .overlayLoadingIndicator(viewModel.isLoadingMore, scale: 1, alignment: .bottom, shouldDisableInteraction: false)
    }
}

#if DEBUG
#Preview {
    EmptyView()
//    HotDealsFeedView()
}
#endif
