//
//  CreatorCellComponents.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.11.2023.
//

import SwiftUI

struct CreatorCardDetailView: View {
    
    let creator: Creator
    @ObservedObject var followViewModel: FollowViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            TopCreatorThumbnailView(creator: creator, thumbnailSize: .small, showAdditionalCreatorDetail: false)
            creatorDetailsView
        }
        .padding(16)
        .background(Color.beige, in: RoundedRectangle(cornerRadius: 8))
        .roundedBorder(Color.cappuccino, cornerRadius: 8)
    }
    
    private var creatorDetailsView: some View {
        VStack(spacing: 8) {
            Text(creator.fullName ?? "")
                .font(kernedFont: .Main.p1RegularKerned)
                .foregroundColor(.jet)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
            Text(creator.formattedUsername)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
                .lineLimit(1)
            FollowContainerView(followViewModel: followViewModel) {
                let isFollowing = followViewModel.isFollowing
                FollowButton(
                    isFollowing: isFollowing,
                    labelString: followViewModel.followingLabel,
                    action: {
                        if isFollowing { return }
                        followViewModel.handleFollowAction()
                    }
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    struct FollowButton: View {
        
        let isFollowing: Bool
        let labelString: String?
        let action: () -> Void
        
        var body: some View {
            Button {
               action()
           } label: {
               RoundedRectangle(cornerRadius: 4)
                   .fill(isFollowing ? Color.cappuccino : .clear)
                   .transaction { bgView in
                       bgView.animation = nil
                   }
                   .frame(width: 92, height: 28)
                   .roundedBorder(isFollowing ? .clear : .orangish, cornerRadius: 3)
                   .animation(.linear, value: isFollowing)
                   .overlay(
                       Text((labelString ?? "").uppercased())
                           .font(kernedFont: .Secondary.p1BoldKerned)
                           .foregroundColor(isFollowing ? .ebony : .orangish)
                   )
           }
           .buttonStyle(.plain)
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        CreatorCardDetailPreview(followState: .notFollowing)
        CreatorCardDetailPreview(followState: .following)
    }
    .frame(width: 180)
    .previewDisplayName("Follow Card States")

}

fileprivate struct CreatorCardDetailPreview: View {
    
    @State private var followState: FollowState
    
    init(followState: FollowState) {
        _followState = State(wrappedValue: followState)
    }
    
    var body: some View {
        CreatorCardDetailView(creator: .creator, followViewModel: .mocked(followType: .user))
    }
}
#endif
