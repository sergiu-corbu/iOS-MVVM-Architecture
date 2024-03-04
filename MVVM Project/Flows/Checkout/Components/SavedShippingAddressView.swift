//
//  SavedShippingAddressView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.12.2023.
//

import SwiftUI

struct SavedShippingAddressView: View {
    
    let shippingAddress: ShippingAddress
    
    var body: some View {
        CheckoutSelectableCellView(isSelected: .constant(true)) {
            Text(shippingAddress.checkouShippingAddress)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundStyle(Color.ebony)
                .lineLimit(2)
                .padding(.vertical, 4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview {
    SavedShippingAddressView(shippingAddress: .sampleAddress)
}
#endif
