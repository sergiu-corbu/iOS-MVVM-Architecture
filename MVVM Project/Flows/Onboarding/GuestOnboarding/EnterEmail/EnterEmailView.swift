//
//  EnterEmailView.swift
//  Bond
//
//  Created by Sergiu Corbu on 04.11.2022.
//

import SwiftUI

struct EnterEmailView: View {
    
    @ObservedObject var viewModel: EnterEmailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationBar(
                inlineTitle: viewModel.onboardingType.navigationTitle,
                onBack: viewModel.onBack.send
            )
            .padding(.bottom, 24)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text(Strings.Authentication.emailAddressQuestion)
                        .font(kernedFont: .Main.h1MediumKerned)
                        .foregroundColor(.jet)
                        .padding(.horizontal, 16)
                    inputFieldView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
            Image(.successImage)
                .renderingMode(.template)
                .foregroundColor(.darkGreen)
        case .idle, .typing: EmptyView()
        case .error(error: _): Image(.errorImage)
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
struct EnterEmailView_Previews: PreviewProvider {
    static var previews: some View {
        EnterEmailView(viewModel: EnterEmailViewModel(onboardingType: .register, authenticationService: MockAuthService()))
    }
}
#endif
