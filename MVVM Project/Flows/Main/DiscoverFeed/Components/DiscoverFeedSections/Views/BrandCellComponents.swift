//
//  BrandCellComponents.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.11.2023.
//

import SwiftUI

struct BrandLogoView: View {
    
    let imageURL: URL?
    var diameterSize: CGFloat
    
    var body: some View {
        AsyncImageView(imageURL: imageURL, localImage: nil, placeholder: {
           BrandPlaceholderView()
        })
        .clearBackground()
        .scaledToFit()
        .frame(width: diameterSize, height: diameterSize)
        .background(Color.white)
        .clipShape(Circle())
    }
}

struct BrandVView: View {
    
    let brand: Brand
    
    var body: some View {
        VStack(spacing: 8) {
            BrandLogoView(imageURL: brand.logoPictureURL, diameterSize: 64)
            brandTitle
        }
        .frame(height: 145)
        .frame(maxWidth: .infinity)
        .background(Color.beige.cornerRadius(8))
        .roundedBorder(Color.midGrey, cornerRadius: 8)
    }
    
    private var brandTitle: some View {
        Text(brand.name.uppercased())
            .font(kernedFont: .Secondary.p3BoldExtraKerned)
            .lineLimit(2)
            .minimumScaleFactor(0.9)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
    }
    
//    private var brandShowsCountView: some View {
//        Text("\(brand.numberOfShows ?? 0) shows")
//            .font(kernedFont: .Secondary.p1MediumKerned)
//            .foregroundColor(.ebony)
//    }
}
