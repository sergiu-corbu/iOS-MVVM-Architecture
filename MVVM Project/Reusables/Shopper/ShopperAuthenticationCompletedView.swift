//
//  ShopperAuthenticationCompletedView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 11.11.2022.
//

import SwiftUI

struct ShopperAuthenticationCompletedView: View {
    
    let action: () -> Void
    
    var body: some View {
        LogoContainerView(
            buttonTitle: Strings.Buttons.startDiscovering,
            contentView: content,
            action: action
        )
    }
    
    private func content() -> some View {
        VStack(spacing: 8) {
            Text(Strings.Authentication.welcomeMessage).font(kernedFont: .Main.p2RegularKerned)
                .foregroundColor(.brightGold)
            Text(Strings.Authentication.profileCompleted)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundColor(.cultured)
                .multilineTextAlignment(.center)
        }
        .outlinedBackground()
    }
}

struct ShopperAuthenticationCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        ShopperAuthenticationCompletedView(action: {})
    }
}
