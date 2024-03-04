//
//  CheckoutLabeledSectionContainer.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 30.12.2023.
//

import SwiftUI

struct CheckoutLabeledSectionContainer<Content: View>: View {
    
    let image: ImageResource
    let title: String
    var onEdit: (() -> Void)?
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(image)
                    .renderingMode(.template)
                    .resizedToFit(size: CGSize(width: 18, height: 18))
                    .foregroundColor(.paleSilver)
                Text(title)
                    .font(kernedFont: .Main.p1MediumKerned)
                    .foregroundColor(.jet)
                Spacer()
                if let onEdit {
                    Buttons.PlainEditButton(onEdit: onEdit)
                }
            }
            content
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        CheckoutLabeledSectionContainer(image: .userIcon, title: "User", content: { Color.random.frame(height: 50)
        }).padding()
        CheckoutLabeledSectionContainer(image: .userIcon, title: "User", onEdit: {}, content: { Color.random.frame(height: 50)
        }).padding()
    }
}
#endif
