//
//  DiscoverShowCard.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 04.04.2023.
//

import SwiftUI

struct DiscoverShowCard: View {
    
    let show: Show
    var cardSize: CGSize = CGSize(width: 120, height: 280)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            thumbnailView
            creatorAndShowDetailView
        }
        .frame(width: cardSize.width, alignment: .top)
        .frame(maxHeight: cardSize.height, alignment: .top)
    }
    
    private var thumbnailView: some View {
        AsyncImageView(imageURL: show.thumbnailUrl, placeholderImage: .mediaContentIcon)
            .scaledToFill()
            .frame(width: cardSize.width, height: 160, alignment: .top)
            .background(Color.cappuccino)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var creatorAndShowDetailView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(show.creator?.formattedUsername ?? "")
                .font(kernedFont: .Secondary.p4RegularKerned)
                .foregroundColor(.middleGrey)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
            Text(show.title ?? "")
                .font(kernedFont: .Main.p1RegularKerned)
                .foregroundColor(.jet)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.9)
        }
    }
}

#if DEBUG
struct DiscoverShowCard_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(120), spacing: 16), count: 2), spacing: 16) {
                ForEach(Show.allShows) {
                    DiscoverShowCard(show: $0)
                }
            }
            .primaryBackground()
            .padding(.horizontal, 16)
        }
    }
}
#endif
