//
//  FollowCreatorView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.03.2023.
//

import SwiftUI

struct FollowCreatorView: View {
    
    @EnvironmentObject private var viewModel: FollowViewModel
    
    var body: some View {
        FollowContainerView(followViewModel: viewModel) {
            let isFollowing = viewModel.isFollowing
            Button {
                if isFollowing { return }
                viewModel.handleFollowAction()
            } label: {
                FollowCreatorButtonLabel(buttonLabel: viewModel.followingLabel, isFollowing: isFollowing)
            }
            .buttonStyle(.scaled)
            .opacity(viewModel.isLoading ? 0 : 1)
        }
    }
    
    struct FollowCreatorButtonLabel: View {
        
        let buttonLabel: String
        let isFollowing: Bool
        
        private var backgroundColor: Color {
            return isFollowing ? .midGrey.opacity(0.44) : .cultured
        }
        
        var body: some View {
            Text(buttonLabel.uppercased())
                .font(kernedFont: .Secondary.p3RegularExtraKerned)
                .foregroundColor(.ebony)
                .clipped()
                .animation(.linear, value: isFollowing)
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                .background(backgroundColor.cornerRadius(20))
                .roundedBorder(isFollowing ? Color.white.opacity(0.35) : .clear, cornerRadius: 20)
        }
    }
}

#if DEBUG
struct FollowCreatorView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            FollowCreatorView.FollowCreatorButtonLabel(buttonLabel: "Follow", isFollowing: false)
            FollowCreatorView.FollowCreatorButtonLabel(buttonLabel: "Unfollow", isFollowing: true)
        }
        .padding()
        .background(Color.cappuccino)
        .previewLayout(.sizeThatFits)
    }
}
#endif
