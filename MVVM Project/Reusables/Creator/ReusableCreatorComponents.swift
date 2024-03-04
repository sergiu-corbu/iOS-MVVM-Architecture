//
//  ReusableCreatorComponents.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.11.2022.
//

import SwiftUI

//MARK: CreatorStepProgress
struct StepProgressView: View {
    
    let currentIndex: Int
    let progressStates: [ProgressState]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PaginatedProgressView(
                currentIndex: .constant(currentIndex),
                states: progressStates,
                tint: .orangish,
                backgroundColor: .midGrey,
                maxIndex: progressStates.count,
                autoAnimationDidFinish: true
            )
            .frame(height: 1)
            Text("Step \(currentIndex + 1)/\(progressStates.count)")
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.middleGrey)
        }
        .padding(.horizontal, 16)
    }
}

//MARK: CreatorProfileCompleted
struct CreatorProfileCompletedView: View {
    
    let action: () -> Void
    
    var body: some View {
        LogoContainerView(
            buttonTitle: Strings.Buttons.startDiscovering,
            contentView: content,
            action: action
        )
    }
    
    private func content() -> some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text(Strings.Authentication.welcomeMessage)
                        .font(kernedFont: .Main.p2RegularKerned)
                        .foregroundColor(.brightGold)
                    Text(Strings.Authentication.profileCompleted)
                        .font(kernedFont: .Main.h1MediumKerned)
                        .foregroundColor(.cultured)
                }
                
                Text(Strings.Authentication.reviewingApplication)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(.midGrey)
            }
            .padding(.horizontal, 16)
            CustomProgressBar(percentage: 100, textColor: .cultured)
        }
        .multilineTextAlignment(.center)
        .outlinedBackground()
    }
}

struct BrandHeaderView: View {
    
    let brandName: String
    let pictureURL: URL?
    
    var body: some View {
        HStack(spacing: 10) {
            BrandLogoView(imageURL: pictureURL, diameterSize: 40)
            Text(brandName.uppercased())
                .font(kernedFont: .Secondary.p4BoldKerned)
                .foregroundColor(.darkGreen)
        }
    }
}

//MARK: CreatorAccountCreated
struct CreatorAccountCreatedView: View {
    
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text(Strings.Authentication.accountCreated)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundColor(.jet)
                .multilineTextAlignment(.center)
                .padding(.top, 80)
            creatorProfileProgressView
                .frame(maxHeight: .infinity)
        }
        .primaryBackground()
    }
    
    var creatorProfileProgressView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 24) {
                Text(Strings.Authentication.completeProfileTitle)
                    .font(kernedFont: .Main.p1RegularKerned)
                CustomProgressBar(percentage: 50)
                Text(Strings.Authentication.completeProfileMessage)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(.ebony)
            }
            .multilineTextAlignment(.center)
            .padding([.horizontal, .top], 16)
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.continue,
                fillColor: .darkGreen,
                action: onContinue
            )
        }
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cappuccino)
        }
        .padding(.horizontal, 16)
    }
}

//MARK: CreatorAuthenticationCompleted
struct CreatorAuthenticationCompletedView: View {
    
    let name: String
    let action: () -> Void
    
    var body: some View {
        LogoContainerView(
            buttonTitle: Strings.Buttons.continue,
            contentView: content,
            action: action
        )
    }
    
    private func content() -> some View {
        VStack(spacing: 40) {
            VStack(spacing: 8) {
                Text(Strings.Authentication.thankYou(name: name))
                    .font(kernedFont: .Main.h1MediumKerned)
                    .foregroundColor(.cultured)
                Text(Strings.Authentication.applicationReceived)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(.cultured)
                    .multilineTextAlignment(.center)
            }
            
            Image(.outlinedMail)
                .renderingMode(.template)
                .foregroundColor(.middleGrey)
            
            Text(Strings.Authentication.applicationReceivedDescription)
                .font(kernedFont: .Secondary.p1BoldKerned)
                .foregroundColor(.lightGrey)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)
        .outlinedBackground()
    }
}

//MARK: Previews
#if DEBUG
struct ReusableCreatorComponents_Previews: PreviewProvider {
    
    static var previews: some View {
        CreatorAccountCreatedView(onContinue: {})
            .previewDisplayName("CreatorAccountCreated")
        CreatorAuthenticationCompletedView(name: "Sergiu", action: {})
            .previewDisplayName("CreatorAuthenticationCompleted")
        
    }
}

private let creatorBio = "Ms. Djerf, a 25-year-old social media influencer who founded the fashion brand Djerf Avenue with her boyfriend, Rasmus Johansson, in 2019, has forged a fast-growing business empire on tantalizing glimpses of her soft-focus Scandi dream life — not to mention one of TikTok’s most emulated haircuts."
#endif
