//
//  ProductsSelectionGridView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.12.2022.
//

import SwiftUI

struct ProductsSelectionGridView<CellContent: View>: View {
    
    let products: [Product]
    let brands: [Brand]
    var showBrandsHeader: Bool = true
    let contentSize: CGSize
    @ViewBuilder let productCellContent: (Product) -> CellContent
    var onReachedLastPage: ((_ lastItemID: String) -> Void)?
    
    private let horizontalPadding: CGFloat = 16
    
    var body: some View {
        if products.isEmpty {
            EmptyProductsSearchView()
                .frame(maxWidth: .infinity)
                .padding(.top, 82)
        } else {
            LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                Section {
                    let viewportSize = CGSize(width: contentSize.width - (2 * horizontalPadding), height: contentSize.height)
                    PinterestGridView(gridItems: products, viewportSize: viewportSize, cellContent: { product in
                        productCellContent(product)
                    }, onReachedLastPage: { lastProduct in
                        onReachedLastPage?(lastProduct.id)
                    })
                } header: {
                    if showBrandsHeader {
                        containingBrandsView
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
    
    private var containingBrandsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.ContentCreation.numberOfProductsInSearch(products.count))
                .monospacedDigit()
                .font(kernedFont: .Secondary.p2RegularKerned)
                .foregroundColor(.jet)
                .animation(nil)
                .padding(.leading, horizontalPadding)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(brands, id: \.id) { brand in
                        Text(brand.name)
                            .font(kernedFont: .Secondary.p3BoldKerned)
                            .foregroundColor(.jet)
                            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                            .background(Color.white.cornerRadius(5))
                            .transition(.move(edge: .leading))
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
        .padding(.bottom, 8)
        .padding(.horizontal, -horizontalPadding)
        .fadedTransparentGradient()
    }
}

#if DEBUG
#Preview {
    struct ProductsContainerViewPreview: View {
        
        @State var products = Product.all
        @State var selectedProducts: Set<Product> = []
        @State var contentSize: CGSize = .zero
        
        var body: some View {
            ScrollView {
                ProductsSelectionGridView(products: products, brands: Brand.allBrands, contentSize: contentSize, productCellContent: { product in
                    ProductView(product: product)
                })
            }
            .primaryBackground()
            .setViewportLayoutSize($contentSize)
        }
    }
    
    return ProductsContainerViewPreview()
}
#endif
