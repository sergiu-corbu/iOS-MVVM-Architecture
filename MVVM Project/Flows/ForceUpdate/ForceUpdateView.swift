//
//  ForceUpdateView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.05.2023.
//

import SwiftUI

struct ForceUpdateView: View {
    
    var body: some View {
        VStack(spacing: 32) {
            Image(.logo)
                .resizedToFit(width: nil, height: 32)
                .padding(.top, 32)
            VStack(spacing: 80) {
                Text(Strings.Others.newVersionAvailable)
                    .font(kernedFont: .Main.h1RegularKerned)
                    .foregroundColor(.jet)
                Image(.updateIcon)
                Text(Strings.Others.forceUpdateMessage)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(.ebony)
                    .lineSpacing(6)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            Spacer()
            Buttons.FilledRoundedButton(title: Strings.Buttons.update, action: {
                UIApplication.shared.tryOpenURL(Constants.APP_APPSTORE_URL)
            })
        }
        .primaryBackground()
    }
}

#if DEBUG
struct ForceUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        ForceUpdateView()
    }
}
#endif
