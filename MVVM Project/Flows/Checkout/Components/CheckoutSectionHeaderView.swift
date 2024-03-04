//
//  CheckoutSectionHeaderView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 04.01.2024.
//

import SwiftUI

struct CheckoutSectionHeaderView: View {
     
    let title: String
    var subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4, content: {
            Text(title)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundStyle(Color.jet)
                .lineLimit(1)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundStyle(Color.middleGrey)
            }
        })
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension CheckoutSectionHeaderView {
    
    init(checkoutSection: CheckoutSectionType, isEditable: Bool = false) {
        self.title = isEditable ? checkoutSection.editableTitle : checkoutSection.title
        self.subtitle = checkoutSection.subtitle
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 24) {
        CheckoutSectionHeaderView(checkoutSection: .billingAddress, isEditable: true)
        CheckoutSectionHeaderView(checkoutSection: .paymentDetails, isEditable: true)
        CheckoutSectionHeaderView(checkoutSection: .billingAddress)
        CheckoutSectionHeaderView(checkoutSection: .paymentDetails)
    }
}
#endif
