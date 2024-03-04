//
//  MinimizedCreatorProfileView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.03.2023.
//

import SwiftUI

struct MinimizedCreatorProfileView: View {
    
    let creator: Creator
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 4) {
                AsyncImageView(imageURL: creator.profilePictureUrl, placeholderImage: .userIcon)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 24, height: 24)
                Text(creator.fullName ?? creator.email)
                    .font(kernedFont: .Secondary.p4RegularKerned)
                    .foregroundColor(.white)
                    .shadow(color: .white, radius: 15)
            }
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    MinimizedCreatorProfileView(creator: .creator, onSelect: {})
}
#endif
