//
//  OrderDetailView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.04.2023.
//

import SwiftUI

struct OrderDetailView: View {
    
    let order: Order
    let onBack: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationBar(inlineTitle: Strings.Orders.orderNumber(order.orderNumber), onDismiss: onBack)
            ScrollView {
                orderDetailView
            }
        }
        .primaryBackground()
    }
    
    private var orderDetailView: some View {
        VStack(alignment: .leading, spacing: 28) {
            ForEach(SectionType.allCases, id: \.rawValue) { sectionType in
                orderSectionContainerView(
                    sectionType: sectionType,
                    sectionView: sectionView(sectionType: sectionType)
                )
            }
            orderSummaryView
        }
    }
    
    private enum SectionType: Int, CaseIterable {
        case items
        case delivery
        case payment
        
        var title: String {
            switch self {
            case .items: return Strings.Orders.items
            case .delivery: return Strings.Orders.delivery
            case .payment: return Strings.Orders.paymentMethod
            }
        }
        
        var icon: ImageResource {
            switch self {
            case .items: return .shoppingBagIcon
            case .delivery: return .houseIcon
            case .payment: return .walletIcon
            }
        }
    }
}

//MARK: Order section view
extension OrderDetailView {
    
    private func orderSectionContainerView(sectionType: SectionType, sectionView: some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(sectionType.icon)
                    .renderingMode(.template)
                    .resizedToFit(size: CGSize(width: 18, height: 18))
                    .foregroundColor(.paleSilver)
                Text(sectionType.title)
                    .font(kernedFont: .Main.p1MediumKerned)
                    .foregroundColor(.jet)
            }
            .padding(.leading, 16)
            sectionView
                .padding(.horizontal, sectionType != .items ? 16 : 0)
            DividerView()
                .padding(.top, 4)
        }
    }
    
    @ViewBuilder
    private func sectionView(sectionType: SectionType) -> some View {
        switch sectionType {
        case .items:
            GeometryReader { geometryProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(order.products, id: \.id) { product in
                            FeaturedProductDetailView(productDisplayable: product, imageRadius: 8)
                                .frame(
                                    width: (geometryProxy.size.width - 32) * 0.9,
                                    height: 160
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .frame(height: 160)
        case .delivery:
            VStack(alignment: .leading, spacing: 0) {
                Text(order.shippingAddress.fullName ?? "N/A")
                    .font(kernedFont: .Secondary.p1RegularKerned)
                Text(order.shippingAddress.checkouShippingAddress.removeNewLines())
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .lineLimit(2)
            }
            .foregroundColor(.ebony)
        case .payment:
            PaymentMethodView()
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cappuccino, in: RoundedRectangle(cornerRadius: 4))
        }
    }
    
}

//MARK: Order summary view
private extension OrderDetailView {
    
    var orderSummaryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Strings.Orders.orderSummary.uppercased())
                .font(kernedFont: .Main.p1MediumKerned)
                .foregroundColor(.jet)
            VStack(alignment: .leading, spacing: 0) {
                priceSectionView(title: Strings.Orders.totalPrice, price: order.cartEntry?.totalPrice, useItalicStyle: true)
                    .padding(.bottom, 4)
                priceSectionView(title: Strings.Orders.items + ":", price: order.cartEntry?.itemsPrice)
                priceSectionView(title: Strings.Orders.shipping + ":", price: order.cartEntry?.shippingPrice)
                priceSectionView(title: Strings.Payment.tax + ":", price: order.cartEntry?.taxValue)
            }
        }
        .padding(.horizontal, 16)
    }
    
    func priceSectionView(title: String, price: Double?, useItalicStyle: Bool = false) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .textStyle(CurrencyTextStyle(useItalicStyle: useItalicStyle))
            Spacer()
            Text(price?.currencyFormatted(isValueInCents: true) ?? "N/A")
                .textStyle(CurrencyTextStyle(useItalicStyle: useItalicStyle))
        }
    }
}

struct CurrencyTextStyle: TextStyle {
    
    var useItalicStyle: Bool = false
    
    func makeBody(text: Text) -> some View {
        return text
            .font(useItalicStyle ? .Main.italic(20) : .Secondary.p2Regular)
            .kerning(useItalicStyle ? 0 : 0.2)
            .foregroundColor(useItalicStyle ? .jet : .middleGrey)
    }
}

#if DEBUG
struct OrderDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        OrderDetailView(order: .mockOrder, onBack: {})
    }
}
#endif
