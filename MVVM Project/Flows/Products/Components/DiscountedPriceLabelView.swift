//
//  DiscountedPriceLabelView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 14.07.2023.
//

import SwiftUI

enum DiscountLabelAlignment {
    case inlineTrailing
    case bottom
    
    var layoutSpacing: CGFloat {
        switch self {
        case .inlineTrailing: return 8
        case .bottom: return 4
        }
    }
    
    @available(iOS 16.0, *)
    func createLayout(spacing: CGFloat? = nil) -> AnyLayout {
        switch self {
        case .inlineTrailing: return HStackLayout(spacing: spacing ?? layoutSpacing).eraseToAnyLayout()
        case .bottom: return VStackLayout(alignment: .leading, spacing: spacing ?? layoutSpacing).eraseToAnyLayout()
        }
    }
}

struct DiscountedPriceLabelView: View {
    
    let price: Double
    let discountedPrice: Double?
    var alignment: DiscountLabelAlignment = .inlineTrailing
    
    var body: some View {
        if let discountedPrice {
            discountedPriceView(discountedPrice)
        } else {
            priceView(value: price, foregroundColor: .brightGold)
        }
    }
    
    private func discountedPriceView(_ discountPrice: Double) -> some View {
        let layout = alignment.createLayout()
        return layout {
            standardPriceSlashedView
            priceView(value: discountPrice, foregroundColor: .brightGold)
        }
    }
    
    var standardPriceSlashedView: some View {
        priceView(value: price, foregroundColor: .paleSilver)
            .padding(.horizontal, 2)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.ebony)
                    .frame(height: 2)
            )
    }
    
    private func priceView(value: Double, foregroundColor: Color) -> some View {
        Text(value.currencyFormatted(isValueInCents: true) ?? "N/A")
            .font(kernedFont: .Secondary.p1BoldKerned)
            .foregroundColor(foregroundColor)
            .lineLimit(1)
    }
}

#if DEBUG
struct DiscountedPriceLabelView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            DiscountedPriceLabelView(price: 19000, discountedPrice: 17800)
            DiscountedPriceLabelView(price: 19000, discountedPrice: 17800, alignment: .bottom)
            DiscountedPriceLabelView(price: 19000, discountedPrice: nil)
        }
        .previewLayout(.sizeThatFits)
        
    }
}
#endif
