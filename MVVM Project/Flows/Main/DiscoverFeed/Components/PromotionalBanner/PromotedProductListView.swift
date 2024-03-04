//
//  PromotedProductListView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 12.10.2023.
//

import SwiftUI

struct PromotedProductListView: View {
    
    let title: String
    var spacing: CGFloat = 16
    let viewModel: PromotedProductListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationBar(
                inlineTitle: title,
                onDismiss: viewModel.onBack,
                trailingView: {
                    Buttons.TinyShareButton(size: CGSize(width: 20, height: 20), onShare: {
                        viewModel.handleShareAction(listTitle: title)
                    })
                }
            )
            GeometryReader { geometryProxy in
                ScrollView(.vertical) {
                    PinterestGridView(
                        gridItems: viewModel.products,
                        viewportSize: CGSize(width: geometryProxy.size.width - (2 * spacing), height: geometryProxy.size.height),
                        configuration: .standard,
                        cellContent: { product in
                            Button(action: {
                                viewModel.onSelectProduct(product)
                            }, label: {
                                ProductView(product: product)
                            })
                            .buttonStyle(.scaled)
                        }
                    )
                    .padding([.horizontal, .top], spacing)
                }
            }
        }
        .background(Color.cultured)
    }
}

class PromotedProductListViewModel {
    
    let products: [Product]
    let bannerID: String
    let shareableProvider: ShareableProvider?
    let onSelectProduct: (Product) -> Void
    let onBack: () -> Void
    
    init(bannerID: String, products: [Product], shareableProvider: ShareableProvider?, onSelectProduct: @escaping (Product) -> Void, onBack: @escaping () -> Void) {
        self.bannerID = bannerID
        self.products = products
        self.shareableProvider = shareableProvider
        self.onSelectProduct = onSelectProduct
        self.onBack = onBack
    }
    
    func handleShareAction(listTitle: String) {
        guard let shareableProvider else {
            return
        }
        shareableProvider.generateShareURL(
            ShareableObject(objectID: bannerID, type: .promotedProducts, shareName: listTitle)
        )
    }
}

#if DEBUG
#Preview {
    PromotedProductListView(
        title: "Top Products for Winter Season",
        viewModel: PromotedProductListViewModel(bannerID: UUID().uuidString, products: Array(repeating: Product.sampleProduct, count: 10), shareableProvider: nil, onSelectProduct: {_ in}, onBack: {})
    )
}
#endif
