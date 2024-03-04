//
//  DiscoverFeedContainerSectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.11.2023.
//

import SwiftUI

struct DiscoverFeedContainerSectionView<Content: View>: View {
    
    let title: String
    var expandActionEnabled = true
    var onExpandSection: (() -> Void)?
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 0) {
                Text(title.uppercased())
                    .font(kernedFont: .Main.h2BoldKerned)
                    .foregroundColor(.jet)
                Spacer()
                if onExpandSection != nil {
                    Buttons.SeeAll {
                        onExpandSection?()
                    }
                    .disabled(!expandActionEnabled)
                }
            }
            .padding(.horizontal, 16)
            content
                .transition(.opacity)
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        DiscoverFeedContainerSectionView(title: "Top Deals", content: {
            Color.random.frame(height: 100)
                .padding(.horizontal, 16)
        })
        DiscoverFeedContainerSectionView(title: "Top Deals", onExpandSection: {}, content: {
            Color.random.frame(height: 100)
                .padding(.horizontal, 16)
        })
    }
}
#endif
