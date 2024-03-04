//
//  PublishedShowView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 12.12.2022.
//

import SwiftUI

struct PublishedShowView: View {
    
    let onFinishedInteraction: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.darkGreen.ignoresSafeArea(.container, edges: .vertical)
                .overlay(messageView)
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.done,
                fillColor: .beige,
                tint: .darkGreen,
                action: onFinishedInteraction
            )
        }
    }
    
    private var messageView: some View {
        VStack(spacing: 10) {
            Text(Strings.ContentCreation.congratsMessage.uppercased())
                .font(kernedFont: .Main.p1RegularKerned)
                .foregroundColor(.brightGold)
            Text(Strings.ContentCreation.showIsBeingPublished)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundColor(.cultured)
        }
        .multilineTextAlignment(.center)
        .outlinedBackground()
    }
}

#if DEBUG
struct PublishedShowView_Previews: PreviewProvider {
    static var previews: some View {
        PublishedShowView(onFinishedInteraction: {})
    }
}
#endif
