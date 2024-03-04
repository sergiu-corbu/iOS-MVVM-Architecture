//
//  ProfilePlaceholders.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.06.2023.
//

import SwiftUI

extension ProfileComponents {
    
    struct SectionPlaceholderView: View {
        
        let image: ImageResource
        var accessLevel: ProfileAccessLevel? = nil
        let text: String
        
        var action: (() -> Void)?
        
        var body: some View {
            VStack(spacing: 16) {
                Image(image)
                Text(text)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(.ebony)
                    .multilineTextAlignment(.center)
                if accessLevel == .readWrite {
                    Button {
                        action?()
                    } label: {
                        Text(Strings.Buttons.createShow)
                            .font(kernedFont: .Secondary.p2BoldKerned)
                            .foregroundColor(.orangish)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(Color.beige.cornerRadius(5))
            .padding(16)
        }
    }
}

#if DEBUG
struct ProfileComponentsPlaceholders_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollView {
            ProfileComponents.SectionPlaceholderView(image: .mediaPlayerIcon, accessLevel: .readOnly, text: Strings.Placeholders.guestShows(owner: "creator"))
            ProfileComponents.SectionPlaceholderView(image: .mediaPlayerIcon, accessLevel: .readWrite, text: Strings.Placeholders.creatorShows)
        }
    }
}
#endif
