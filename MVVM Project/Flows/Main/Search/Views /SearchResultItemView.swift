//
//  SearchResultItem.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.07.2023.
//

import SwiftUI

struct SearchResultItemView: View {
    
    let config: Config
    
    //MARK: Computed properties
    private var thumbnailURL: URL? {
        switch config {
        case .creator(let creator): return creator.profilePictureUrl
        case .product(let product): return product.pictureUrl
        case .show(let show): return show.thumbnailUrl
        case .brand(let brand): return brand.logoPictureUrl
        }
    }
    
    private var mainTitle: String? {
        switch config {
        case .creator(let creator): return creator.fullName
        case .product(let product): return product.name
        case .show(let show): return show.title
        case .brand(let brand): return brand.name
        }
    }

    private var subtitle: String? {
        switch config {
        case .creator(let creator): return creator.formattedName
        case .show(let show): return show.publishingDate.dateString(formatType: .compactDateAndTime)
        case .product, .brand(_): return nil
        }
    }
    
    //MARK: Views
    
    var body: some View {
        HStack(spacing: 12) {
            thumbnailView
            contentStack
        }
        .padding(EdgeInsets(top: 8, leading: 12, bottom: 12, trailing: 12))
        .background {
            RoundedRectangle(cornerRadius: 5).strokeBorder(Color.lightGrey, lineWidth: 1)
                .padding(EdgeInsets(top: -1, leading: -1, bottom: 0, trailing: -1))
                .clipped()
        }
        .contentShape(Rectangle())
    }
    
    private var contentStack: some View {
        VStack(spacing: 2) {
            showStatus
            brandName
            titleLabel
            subtitleLabel
            priceView
        }
    }

    private var thumbnailView: some View {
        AsyncImageView(imageURL: thumbnailURL, placeholderImage: .mediaContentIcon)
            .downsampled(targetSize: CGSize(width: 112, height: 112))
            .clearBackground()
            .scaledToFit()
            .frame(width: 56, height: 56)
            .overlay {
                if config.isShow {
                    ZStack {
                        Color.black.opacity(0.3)
                        Image(.playIcSmall)
                            .renderingMode(.template)
                            .foregroundColor(.white)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: config.isBrand ? 56 / 2 : 5))
    }
    
    @ViewBuilder private var titleLabel: some View {
        if let mainTitle = mainTitle {
            Text(mainTitle)
                .font(.Main.p1Medium)
                .foregroundColor(.brownJet)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder private var subtitleLabel: some View {
        if let subtitle = subtitle {
            Text(subtitle)
                .font(kernedFont: .Secondary.p2RegularKerned)
                .foregroundColor(.middleGrey)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    //MARK: Show Related Views
    
    @ViewBuilder private var showStatus: some View {
        if case .show(let show) = config {
            Text(show.status.rawValue.capitalized)
                .font(kernedFont: .Secondary.p2MediumKerned())
                .foregroundColor(show.status == .scheduled ? .orangish : .middleGrey)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    //MARK: Product Related Views
    
    @ViewBuilder private var priceView: some View {
        if case .product(let product) = config {
            Text(product.minPrice.currencyFormatted(isValueInCents: true) ?? "N/A")
                .font(kernedFont: .Secondary.p1BoldKerned)
                .foregroundColor(.brightGold)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder private var brandName: some View {
        if case .product(let product) = config {
            Text(product.brandName)
                .font(kernedFont: .Secondary.p3MediumKerned)
                .foregroundColor(.battleshipGray)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

extension SearchResultItemView {
    
    enum Config: Equatable, Identifiable {
        var id: String {
            switch self {
            case .show(let show): return show.id
            case .product(let product): return product.id
            case .brand(let brand): return brand.id
            case .creator(let creator): return creator.id
            }
        }

        case show(SearchResult.Show)
        case product(SearchResult.Product)
        case creator(SearchResult.Creator)
        case brand(SearchResult.Brand)
        
        var reuseIdentifier: String {
            switch self {
            case .show: return "\(type(of: self))_Show"
            case .creator: return "\(type(of: self))_Creator"
            case .product: return "\(type(of: self))_Product"
            case .brand: return "\(type(of: self))_Brand"
            }
        }
        
        var isBrand: Bool {
            if case .brand = self { return true }; return false
        }
        
        var isShow: Bool {
            if case .show = self { return true }; return false
        }
    }
}

#if DEBUG
struct SearchResultItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SearchResultItemView(config: .show(SearchResult.Show.mocked))
            SearchResultItemView(config: .product(SearchResult.Product.mocked))
            SearchResultItemView(config: .creator(SearchResult.Creator.mocked))
            SearchResultItemView(config: .brand(SearchResult.Brand.mocked))
        }
    }
}
#endif
