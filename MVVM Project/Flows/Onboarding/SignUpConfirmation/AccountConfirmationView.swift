//
//  AccountConfirmationView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.11.2022.
//

import SwiftUI

struct AccountConfirmationView: View {
    
    let userEmail: String
    var onboardingType: OnboardingType? = nil
    let onBack: () -> Void
    let onOpenMail: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            NavigationBar(
                inlineTitle: onboardingType?.navigationTitle ?? Strings.NavigationTitles.applyAsACreator,
                onDismiss: onBack
            )
            if onboardingType == nil {
                StepProgressView(currentIndex: 1, progressStates: ProgressState.createStaticStates(currentIndex: 1))
            }
            VStack(spacing: 40) {
                Image(.outlinedMail)
                    .foregroundColor(.brownJet)
                Text(Strings.Authentication.mailConfirmationMessage)
                    .foregroundColor(.brownJet)
                    .font(kernedFont: .Main.h1MediumKerned)
                confirmEmailMessageView
            }
            .frame(maxHeight: .infinity)
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.openMail,
                action: onOpenMail
            )
        }
        .primaryBackground()
    }
    
    private var confirmEmailMessageView: some View {
        VStack(spacing: 2) {
            HStack {
                Text(Strings.Authentication.mainConfirmationInfo)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                + Text(userEmail + ".")
                    .font(kernedFont: .Secondary.p1BoldKerned)
            }
            Text(Strings.Authentication.mainConfirmationMessage)
                .font(kernedFont: .Secondary.p1RegularKerned)
        }
        .foregroundColor(.ebony)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
    }
}

#if DEBUG
struct AccountConfirmationView_Previews: PreviewProvider {
    
    static var previews: some View {
        AccountConfirmationView(userEmail: "sergiu@icloud.com", onBack: {}, onOpenMail: {})
            .previewDevice(.iPhoneSE_3rd)
    }
}
#endif
