//
//  SignUpConfirmationView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 10.01.2023.
//

import SwiftUI

struct SignUpConfirmationView: View {
    
    @ObservedObject var viewModel: SignUpConfirmationViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Buttons.CancelButton(onCancel: viewModel.onCancel)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 16)
            VStack(spacing: 32) {
                accountConfirmationView
                ProgressView()
                    .tint(.darkGreen)
                    .scaleEffect(1.2)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .padding(.top, 12)
        .primaryBackground()
        .onAppear(perform: viewModel.validateAuthenticationCode)
        .errorToast(error: $viewModel.error)
    }
    
    private var accountConfirmationView: some View {
        VStack(spacing: 36) {
            Text(Strings.Authentication.oneMoment)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundColor(.jet)
            Text(Strings.Authentication.accountConfirmationMessage)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .lineLimit(3)
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
struct SignUpConfirmationView_Previews: PreviewProvider {
    
    static var previews: some View {
        SignUpConfirmationPreview()
    }
    
    private struct SignUpConfirmationPreview: View {
        @StateObject var viewModel = SignUpConfirmationViewModel(authenticationCode: "", authenticationService: MockAuthService(), userSession: MockUserSession(), onCancel: {}, onFinishedValidation: {_ in})
        
        var body: some View {
            Color.cultured
                .sheet(isPresented: .constant(true)) {
                    SignUpConfirmationView(viewModel: viewModel)
                }
        }
    }
}
#endif
