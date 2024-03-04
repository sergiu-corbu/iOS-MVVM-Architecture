//
//  PersonalCreatorProfileView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.11.2022.
//

import SwiftUI

struct PersonalCreatorProfileView: View {
    
    @ObservedObject var viewModel: PersonalCreatorProfileViewModel
    
    @Namespace private var creatorProfileNamespace
    @State private var showMinimizedProfile = false
    private let navBarHeight: CGFloat = 28
    
    var body: some View {
        BaseCreatorProfileView(
            viewModel: viewModel, showVideoStreamBuilder: viewModel.showVideoStreamBuilder,
            accessLevel: .readWrite, navigationBarView: {
                navigationView
            }, profileContentView: profileContentView
        )
        .liveStreamSetupRoomSelectionAlert($viewModel.liveStreamSelectionError)
        .environmentObject(viewModel.videoUploadProgressContainer)
        .onAppear(perform: viewModel.onViewAppeared)
        .minimizedCartViewOverlay(cartManager: viewModel.checkoutCartManager, onPresentCart: viewModel.creatorProfileAction?.onPresentCart)
    }
    
    private func profileContentView() -> some View {
        HStack(spacing: -16) {
            let tint = viewModel.creatorHasImage ? Color.white : .ebony
            let fill = viewModel.creatorHasImage ? Color.white.opacity(0.1) : .cappuccino
            Buttons.FilledRoundedButton(title: Strings.Buttons.editProfile, fillColor: fill, tint: tint, additionalLeadingView: {
                Image(.editDashIcon)
            }, action: { viewModel.creatorProfileAction?.onEditProfile() })
            Buttons.FilledRoundedButton(title: Strings.Buttons.favorites, fillColor: fill, tint: tint, additionalLeadingView: {
                Image(systemName: "heart")
                    .foregroundColor(.white)
            }, action: { viewModel.creatorProfileAction?.onShowFavorites() })
        }
    }
}

//MARK: NavigationBar
private extension PersonalCreatorProfileView {
    
    var navigationView: some View {
        let tint = viewModel.creatorHasImage || showMinimizedProfile ? Color.white : .ebony
        return HStack(spacing: 16) {
            NavigationButton(image: .settingsIcon, tint: tint, action: { viewModel.creatorProfileAction?.onShowSettings() })
            Spacer()
            NavigationButton(image: .shareIcon, tint: tint, action: viewModel.generateProfileShareLink)
            NavigationButton(image: .package, tint: tint, action: { viewModel.creatorProfileAction?.onShowOrders() })
        }
        .shadow(color: .jet, radius: viewModel.creatorHasImage ? 3 : 0)
    }
}

#if DEBUG
struct PersonalCreatorProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        ForEach(previewDevices) {
            PersonalCreatorProfileViewFilledPreviews(viewModel: _viewModel)
                .previewDisplayName("Filled profile")
                .previewDevice($0)
        }
        PersonalCreatorProfileViewUnfilledPreviews(viewModel: _viewModel)
            .previewDisplayName("Unfilled profile")
    }
    
    static let _viewModel = PersonalCreatorProfileViewModel(
        creator: User.creator, userRepository: MockUserRepository(),
        userSession: MockUserSession(), deeplinkProvider: MockDeeplinkProvider(), checkoutCartManager: .mocked,
        creatorService: MockCreatorService(),
        showService: MockShowService(),
        uploadService: MockAWSUploadService(),
        showStreamBuilder: .mockedBuilder, creatorProfileAction: .emptyActions
    )
    
    private struct PersonalCreatorProfileViewFilledPreviews: View {
        
        @ObservedObject var viewModel: PersonalCreatorProfileViewModel
        
        var body: some View {
            PersonalCreatorProfileView(viewModel: viewModel)
                .onAppear {
                    DispatchQueue.main.asyncAfter(seconds: 0.5) {
                        viewModel.localProfileImage = UIImage(named: "user_profile")
                    }
                }
        }
    }
        
    private struct PersonalCreatorProfileViewUnfilledPreviews: View {
        
        @ObservedObject var viewModel: PersonalCreatorProfileViewModel
                
        var body: some View {
            PersonalCreatorProfileView(viewModel: viewModel)
                .task {
                    viewModel.creator.profilePictureUrl = nil
//                    await Task.sleep(seconds: 2)
//                    viewModel.localProfileImage = UIImage(named: "user_profile")
                }
        }
    }
}
#endif
