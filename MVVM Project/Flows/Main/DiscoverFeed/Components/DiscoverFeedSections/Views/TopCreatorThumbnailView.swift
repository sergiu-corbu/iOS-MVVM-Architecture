//
//  TopCreatorThumbnailView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.01.2023.
//

import SwiftUI

struct TopCreatorThumbnailView: View {
    
    let creator: Creator
    var thumbnailSize: ThumbnailSize = .medium
    var showAdditionalCreatorDetail = true
    
    enum ThumbnailSize {
        case small
        case medium
        case custom(width: CGFloat, height: CGFloat)
        
        var dimension: CGSize {
            switch self {
            case .small: CGSize(width: 72, height: 72)
            case .medium: CGSize(width: 80, height: 80)
            case .custom(width: let width, height: let height): CGSize(width: width, height: height)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncImageView(imageURL: creator.profilePictureUrl, placeholder: {
                Image(.userIcon)
                    .frame(size: thumbnailSize.dimension)
                    .background(Color.cappuccino, in: RoundedRectangle(cornerRadius: 4))
            })
            .aspectRatio(contentMode: .fill)
            .frame(size: thumbnailSize.dimension, alignment: .top)
            .cornerRadius(4)
            if showAdditionalCreatorDetail {
                Text(creator.fullName?.fullNameSplitted ?? "")
                    .font(kernedFont: .Secondary.p2RegularKerned)
                    .foregroundColor(.ebony)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(width: thumbnailSize.dimension.width)
    }
}

#if DEBUG
#Preview {
    HStack {
        TopCreatorThumbnailView(creator: .creator)
        TopCreatorThumbnailView(creator: .creator, thumbnailSize: .small)
        TopCreatorThumbnailView(creator: .creator, thumbnailSize: .custom(width: 40, height: 60))
    }
    
}
#endif
