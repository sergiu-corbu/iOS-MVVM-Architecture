//
//  BrandAvatarView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.05.2023.
//

import SwiftUI

struct BrandAvatarView: View {
    
    let name: String
    let imageURL: URL?
    let followers: Int
    
    var body: some View {
        HStack(spacing: 12) {
            BrandLogoView(imageURL: imageURL, diameterSize: 80)
            brandShortDetailView
        }
        .padding(.horizontal, 16)
    }
        
    private var brandShortDetailView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.Main.h1Italic)
                .foregroundColor(.white)
//            HStack(spacing: 4) {
//                Text(followers, format: .number.notation(.compactName))
//                    .font(kernedFont: .Secondary.p1BoldKerned)
//                    .foregroundColor(.orangish)
//                    .monospacedDigit()
//                Text(Strings.Profile.followers)
//                    .font(kernedFont: .Secondary.p1RegularKerned)
//                    .foregroundColor(.cultured)
//            }
        }
    }
    
}

#if DEBUG
struct BrandAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BrandAvatarView(name: "Baldinini", imageURL: .sampleImageURL, followers: 3414)
            BrandAvatarView(name: "Baldinini", imageURL: nil, followers: 10)
        }
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.gray)
    }
}
#endif
