//
//  AccountValidationView.swift
//  Bond
//
//  Created by Mihai Mocanu on 09.11.2022.
//

import SwiftUI

struct AccountValidationView: View {
    let viewModel: AccountValidationViewModel
    let mail = "chloe.bedford@gmail.com" /// for testing purposes this remains here
    
    var body: some View {
        ZStack {
            topAndBottomView
            centeredView
        }
    }
    
    private var topAndBottomView: some View {
        VStack {
            NavigationBar(inlineTitle: LocalizedStrings.NavigationTitles.joinBond) {
                viewModel.onBackNavigation.send()
            }
            Spacer()
            Buttons.FilledRoundedButton(title: LocalizedStrings.Buttons.openMail) {
                viewModel.onOpenMail.send()
            }
        }
        .primaryBackground()
    }
    
    private var centeredView: some View {
        VStack(spacing: 40) {
            Image(.outlinedMail)
                .foregroundColor(.brownJet)
            Text(LocalizedStrings.Authentication.mailConfirmationMessage)
                .foregroundColor(.brownJet)
                .font(kernedFont: .Main.h1MediumKerned)
            HStack {
                Text(LocalizedStrings.Authentication.mainConfirmationInfo)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                + Text(mail)
                    .font(kernedFont: .Secondary.p1BoldKerned)
                + Text(LocalizedStrings.Authentication.mainConfirmationMessage)
                    .font(kernedFont: .Secondary.p1RegularKerned)
            }
            .foregroundColor(.ebony)
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }
}

#if DEBUG
struct AccountValidationViewPreviews: PreviewProvider {
    static var previews: some View {
        AccountValidationView(viewModel: AccountValidationViewModel())
    }
}
#endif
