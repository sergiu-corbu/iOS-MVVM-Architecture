//
//  FeaturedProductsListView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.03.2023.
//

import SwiftUI
import Combine

struct FeaturedProductsListView: View {
    
    @State var show: Show?
    var currentShowPublisher: AnyPublisher<Show, Never>?
    var style: Style = .bordered
    var interactionsEnabled = true
    let onSelectProductAction: ((ProductSelectableDTO) -> Void)?
    
    var body: some View {
        let content = VStack(alignment: .leading, spacing: 8) {
            shopIndicationsView
            GeometryReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    if let featuredProducts = show?.featuredProducts, !featuredProducts.isEmpty {
                        ScrollViewReader { scrollProxy in
                            LazyHStack(spacing: 8) {
                                ForEach(featuredProducts) { product in
                                    featuredProductCellView(product).frame(width: proxy.size.width - 32)
                                        .id(product.id)
                                }
                            }
                            .padding(.horizontal, 16)
                            .onChange(of: show, perform: { newValue in
                                scrollProxy.scrollTo(newValue?.featuredProducts?.first?.id, anchor: .center)
                            })
                        }
                    } else {
                        FeaturedShowProductView(product: nil, interactionsEnabled: false)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .frame(height: 60)
        }
        
        if let currentShowPublisher {
            content.onReceive(currentShowPublisher) { show in
                self.show = show
            }
        } else {
            content
        }
    }
    
    private func featuredProductCellView(_ product: Product) -> some View {
        Button {
            handleProductSelection(product: product)
        } label: {
            FeaturedShowProductView(product: product, foregroundStyle: style.foregroundStyle, interactionsEnabled: interactionsEnabled)
        }
        .buttonStyle(.scaled)
        .disabled(!interactionsEnabled)
    }
    
    private var shopIndicationsView: some View {
        Button {
            handleProductSelection(product: nil)
        } label: {
            let labelView = Text(Strings.ShowDetail.shopMyShow.uppercased())
                .font(kernedFont: .Secondary.p3MediumKerned)
                .foregroundStyle(style.foregroundStyle)
            Group {
                switch style {
                case .bordered:
                    labelView
                        .padding(8)
                        .background(Color.ebony.opacity(0.15), in: RoundedRectangle(cornerRadius: 2))
                case .plain:
                    labelView
                }
            }
            .padding(.leading, 16)
        }
        .buttonStyle(.plain)
    }
    
    private func handleProductSelection(product: Product?) {
        guard let creator = show?.creator, interactionsEnabled,
              let products = show?.featuredProducts else {
            return
        }
        
        var productIndex: Int = 0
        if let product = product, let index = products.firstIndex(of: product) {
            productIndex = index
        }
        onSelectProductAction?(
            ProductSelectableDTO(
                products: products, selectedIndex: productIndex,
                creator: creator, showID: show?.id
            )
        )
    }
}

extension FeaturedProductsListView {
    
    enum Style {
        case bordered
        case plain
        
        var foregroundStyle: Color {
            switch self {
            case .bordered: return .cultured
            case .plain: return .jet
            }
        }
    }
    
    struct FeaturedShowProductView: View {
        
        let product: Product?
        var foregroundStyle: Color = .cultured
        var interactionsEnabled: Bool = true
        
        var body: some View {
            if let product {
                HStack(spacing: 8) {
                    productImageView
                    productInfoView(product)
                    Spacer()
                    if interactionsEnabled {
                        Image(systemName: "chevron.down")
                            .renderingMode(.template)
                            .foregroundColor(.paleSilver)
                            .padding(.trailing, 8)
                    }
                }
                .frame(height: 60)
                .roundedBorder(Color.battleshipGray.opacity(0.55), cornerRadius: 5)
                .contentShape(.interaction, RoundedRectangle(cornerRadius: 5))
            } else {
                Image(.productPlaceholder)
                    .resizedToFit(width: nil, height: 60)
            }
        }
        
        private var productImageView: some View {
            AsyncImageView(imageURL: product?.primaryMediaImageURL, placeholderImage: .fashionIcon)
                .aspectRatio(contentMode: .fit)
                .frame(width: 58, height: 58)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .padding(1)
        }
        
        private func productInfoView(_ product: Product) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(product.brand.name.uppercased())
                    .font(kernedFont: .Secondary.p4BoldKerned)
                    .foregroundColor(.middleGrey)
                    .lineLimit(1)
                Text(product.name.uppercased())
                    .font(kernedFont: .Main.p2MediumKerned)
                    .foregroundStyle(foregroundStyle)
                    .lineLimit(1)
                Text(Strings.ProductsDetail.startingFromPrice(product.minPrice.currencyFormatted(isValueInCents: true)))
                    .font(kernedFont: .Secondary.p1BoldKerned)
                    .foregroundColor(.brightGold)
            }
        }
    }
}

#if DEBUG
struct FeaturedProductsListView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            FeaturedProductsListView(show: .scheduled, interactionsEnabled: false, onSelectProductAction: nil)
            FeaturedProductsListView(show: .scheduled, onSelectProductAction: { _ in })
            FeaturedProductsListView(show: nil, style: .plain, onSelectProductAction: { _ in })
            FeaturedProductsListView(show: .scheduled, style: .plain, onSelectProductAction: { _ in })
        }
        .previewLayout(.sizeThatFits)
        .padding(.vertical)
        .background(Color.paleSilver)
    }
}
#endif
