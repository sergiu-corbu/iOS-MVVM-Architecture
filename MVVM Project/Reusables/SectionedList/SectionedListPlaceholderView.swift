//
//  SectionedListPlaceholderView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 10.09.2023.
//

import SwiftUI

struct SectionedListPlaceholderView: View {

    let message: String
    let image: ImageResource
    
    var body: some View {
        VStack(spacing: 24) {
            Image(image)
                .renderingMode(.template)
                .resizedToFit(size: CGSize(width: 42, height: 42))
                .foregroundColor(.battleshipGray.opacity(0.55))
            Text(message)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 16)
    }
}

#if DEBUG
struct SectionedListPlaceholderView_Previews: PreviewProvider {
    
    static var previews: some View {
        SectionedListPlaceholderView(message: Strings.Placeholders.favoriteShows, image: .addMediaIcon)
    }
}
#endif
