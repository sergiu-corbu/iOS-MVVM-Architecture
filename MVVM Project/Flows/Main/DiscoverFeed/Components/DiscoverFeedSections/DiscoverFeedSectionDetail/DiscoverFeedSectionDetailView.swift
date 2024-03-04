//
//  DiscoverFeedSectionDetailView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.11.2023.
//

import SwiftUI

struct DiscoverFeedSectionDetailView<Item: StringIdentifiable & Equatable>: View {
    
    @ObservedObject var viewModel: DiscoverFeedSectionDetailViewModel<Item>
    var spacing: CGFloat = 16
    var loadMoreTreshold: LoadMoreTreshold = .constant(200)
    @State private var viewportSize: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationBar(inlineTitle: viewModel.sectionType.title, onDismiss: viewModel.actionHandler.onBack)
            ScrollView {
                contentView
            }
            .overlayLoadingIndicator(loadingSourceType: viewModel.dataStore.loadingSourceType)
            .setViewportLayoutSize($viewportSize)
            .refreshable {
                await Task {
                    try? await viewModel.dataStore.refreshContent()
                }.value
            }
        }
        .background(Color.cultured)
        .errorToast(error: $viewModel.error)
    }
    
    //Views
    @ViewBuilder private var contentView: some View {
        let items = viewModel.dataStore.items
        let availableWidth = viewportSize.width - 2 * spacing
        switch viewModel.sectionType {
        case .shows(_):
            let gridItemsSpacing = CGFloat(12)
            CellDetailView(
                gridLayoutItems: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3),
                items: items,
                onSelectItem: viewModel.actionHandler.onSelectItem,
                content: { item in
                    let cellSize = CGSize(width: (availableWidth - gridItemsSpacing) / 3, height: 280)
                    if let show = item as? Show {
                        DiscoverShowCard(show: show, cardSize: cellSize)
                    }
                }
            )
        case .products(_):
            PinterestGridView(
                gridItems: items,
                viewportSize: CGSize(width: availableWidth, height: 700),
                configuration: .standard,
                cellContent: { productWrapper in
                    if let product = (productWrapper as? ProductWrapper)?.product {
                        Button(action: {
                            viewModel.actionHandler.onSelectItem(product)
                        }, label: {
                            ProductView(product: product)
                        })
                        .buttonStyle(.plain)
                    }
                },
                onReachedLastPage: viewModel.loadMoreContent(lastItem:)
            )
            .padding(EdgeInsets(top: 28, leading: 16, bottom: 28, trailing: 16))
        case .creators:
            CellDetailView(
                gridLayoutItems: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
                items: items,
                onSelectItem: viewModel.actionHandler.onSelectItem,
                content: { item in
                    if let creator = item as? Creator {
                        CreatorCardDetailView(creator: creator, followViewModel: viewModel.followViewModel(from: creator))
                    }
                }, onContentOffsetChanged: handleContentOffsetChanged
            )
        case .brands:
            CellDetailView(
                gridLayoutItems: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2),
                items: items,
                onSelectItem: viewModel.actionHandler.onSelectItem,
                content: { item in
                    if let brand = (item as? BrandWrapper)?.value {
                        BrandVView(brand: brand)
                    }
                }, onContentOffsetChanged: handleContentOffsetChanged
            )
        }
    }
    
    //Load More
    private func handleContentOffsetChanged(_ contentOffset: CGPoint, contentSize: CGSize) {
        guard let lastItem = viewModel.dataStore.items.last else {
            return
        }

        let maxVisibileY = contentSize.height - viewportSize.height - contentOffset.y
        let tresholdY: CGFloat
        switch loadMoreTreshold {
        case .fraction(let fraction):
            tresholdY = viewportSize.height * fraction
        case .constant(let constant):
            tresholdY = constant
        }

        if maxVisibileY <= tresholdY {
            viewModel.loadMoreContent(lastItem: lastItem)
        }
    }
    
    struct CellDetailView<Content: View>: View {
        
        let gridLayoutItems: [GridItem]
        let items: [Item]
        let onSelectItem: (Item) -> Void
        @ViewBuilder let content: (Item) -> Content
        var onContentOffsetChanged: ((_ contentOffset: CGPoint, _ contentSieze: CGSize) -> Void)?
        
        @State private var contentSize: CGSize?
        
        var body: some View {
            LazyVGrid(columns: gridLayoutItems, spacing: gridLayoutItems.first?.spacing) {
                ForEach(items) { item in
                    Button {
                        onSelectItem(item)
                    } label: {
                        content(item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(EdgeInsets(top: 28, leading: 16, bottom: 28, trailing: 16))
            .animation(.smooth, value: items.count)
            .readContentSize(onContentSizeChanged: { size in
                self.contentSize = size
            })
            .scrollContentOffset(coordinateSpace: .global) {
                if let contentSize {
                    onContentOffsetChanged?($0, contentSize)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    DiscoverFeedSectionDetailView<BrandWrapper>(viewModel: .preview(sectionType: .brands))
}
#endif
