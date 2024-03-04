//
//  BrandsTagContainerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.11.2022.
//

import SwiftUI

enum BrandTagType {
    case suggestion
    case selection
    
    var tagImage: Image {
        switch self {
        case .suggestion: return Image(.plusIcon)
        case .selection: return Image(.closeIcon)
        }
    }
    
    var background: Color {
        switch self {
        case .suggestion: return .beige
        case .selection: return .cultured
        }
    }
}

struct BrandsTagContainerView: View {
    
    let brands: [Brand]
    let tagType: BrandTagType
    let onSelectBrand: (Brand) -> Void
    
    var body: some View {
        AdaptiveFlowLayoutView(
            data: brands,
            interitemSpacing: 8,
            lineSpacing: 8
        ) { brand in
            TagView(brand: brand, tagType: tagType) {
                onSelectBrand(brand)
            }
        }
        .padding(.horizontal, 16)
    }
}

extension BrandsTagContainerView {
    
    struct TagView: View {
        
        let brand: Brand
        let tagType: BrandTagType
        let onSelect: () -> Void
        
        private var borderRadius: CGFloat {
            return tagType == .suggestion ? 4 : 2
        }
        
        var body: some View {
            Button {
                onSelect()
            } label: {
                HStack(spacing: 4) {
                    Text(brand.name)
                        .font(kernedFont: .Secondary.p1RegularKerned)
                        .foregroundColor(.jet)
                    tagType.tagImage
                        .resizable()
                        .renderingMode(.template)
                        .frame(
                            width: tagType == .suggestion ? 10 : 14,
                            height: tagType == .suggestion ? 10 : 14
                        )
                        .foregroundColor(tagType == .suggestion ? .orangish : .jet)
                }
                .padding(4)
                .background(
                    tagType.background.cornerRadius(borderRadius)
                )
                .roundedBorder(tagType == .suggestion ? Color.clear : .midGrey, cornerRadius: borderRadius)
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
struct BrandsTagContainerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BrandsTagContainerView(brands: Brand.allBrands, tagType: .selection) { _ in}
            BrandsTagContainerView(brands: Brand.allBrands, tagType: .suggestion) { _ in}
        }
    }
}
#endif
