//
//  FeaturedProductsCollectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.12.2022.
//

import SwiftUI

struct FeaturedProductsCollectionView: View {
    
    let products: [Product]
    var title: String
    
    init(_ products: [Product], title: String = Strings.ContentCreation.featuredProducts) {
        self.products = products
        self.title = title
    }
    
    init(_ products: Set<Product>, title: String = Strings.ContentCreation.featuredProducts) {
        self.products = Array(products)
        self.title = title
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(kernedFont: .Main.p1MediumKerned)
                .foregroundColor(.jet)
                .padding(.leading, 16)
            DividerView()
            CollectionView(
                dataSource: products,
                collectionViewLayout: productsCompositionalLayout,
                cellProvider: { product in
                    FeaturedProductDetailView(productDisplayable: product)
                }
            )
            .frame(height: 160)
            DividerView()
        }
    }
    
    private var productsCompositionalLayout: UICollectionViewLayout {
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85),
                                               heightDimension: .fractionalHeight(1))
        return UICollectionViewLayout.horizontalCompositionalLayout(groupLayoutSize: groupSize, interItemSpacing: 8)
    }
}
    
struct FeaturedProductDetailView: View {
    
    let productDisplayable: any ProductDisplayable
    var imageRadius: CGFloat = 5
    var isInDelete = false
    var onDeleteAction: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 8) {
            AsyncImageView(imageURL: productDisplayable.productThumbnailURL, placeholder: {
                ProductPlaceholderView()
                    .frame(height: 55)
            })
            .aspectRatio(contentMode: .fit)
            .cornerRadius(imageRadius)
            .frame(maxWidth: 120)
            .overlay(alignment: .bottomTrailing) {
                if onDeleteAction != nil {
                    deleteButton
                }
            }
            VStack(alignment: .leading, spacing: 12) {
                ProductSaleDetailView(productDisplayable: productDisplayable)
                if let seller = productDisplayable.seller {
                    Text(Strings.Payment.soldBy + seller.capitalized)
                        .font(kernedFont: .Secondary.p1RegularKerned)
                        .foregroundColor(.ebony)
                }
            }
            Spacer()
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            if isInDelete {
                return
            }
            onDeleteAction?()
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.cultured.opacity(0.9))
                    .frame(width: 24, height: 24)
                if isInDelete {
                    ProgressView()
                        .tint(Color.darkGreen)
                        .scaleEffect(0.7)
                } else {
                    Image(.closeIconHeavy)
                }
            }
        })
        .padding([.trailing, .bottom], 8)
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct FeaturedProductsCollectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        FeaturedProductsCollectionView([.prod5, .prod1, .prod3, .prod4, .prod7])
            .primaryBackground()
        
        VStack(spacing: 24) {
            FeaturedProductDetailView(productDisplayable: Product.prod1)
            .frame(height: 220)
            FeaturedProductDetailView(productDisplayable: Product.prod1, onDeleteAction: {})
            .frame(height: 220)
            FeaturedProductDetailView(productDisplayable: Product.prod1, isInDelete: true, onDeleteAction: {})
            .frame(height: 220)
        }
        .previewDisplayName("Featured Product Detail")
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.beige)
    }
}
#endif
