//
//  PublicCreatorProfileView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.02.2023.
//

import SwiftUI

struct PublicCreatorProfileView: View {
    
    @ObservedObject var viewModel: PublicCreatorProfileViewModel
    let showVideoStreamBuilder: ShowVideoStreamBuilder
        
    var body: some View {
        BaseCreatorProfileView(
            viewModel: viewModel,
            showVideoStreamBuilder: showVideoStreamBuilder,
            accessLevel: .readOnly,
            navigationBarView: {
                navigationView
        }, profileContentView: {
            FollowButton(onFollowAction: {
                viewModel.handleFollowAction(isFollowing: $0)
            })
        })
        .environment(\.currentUserPublisher, showVideoStreamBuilder.userRepository.currentUserSubject)
    }
    
    private var navigationView: some View {
        ZStack {
            Buttons.BackButton(action: viewModel.onBack)
                .frame(maxWidth: .infinity, alignment: .leading)
            Buttons.ShareButton(tint: .white, onShare: viewModel.generateShareLink)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

extension PublicCreatorProfileView {
    
    struct FollowButton: View {
        
        @EnvironmentObject var followViewModel: FollowViewModel
        let onFollowAction: (Bool) -> Void
        
        private var isFollowing: Bool {
            return followViewModel.isFollowing
        }
        
        var body: some View {
            FollowContainerView(followViewModel: followViewModel) {
                Buttons.FilledRoundedButton(
                    title: followViewModel.followState.labelString,
                    isLoading: followViewModel.isLoading,
                    fillColor: .white.opacity(isFollowing ? 0.1 : 1),
                    tint: isFollowing ? .paleSilver : .jet,
                    action: {
                        followViewModel.handleFollowAction(completionHandler: {
                            onFollowAction(followViewModel.isFollowing)
                        })
                    }
                )
            }
        }
    }
}

#if DEBUG
struct PublicCreatorProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        PublicCreatorProfilePreview()
    }
    
    private struct PublicCreatorProfilePreview: View {
        
        @StateObject var viewModel = PublicCreatorProfileViewModel(
            creator: User.creator, showService: MockShowService(), creatorService: MockCreatorService(), deeplinkProvider: MockDeeplinkProvider(), onBack: {}, onRequestAuthentication: { _ in})
        
        var body: some View {
            PublicCreatorProfileView(viewModel: viewModel, showVideoStreamBuilder: .mockedBuilder)
                .environmentObject(FollowViewModel.mocked(followType: .user))
        }
    }
}
#endif
