//
//  InputField + Preview.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 05.11.2022.
//

import SwiftUI

#if DEBUG
struct InputField_Previews: PreviewProvider {
    
    static var previews: some View {
        InputFieldPreview()
    }
    
    private struct InputFieldPreview: View {
        
        @State private var text1 = ""
        @State private var text2 = ""
        @State private var text3 = ""
        @State private var error: Error? = nil
        
        var body: some View {
            VStack(spacing: 40) {
                Button("Toggle error", action: toggleError)
                emailField()
                defaultEmail()
                usernameField()
            }
            .previewLayout(.sizeThatFits)
        }
        
        func emailField() -> some View {
            InputField(
                inputText: $text1,
                scope: "Enter your email",
                placeholder: "Email",
                leadingView: {Image(.mail)}, onSubmit: {}
            ).emailFieldStyle(error: error, focusDelay: 0.5)
        }
        
        func defaultEmail() -> some View {
            InputField(
                inputText: $text2,
                scope: "Name",
                placeholder: "Enter your name", onSubmit: {}
            ).defaultFieldStyle(hint: "some hint")
        }
        
        func usernameField() -> some View {
            InputField(
                inputText: $text3,
                scope: "Username",
                placeholder: "Enter your username", onSubmit: {}
            ).defaultFieldStyle(error: error, hint: "Usernames can contain letters (a-z), numbers (0-9), and periods (.)")
        }
        
        func toggleError() {
            if error != nil {
                error = nil
            } else {
                error = AuthenticationError.invalidEmail
            }
        }
    }
}
#endif

