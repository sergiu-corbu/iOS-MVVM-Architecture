//
//  GiftSelectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.06.2023.
//

import SwiftUI

struct GiftSelectionView: View {
    
    let onRequestProduct: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(Strings.ContentCreation.productRequestQuestion)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.middleGrey)
            Buttons.FillBorderedButton(
                title: Strings.Buttons.requestProduct,
                textColor: .ebony,
                leadingAsset: { Image(.giftIcon) },
                action: onRequestProduct
            )
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
struct GiftSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GiftSelectionView(onRequestProduct: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
