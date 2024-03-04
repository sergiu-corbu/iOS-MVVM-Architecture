//
//  PersonalDetailsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.11.2022.
//

import SwiftUI

struct PersonalDetailsView: View {
    
    @ObservedObject var viewModel: PersonalDetailsViewModel
    @FocusState private var selectedField: InputFieldType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationBar(
                inlineTitle: Strings.NavigationTitles.personalDetails,
                onDismiss: viewModel.onFinishedInteraction.send,
                trailingView: {
                    Buttons.SaveButton(
                        isEnabled: viewModel.saveButtonEnabled,
                        isLoading: viewModel.isLoading) {
                            viewModel.savePersonalDetails()
                        }
                }
            )
            ScrollView {
                inputFieldsView
                    .padding(.top, 10)
                    .onChange(of: selectedField) { newField in
                        if newField == .username, viewModel.fullName.isEmpty {
                            viewModel.fullnameError = AuthenticationError.invalidFullname
                        }
                    }
            }
        }
        .primaryBackground()
        .errorToast(error: $viewModel.backendError)
    }
    
    private var inputFieldsView: some View {
        VStack(spacing: 12) {
            InputField(
                inputText: .constant(viewModel.userEmail),
                scope: Strings.TextFieldScope.email,
                placeholder: Strings.Placeholders.email,
                leadingView: {
                    Image(.mail)
                }, onSubmit: { }
            )
            .emailFieldStyle(error: nil)
            .disabled(true)
            fullNameField()
            usernameField()
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
                selectedField = .username
            }
        )
        .defaultFieldStyle(
            error: viewModel.fullnameError,
            hint: Strings.TextFieldHints.fullName,
            contentType: .name
        ).focused($selectedField, equals: .fullName)
    }
    
    private func usernameField() -> some View {
        InputField(
            inputText: $viewModel.username.lowercased(),
            scope: Strings.TextFieldScope.username,
            placeholder: Strings.Placeholders.username,
            submitLabel: .done,
            onSubmit: {
                viewModel.savePersonalDetails()
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
        .focused($selectedField, equals: .username)
        .textInputAutocapitalization(.never)
        .debounce(publisher: viewModel.$username, viewModel.checkUsernameAvailability)
    }
}

#if DEBUG
struct PersonalDetailsView_Previews: PreviewProvider {
    
    static var previews: some View {
        PersonalDetailsView(viewModel: .init(user: User.creator, userRepository: MockUserRepository(), userSession: MockUserSession(), authenticationService: MockAuthService()))
    }
}
#endif
