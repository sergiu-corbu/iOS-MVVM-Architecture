//
//  BrandCollaborationsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.11.2022.
//

import SwiftUI

struct BrandCollaborationsView: View {
    
    let brands: [PartnershipBrand]
    let selectedBrandIDs: Set<String>
    let selectionHandler: (PartnershipBrand) -> Void
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 2)
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 4) {
            ForEach(brands, id: \.name) {
                brandView($0)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func brandView(_ brand: PartnershipBrand) -> some View {
        let isSelected = selectedBrandIDs.contains(brand.id)
        return Button {
            selectionHandler(brand)
        } label: {
            brandDetailsView(brand, isSelected: isSelected)
                .roundedBorder(Color.midGrey, cornerRadius: 6)
                .overlay(alignment: .topTrailing) {
                    if isSelected {
                        SquareStyledCheckmarkView(isSelected: isSelected)
                            .padding([.top, .trailing], 8)
                    }
                }
        }
        .buttonStyle(.plain)
    }
    
    private func brandDetailsView(_ brand: PartnershipBrand, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            AsyncImageView(imageURL: brand.brandPictureURL, localImage: nil, placeholder: {
               BrandPlaceholderView()
            })
            .aspectRatio(contentMode: .fit)
            .frame(width: 36, height: 36)
            .background(Color.white)
            .clipShape(Circle())
            Text(brand.name.uppercased())
                .font(kernedFont: .Secondary.p4BoldKerned)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(height: 105)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.beige : .cultured)
        .animation(.easeInOut(duration: 0.35), value: isSelected)
    }
}

struct BrandPlaceholderView: View {
    
    var body: some View {
        Image(.noMediaIcon)
            .renderingMode(.template)
            .resizedToFit(width: nil, height: nil)
            .padding(4)
            .background(Color.cappuccino, in: Circle())
            .foregroundColor(.middleGrey)
    }
}

#if DEBUG
struct BrandCollaborationsView_Previews: PreviewProvider {
    
    static var previews: some View {
        BrandCollaborationsViewPreviews()
            .previewLayout(.sizeThatFits)
    }
    
    private struct BrandCollaborationsViewPreviews: View {
        
        let brands = PartnershipBrand.allBrands
        
        var body: some View {
            BrandCollaborationsView(brands: brands, selectedBrandIDs: .init(), selectionHandler: { _ in })
                .primaryBackground()
        }
    }
}
#endif
