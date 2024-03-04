//
//  ProductSaleDetailView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.12.2023.
//

import SwiftUI

typealias CustomPrices = (salePrice: Double?, retailPrice: Double?)

struct ProductSaleDetailView: View {
    
    let productDisplayable: any ProductDisplayable
    var customPrices: CustomPrices?
    var configuration: Configuration = .standard
    var actionHandler: Action?

    private var salePrice: Double {
        customPrices?.salePrice ?? productDisplayable.salePrice
    }
    private var retailPrice: Double {
        customPrices?.retailPrice ?? productDisplayable.retailPrice
    }
    
    var body: some View {
        VStack(alignment: configuration.alignment, spacing: 2) {
            Button {
                actionHandler?.onSelectBrand?()
            } label: {
                Text(productDisplayable.brandName.uppercased())
                    .font(kernedFont: .Secondary.p4BoldKerned)
                    .foregroundColor(.middleGrey)
            }
            .buttonStyle(.plain)
            Text(productDisplayable.productName.uppercased())
                .font(kernedFont: .Main.p2MediumKerned)
                .foregroundColor(.jet)
                .lineLimit(configuration.textLineLimit)
                .minimumScaleFactor(0.9)
            if let variant = productDisplayable.productVariant {
                Text(variant)
                    .font(kernedFont: .Secondary.p2RegularKerned)
                    .foregroundColor(.ebony)
                    .lineLimit(1)
            }
            if let infaltedPrice = productDisplayable.inflatedSalePrice(basePrice: salePrice) {
                DiscountedPriceLabelView(price: infaltedPrice, discountedPrice: salePrice)
            } else {
                DiscountedPriceLabelView(price: retailPrice, discountedPrice: productDisplayable.shopifyDiscountValue)
            }
        }
        .padding(.horizontal, actionHandler?.onShare != nil ? 24+8 : 0)
        .overlay(alignment: .trailing, content: {
            if let onShare = actionHandler?.onShare {
                Buttons.TinyShareButton(tint: .middleGrey, onShare: onShare)
                    .frame(width: 24, height: 24)
                    .offset(y: -1)
            }
        })
    }
}

extension ProductSaleDetailView {
    struct Configuration {
        let alignment: HorizontalAlignment
        let textLineLimit: Int
        
        static let standard = Configuration(alignment: .leading, textLineLimit: 2)
        static let centered = Configuration(alignment: .center, textLineLimit: 1)
    }
    struct Action {
        var onSelectBrand: (() -> Void)?
        var onShare: (() -> Void)?
    }
}

#if DEBUG
#Preview {
    ProductSaleDetailView(productDisplayable: Product.sampleProduct)
}
#endif
