//
//  CreatorEnterEmailView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.11.2022.
//

import SwiftUI

struct CreatorEnterEmailView: View {
    
    @ObservedObject var viewModel: CreatorEnterEmailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            NavigationBar(
                inlineTitle: Strings.NavigationTitles.applyAsACreator,
                onDismiss: viewModel.onBack.send
            )
            StepProgressView(currentIndex: 0, progressStates: viewModel.progressStates)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text(Strings.Authentication.emailAddressQuestion)
                        .font(kernedFont: .Main.h1MediumKerned)
                        .foregroundColor(.jet)
                        .padding(.horizontal, 16)
                    inputFieldView()
                }
            }
            footerSection
        }
        .primaryBackground()
    }
    
    private func inputFieldView() -> some View {
        InputField(
            inputText: $viewModel.email,
            scope: Strings.TextFieldScope.email,
            placeholder: Strings.Placeholders.email,
            leadingView: {
                Image(.mail)
            }, trailingView: {
                inputFieldTrailingView()
            },
            onSubmit: viewModel.requestSignInEmail
        )
        .emailFieldStyle(error: viewModel.emailFieldState.error, focusDelay: 0.5)
        .debounce(publisher: viewModel.$email, viewModel.validateEmail)
    }
        
    @ViewBuilder
    private func inputFieldTrailingView() -> some View {
        switch viewModel.emailFieldState {
        case .success:
            Image(.successIcon)
                .renderingMode(.template)
                .foregroundColor(.darkGreen)
        case .idle, .typing: EmptyView()
        case .error(error: _): Image(.errorIcon)
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 0) {
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.continue,
                isEnabled: viewModel.continueButtonEnabled,
                isLoading: viewModel.isLoading,
                action: viewModel.requestSignInEmail
            )
            VStack(spacing: 4) {
                Text(Strings.TermsAndConditions.continueAgreement)
                    .foregroundColor(.jet)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                Link(destination: Constants.TERMS_AND_CONDITIONS) {
                    Text(Strings.TermsAndConditions.termsAndConditions)
                        .foregroundColor(.orangish)
                        .font(kernedFont: .Secondary.p1BoldKerned)
                }
            }
            .frame(maxWidth: .infinity)
            .padding([.horizontal, .bottom], 16)
        }
    }
}

#if DEBUG
struct CreatorEnterEmailView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorEnterEmailView(viewModel: CreatorEnterEmailViewModel(authenticationService: MockAuthService()))
    }
}
#endif
