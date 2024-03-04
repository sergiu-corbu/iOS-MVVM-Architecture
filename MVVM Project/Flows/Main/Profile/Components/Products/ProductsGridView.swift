//
//  ProductsGridView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.06.2023.
//

import SwiftUI

extension ProfileComponents {
    
    /// - Note: For accurate layouts, a `parentContentSize` must be injected somewhere in the view hierarchy.
    struct ProductsGridView: View {
        
        @ObservedObject var viewModel: ProductsGridViewModel
        var spacing: CGFloat = 16
        var onProductSelected: ((Product) -> Void)?
        
        //Internal
        @Environment(\.parentContentSize) private var contentSize: CGSize
        private var viewportSize: CGSize {
            return CGSize(width: contentSize.width - 2 * spacing, height: contentSize.height)
        }
        
        var body: some View {
            if viewModel.showPlaceholder {
                ProfileComponents.SectionPlaceholderView(image: .fashionIcon, text: viewModel.placeholderMessage)
            } else {
               contentView
            }
        }
        
        private var contentView: some View {
            PinterestGridView(gridItems: viewModel.products, viewportSize: viewportSize, cellContent: { productWrapper in
                let product = productWrapper.product
                Button {
                    onProductSelected?(product)
                } label: {
                    ProductView(product: product, viewportSize: viewportSize)
                }.buttonStyle(.scaled)
            }, onReachedLastPage: {
                viewModel.loadMoreProductsIfNeeded($0)
            })
            .padding(spacing)
            .overlayLoadingIndicator(loadingSourceType: viewModel.loadingType)
        }
    }
}

#if DEBUG
#Preview {
    GeometryReader {
        ProfileComponents.ProductsGridView(viewModel: .previewVM)
            .parentContentSize($0.size)
    }
}
#endif
