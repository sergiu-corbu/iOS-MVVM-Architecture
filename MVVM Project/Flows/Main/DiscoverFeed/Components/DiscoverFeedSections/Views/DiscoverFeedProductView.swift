//
//  DiscoverFeedProductView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 20.11.2023.
//

import SwiftUI

struct DiscoverFeedProductView: View {
    
    let product: Product
        
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImageView(imageURL: product.primaryMediaImageURL, placeholderImage: .fashionIcon)
                .resizedToFitProductImageView(aspectRatio: product.imageAspectRatio, cornerRadius: 8)
            productDetails
        }
        .background(Color.beige)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .topLeading) {
            if let discountPercentage = product.discountPercentage, discountPercentage > .zero {
                ProductDiscountLabelView(discountValue: discountPercentage)
                    .padding(EdgeInsets(top: 6, leading: 4, bottom: 0, trailing: 0))
            }
        }
    }
    
    private var productDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.brandName.uppercased())
                .font(kernedFont: .Secondary.p4BoldKerned)
                .foregroundStyle(Color.middleGrey)
                .lineLimit(1)
            Text(product.name.uppercased())
                .font(kernedFont: .Main.p2MediumKerned)
                .foregroundStyle(Color.jet)
                .lineLimit(2)
            if let inflatedPrice = product.inflatedSalePrice(basePrice: product.salePrice) {
                DiscountedPriceLabelView(price: inflatedPrice, discountedPrice: product.salePrice, alignment: .bottom)
            } else {
                DiscountedPriceLabelView(price: product.retailPrice, discountedPrice: product.shopifyDiscountValue, alignment: .bottom)
            }
        }
        .padding(4)
    }
}

struct DiscoverFeedProductPlaceholderView: View {
    
    var body: some View {
        Color.beige.clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(height: .random(in: 140..<220))
            .overlay(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    let widths = [40, 90, 68]
                    ForEach(widths.shuffled()) { width in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.cappuccino)
                            .frame(width: CGFloat(width), height: 12)
                    }
                }
                .padding(4)
            }
    }
}

struct DiscoverProductsPlaceholderView: View {
    
    let viewportSize: CGSize
    
    var body: some View {
        PinterestGridView(gridItems: [1,2,3], viewportSize: viewportSize, configuration: .triple, cellContent: { _ in
            DiscoverFeedProductPlaceholderView()
        })
    }
}

struct ProductDiscountLabelView: View {
    
    let discountValue: Double
    
    var body: some View {
        Text("-\(Int(discountValue))%")
            .font(kernedFont: .Secondary.p4BoldKerned)
            .foregroundStyle(Color.firebrick)
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.cultured)
            )
    }
}

#if DEBUG
#Preview {
    VStack {
        HStack {
            DiscoverFeedProductView(product: .sampleProduct)
                .frame(width: 106)
            ProductDiscountLabelView(discountValue: 30)
            ProductDiscountLabelView(discountValue: 7)
        }
        DiscoverFeedProductView(product: .prod4)
            .frame(width: 106)
        HStack {
            ForEach(0..<3, id: \.self) { _ in
                DiscoverFeedProductPlaceholderView()
                    .frame(width: 106)
            }
        }
        
       
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.cappuccino)
}
#endif
