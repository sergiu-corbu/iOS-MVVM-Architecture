//
//  CheckoutProductsCartListView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.12.2023.
//

import SwiftUI

struct CheckoutProductsCartListView<ProductCellContent: View>: View {
    
    let products: [CheckoutProduct]
    @ViewBuilder let productCellContent: (CheckoutProduct, ScrollViewProxy?) -> ProductCellContent
    
    var body: some View {
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(products, id: \.sku.id) { product in
                            productCellContent(product, scrollProxy)
                                .id(product.sku.id)
                                .frame(width: geometryProxy.size.width * 0.9 - 24)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
        }
        .frame(height: 160)
    }
}

#if DEBUG
#Preview {
    CheckoutProductsCartListView(products: [.prod1, .prod2]) { (product, _) in
        FeaturedProductDetailView(
            productDisplayable: product,
            onDeleteAction: { }
        )
    }
}
#endif
