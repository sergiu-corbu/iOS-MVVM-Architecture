//
//  PaymentMethodView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.08.2023.
//

import Foundation
import SwiftUI

struct PaymentMethodView: View {
    var body: some View {
        HStack(spacing: 12) {
            Text(" Pay")
                .font(kernedFont: .Secondary.p4MediumKerned)
                .foregroundColor(.jet)
                .padding(6)
                .roundedBorder(Color.jet, cornerRadius: 5)
            Text(Strings.Orders.applePay.uppercased())
                .font(kernedFont: .Secondary.p2MediumKerned())
                .foregroundColor(.ebony)
        }
    }
}

struct PaymentMethodView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentMethodView()
    }
}
