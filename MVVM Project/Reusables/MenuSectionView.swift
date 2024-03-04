//
//  MenuSectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import SwiftUI

struct MenuSectionView<Content: View>: View {
    
    let image: ImageResource
    let title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(image)
                Text(title)
                    .font(kernedFont: .Main.p1MediumKerned)
                    .foregroundColor(.orangish)
                    .textCase(.uppercase)
                Spacer()
            }
            .padding(.horizontal, 16)
            Rectangle()
                .fill(Color.midGrey)
                .frame(height: 1)
            VStack(spacing: 0) {
                content
            }
        }
        .background(Color.cultured)
    }
}
    
struct MenuSectionRowView: View {
    
    let title: String
    var kernedFont: KernedFont = .Secondary.p1RegularKerned
    var foregroundColor: Color = .ebony
    var image: ImageResource? = .chevronRight
    var url: URL? = nil
    var isEnabled: Bool = true
    var action: (() -> Void)?
    
    var body: some View {
        if let url = url {
            Link(destination: url) {
                rowContent
            }
            .buttonStyle(.plain)
        } else {
            Button {
                action?()
            } label: {
                rowContent
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
        }
    }
    
    private var rowContent: some View {
        HStack {
            Text(title)
                .font(kernedFont: kernedFont)
                .foregroundColor(foregroundColor)
            Spacer()
            if let image {
                Image(image)
            }
        }
        .background(Color.cultured)
        .padding(EdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16))
    }
}

#if DEBUG
struct MenuSectionView_Previews: PreviewProvider {
    static var previews: some View {
        MenuSectionView(image: .shield, title: "App Setings") {
            VStack {
                ForEach(0..<10, id: \.self) {
                    MenuSectionRowView(title: "Number \($0)", url: nil)
                }
            }
        }
    }
}
#endif
