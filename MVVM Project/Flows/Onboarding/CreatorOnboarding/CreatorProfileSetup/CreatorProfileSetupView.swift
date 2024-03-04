//
//  CreatorProfileSetupView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.11.2022.
//

import SwiftUI

struct CreatorProfileSetupView: View {
    
    @ObservedObject var viewModel: CreatorProfileSetupViewModel
    @FocusState private var selectedInputField: InputFieldType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            NavigationBar(
                inlineTitle: Strings.NavigationTitles.applyAsACreator,
                onDismiss: viewModel.onBack.send
            )
            StepProgressView(currentIndex: 2, progressStates: viewModel.progressStates)
            mainContent()
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.continue,
                isEnabled: viewModel.continueButtonEnabled,
                isLoading: viewModel.isLoading
            ) {
                selectedInputField = nil
                viewModel.continueAction()
            }
        }
        .primaryBackground()
        .errorToast(error: $viewModel.backendError)
        .onDisappear(perform: viewModel.usernameAvailabilityTask?.cancel)
    }
    
    private func mainContent() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                Text(Strings.Authentication.detailsLeft)
                    .font(kernedFont: .Main.h1MediumKerned)
                    .foregroundColor(.jet)
                    .padding(.horizontal, 16)
                VStack(alignment: .leading, spacing: 12) {
                    fullNameField()
                    usernameField()
                }
                .onChange(of: selectedInputField) { newField in
                    if newField == .username, viewModel.fullName.isEmpty {
                        viewModel.fullnameError = AuthenticationError.invalidFullname
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func fullNameField() -> some View {
        InputField(
            inputText: $viewModel.fullName,
            scope: Strings.TextFieldScope.fullName,
            placeholder: Strings.Placeholders.fullName,
            submitLabel: .next,
            leadingView: {
                Image(.userIcon)
            }, onSubmit: {
                selectedInputField = .username
            }
        )
        .defaultFieldStyle(
            error: viewModel.fullnameError,
            hint: Strings.TextFieldHints.fullName,
            contentType: .name
        ).focused($selectedInputField, equals: .fullName)
    }
    
    private func usernameField() -> some View {
        InputField(
            inputText: $viewModel.username.lowercased(),
            scope: Strings.TextFieldScope.username,
            placeholder: Strings.Placeholders.username,
            submitLabel: .done,
            onSubmit: {
                viewModel.continueAction()
            }, leadingView: {
                Image(.userIcon)
            }, trailingView: {
                if viewModel.isValidatingUsername {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    switch viewModel.usernameFieldState {
                    case .typing, .idle: EmptyView()
                    case .success: Image(.successIcon)
                    case .error(error: _): Image(.errorIcon)
                    }
                }
            }
        )
        .defaultFieldStyle(
            error: viewModel.usernameFieldState.error,
            hint: Strings.TextFieldHints.username
        )
        .focused($selectedInputField, equals: .username)
        .textInputAutocapitalization(.never)
        .debounce(publisher: viewModel.$username, viewModel.checkUsernameAvailability)
    }
}

#if DEBUG
struct CreatorProfileSetupView_Previews: PreviewProvider {
    
    static var previews: some View {
        CreatorProfileSetupPreview()
    }
    
    private struct CreatorProfileSetupPreview: View {
        
        @StateObject var viewModel = CreatorProfileSetupViewModel(
            authenticationService: MockAuthService(),
            userRepository: MockUserRepository())
        
        var body: some View {
            CreatorProfileSetupView(viewModel: viewModel)
        }
    }
}
#endif
