//
//  ShopperProfileView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.11.2022.
//

import Foundation
import SwiftUI

struct ShopperProfileView: View {
    
    @ObservedObject var viewModel: ShopperProfileViewModel
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(spacing: 0) {
                    topAnchorHelperView
                    headerSection
                    UserSettingsView(
                        user: viewModel.user,
                        onContactUs: { viewModel.actionHandler?.onContactUs() },
                        onShowPersonalDetails: { viewModel.actionHandler?.onShowPersonalDetails() },
                        onManageAccount: { viewModel.actionHandler?.onManageAccount() },
                        onApplyToSell: { viewModel.actionHandler?.onApplyToSell() }
                    )
                }
            }
            .splitColorBackground()
            .onChange(of: viewModel.sessionDidChange) { _ in
                reader.scrollTo(NamespaceID.topAnchor, delay: 0.5)
            }
            .minimizedCartViewOverlay(cartManager: viewModel.checkoutCartManager, onPresentCart: viewModel.actionHandler?.onPresentCart)
        }
    }
    
    //MARK: HeaderSection
    private var headerSection: some View {
        VStack(spacing: 24) {
            Image(.logo)
                .resizedToFit(width: 122, height: 32)
                .padding(EdgeInsets(top: 56, leading: 0, bottom: 32, trailing: 0))
            if let user = viewModel.user {
                profileAndOrdersView(user: user)
            } else {
                guestView
            }
        }
        .background(Color.darkGreen)
    }
    
    //MARK: ProfileView
    private func profileAndOrdersView(user: User) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            UserHeaderInformationView(user: user, onSelectSection: { _ in
                viewModel.actionHandler?.onSelectFollowSection()
            })
            HStack(spacing: -16) {
                Buttons.FilledRoundedButton(
                    title: Strings.Buttons.orders,
                    fillColor: .white.opacity(0.1),
                    additionalLeadingView: {
                        Image(.package)
                    }, action: { viewModel.actionHandler?.onShowOrders() })
                Buttons.FilledRoundedButton(
                    title: Strings.Buttons.favorites,
                    fillColor: .white.opacity(0.1),
                    additionalLeadingView: {
                        Image(systemName: "heart").foregroundColor(.white)
                    }, action: { viewModel.actionHandler?.onShowFavorites()})
            }
        }
        .transition(.fade())
    }
    
    //MARK: GuestView
    private var guestView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text(Strings.Profile.join)
                    .font(.Main.h1Italic)
                    .foregroundColor(.lightGrey)
                Text(Strings.Profile.signInToUseFeatures)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(.lightGrey)
                    .lineSpacing(2)
                    .multilineTextAlignment(.center)
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16))
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.createAnAccount,
                fillColor: .beige,
                tint: .darkGreen) {
                    viewModel.actionHandler?.onStartOnboardingFlow(.register)
                }
            .padding(.bottom, 8)
            signInView
        }
        .padding(.bottom, 16)
        .transition(.fade())
    }
    
    private var signInView: some View {
        VStack(spacing: 12) {
            Text(Strings.Profile.existentAccountQuestion)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.lightGrey)
            Button {
                viewModel.actionHandler?.onStartOnboardingFlow(.signIn)
            } label: {
                Text(Strings.Buttons.signIn)
                    .font(kernedFont: .Secondary.p2BoldKerned)
                    .foregroundColor(.orangish)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var topAnchorHelperView: some View {
        Color.clear
            .frame(height: 1)
            .id(NamespaceID.topAnchor)
    }
}

extension ShopperProfileView {
    
    struct NamespaceID {
        static let topAnchor = 0
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    
    static let guestViewModel = ShopperProfileViewModel(userRepository: MockUserRepository(), userSession: MockUserSession(), checkoutCartManager: .mocked, actionHandler: nil)
    
    static var previews: some View {
        Group {
            ShopperProfileView(viewModel: guestViewModel)
                .previewDisplayName("Guest Profile")
            ShopperPreview()
                .previewDisplayName("Shopper Profile")
        }
    }
    
    private struct ShopperPreview: View {
        
        @StateObject private var viewModel = ShopperProfileViewModel(userRepository: MockUserRepository(), userSession: MockUserSession(), checkoutCartManager: .mocked, actionHandler: nil)
        
        var body: some View {
            ShopperProfileView(viewModel: viewModel)
                .task {
                    viewModel.user = try? await viewModel.userRepository.getCurrentUser()
                }
        }
    }
}
#endif
