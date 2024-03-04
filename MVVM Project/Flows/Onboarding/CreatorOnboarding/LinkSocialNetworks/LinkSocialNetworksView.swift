//
//  LinkSocialNetworksView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.11.2022.
//

import SwiftUI

struct LinkSocialNetworksView: View {
    
    @ObservedObject var viewModel: LinkSocialNetworksViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationBar(
                inlineTitle: Strings.NavigationTitles.applyAsACreator,
                onDismiss: viewModel.onBack.send
            )
            StepProgressView(currentIndex: 3, progressStates: viewModel.progressStates)
            mainContent
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.continue,
                isEnabled: !viewModel.selectedNetworkHandles.isEmpty,
                isLoading: viewModel.isLoading,
                action: viewModel.addSocialNetworks
            )
        }
        .primaryBackground()
        .errorToast(error: $viewModel.backendError)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 48) {
                linkSocialNetworksMessageView
                SocialNetworkContainerView(selectedSocialNetworks: Set(viewModel.selectedNetworkHandles.values)) {
                    viewModel.addSocialNetworkHandle($0)
                }
            }
        }
    }
    
    private var linkSocialNetworksMessageView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Strings.Authentication.linkHandlesMessage)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundColor(.jet)
            Text(Strings.Authentication.approvalInfo)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
struct LinkSocialNetworksHandles_Previews: PreviewProvider {
    
    static var previews: some View {
        LinkSocialNetworksView(viewModel: .init(creatorService: MockCreatorService(), userRepository: MockUserRepository()))
    }
}
#endif
