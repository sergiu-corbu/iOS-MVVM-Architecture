//
//  ProfileNavigationBar.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.05.2023.
//

import SwiftUI

extension ProfileComponents {
    
    struct NavigationBar<AdditionalContent: View>: View {
        
        let isMinimized: Bool
        let username: String?
        let imageURL: URL?
        
        @ViewBuilder let addionalNavigationBarContent: AdditionalContent
        
        var body: some View {
            ZStack {
                addionalNavigationBarContent
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
                    .background(
                        ZStack {
                            isMinimized ? Color.darkGreen : .clear
                            if imageURL != nil {
                                LinearGradient(colors: [Color.jet.opacity(0), .jet.opacity(0.25)],
                                               startPoint: .bottom, endPoint: .top)
                            }
                        }
                        .ignoresSafeArea(.container, edges: .top)
                    )
                if isMinimized {
                    minimizedAvatarView
                }
            }
            .animation(.easeInOut, value: isMinimized)
        }
        
        @ViewBuilder private var minimizedAvatarView: some View {
            HStack(spacing: 4) {
                AsyncImageView(imageURL: imageURL, placeholder: {
                    Image(.userIcon)
                        .background(Color.midGrey)
                })
                .aspectRatio(1, contentMode: .fit)
                .clipShape(.circle)
                .frame(width: 24, height: 24)
                Text(username ?? "")
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(.midGrey)
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .padding(.bottom, 12)
        }
    }
}

#if DEBUG
#Preview {
    ProfileComponents.NavigationBar(
        isMinimized: true, username: "testUser",
        imageURL: URL(string: "https://s3.us-east-1.amazonaws.com/ns--upload-prod/brand/6526d6d12a44b54062936ca4/logoImage/1697044481200"),
        addionalNavigationBarContent: {}
    )
    .padding()
    .background(Color.darkGreen.clipShape(.rect(cornerRadius: 8)))
}
#endif
