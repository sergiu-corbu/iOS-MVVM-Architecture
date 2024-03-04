//
//  OrderPreviewCellView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 31.03.2023.
//

import SwiftUI

struct OrderPreviewCellView: View {
    
    let order: Order
    
    var body: some View {
        HStack(spacing: 12) {
            BrandLogoView(imageURL: order.purchasedProduct?.brand.logoPictureURL, diameterSize: 64)
            orderDetailsView
            Spacer()
            Image(.chevronRight)
        }
        .padding(EdgeInsets(top: 18, leading: 8, bottom: 18, trailing: 8))
        .background(Color.beige, in: RoundedRectangle(cornerRadius: 8))
        .roundedBorder(Color.cappuccino, cornerRadius: 8)
    }
    
    private var orderDetailsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Strings.Orders.orderNumber(order.orderNumber))
                .font(kernedFont: .Main.p1RegularKerned)
                .foregroundColor(.jet)
            Text(Strings.Orders.orderPlacedOn(order.orderDate.dateString(formatType: .compactDate)))
                .font(kernedFont: .Secondary.p2RegularKerned)
                .foregroundColor(.ebony)
            HStack(spacing: 8) {
                Text(Strings.Orders.total + ": " + (order.cartEntry?.totalPrice.currencyFormatted(isValueInCents: true) ?? ""))
                    .font(kernedFont: .Secondary.p1RegularKerned)
                Circle()
                    .fill(Color.jet)
                    .frame(width: 3, height: 3)
                Text(Strings.Orders.numberOfOrderedItems(order.products.count))
                    .font(kernedFont: .Secondary.p1RegularKerned)
            }
            .foregroundColor(.jet)
            .padding(.top, 8)
        }
    }
}

#if DEBUG
struct OrderPreviewCellView_Previews: PreviewProvider {
    
    static var previews: some View {
        OrderPreviewCellView(order: .mockOrder)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
