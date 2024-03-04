//
//  ProfileCompletedView.swift
//  Bond
//
//  Created by Sergiu Corbu on 02.11.2022.
//

import SwiftUI

struct ProfileCompletedView: View {
    
    let onFinishedInteraction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Image(.logo)
                .padding(.top, 74)
            greetingMessageView()
            Buttons.FilledRoundedButton(
                title: LocalizedStrings.Buttons.startShopping,
                fillColor: .beige,
                tint: .darkGreen,
                action: onFinishedInteraction
            )
        }
        .background(
            Color.darkGreen.ignoresSafeArea(.container, edges: .vertical)
        )
    }
    
    private func greetingMessageView() -> some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.middleGrey)
            .overlay {
                ZStack {
                    VStack(spacing: 10) {
                        Text(LocalizedStrings.Authentication.welcomeMessage)                            .font(kernedFont: .Main.p1MediumKerned)
                            .foregroundColor(.brightGold)
                        Text(LocalizedStrings.Authentication.profileCompleted)
                            .font(kernedFont: .Main.h1MediumKerned)
                            .foregroundColor(.cremeCultured)
                            .multilineTextAlignment(.center)
                    }
                    Color.ebony.opacity(0.15)
                }
            }
            .frame(height: 128)
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity)
    }
    
    private func startShoppingButton() -> some View {
        Color.white
            .frame(height: 56)
    }
}

#if DEBUG
struct ProfileCompletedView_Previews: PreviewProvider {
    
    static var previews: some View {
        ProfileCompletedView(onFinishedInteraction: {})
    }
}
#endif
