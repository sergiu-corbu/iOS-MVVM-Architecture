//
//  JoinRestrictionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 05.07.2023.
//

import SwiftUI

extension View {
    func signInRestrictionOverlay(isPresented: Bool, onRequestAuthentication: (() -> Void)? = nil) -> some View {
        return self.modifier(JoinRestrictionViewModifier(isPresented: isPresented, onRequestAuthentication: onRequestAuthentication))
    }
}

struct JoinRestrictionViewModifier: ViewModifier {
    
    let isPresented: Bool
    let onRequestAuthentication: (() -> Void)?
    
    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                restrictionView
            }
        }
    }
    
    var restrictionView: some View {
        ZStack {
            VisualEffectView(blurStyle: .regular, vibrancyStyle: .fill)
            Color.battleshipGray.opacity(0.55)
            let gradient = IncreasingGradient(startValue: 0.1, endValue: 0.85)
            LinearGradient(gradient: gradient.makeGradient(.jet), startPoint: .top, endPoint: .bottom)
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(Strings.Authentication.joinUs)
                        .font(.Main.h1Italic)
                    Text(Strings.Authentication.accountCreationMessage)
                        .font(kernedFont: .Secondary.p1RegularKerned)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                .foregroundColor(.white)
                Buttons.FilledRoundedButton(
                    title: Strings.Buttons.authenticate,
                    fillColor: .beige, tint: .darkGreen,
                    action: { onRequestAuthentication?() }
                )
            }
        }
    }
}

#if DEBUG
struct JoinRestrictionView_Previews: PreviewProvider {
    static var previews: some View {
        Color.red
            .signInRestrictionOverlay(isPresented: true, onRequestAuthentication: nil)
            .ignoresSafeArea()
    }
}
#endif
