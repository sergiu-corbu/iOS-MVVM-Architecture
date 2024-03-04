//
//  NavigationBar.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.11.2022.
//

import SwiftUI

struct NavigationBar<TrailingView: View>: View {
    
    enum BarType {
        case logo
        case title
        case navigation
        case sheet
    }
    
    let barType: BarType
    let title: String
    var onDismiss: (() -> Void)?
    
    @ViewBuilder var trailingView: TrailingView
    
    var body: some View {
        ZStack {
            switch barType {
            case .navigation:
                backButton()
                inlineTitleView()
                trailingView
                    .frame(maxWidth: .infinity, alignment: .trailing)
            case .logo:
                logoImage()
            case .title:
                titleView()
            case .sheet:
                closeButton()
                inlineTitleView()
                trailingView
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(EdgeInsets(top: 22, leading: 16, bottom: 10, trailing: 16))
    }
}

extension NavigationBar {
    
    private func backButton() -> some View {
        Button {
            onDismiss?()
        } label: {
            Image(.backIcon)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func closeButton() -> some View {
        Button {
            onDismiss?()
        } label: {
            Image(.closeIcSmall)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func logoImage() -> some View {
        Image(.logo)
            .renderingMode(.template)
            .resizedToFit(size: nil)
            .frame(maxHeight: 20)
            .foregroundColor(.darkGreen)
            .frame(maxWidth: .infinity)
    }
    
    private func titleView() -> some View {
        Text(title)
            .font(.Main.h2Italic)
            .foregroundColor(.brownJet)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func inlineTitleView() -> some View {
        Text(title)
            .font(kernedFont: .Main.p1RegularKerned)
            .foregroundColor(.feldgrau)
            .lineLimit(1)
            .padding(.horizontal, 24)
    }
}

extension NavigationBar {
    
    func backButtonHidden(_ isHidden: Bool) -> some View {
        overlay(alignment: .leading, content: {
            if isHidden {
                Color.cultured
                    .frame(width: 20)
                    .padding(.leading, 16)
            }
        })
    }
}

extension NavigationBar where TrailingView == EmptyView {
    
    init(barType: BarType, title: String?, onDismiss: (() -> Void)? = nil) {
        self.barType = barType
        self.title = title ?? ""
        self.onDismiss = onDismiss
        self.trailingView = EmptyView()
    }
    
    init(inlineTitle: String, onDismiss: @escaping () -> Void) {
        self.barType = .navigation
        self.title = inlineTitle
        self.onDismiss = onDismiss
        self.trailingView = EmptyView()
    }
    
    init() {
        self.onDismiss = nil
        self.title = ""
        self.barType = .logo
        self.trailingView = EmptyView()
    }
    
    init(title: String) {
        self.title = title
        self.onDismiss = nil
        self.barType = .title
        self.trailingView = EmptyView()
    }
}

extension NavigationBar {
    
    init(inlineTitle: String, onDismiss: @escaping () -> Void, @ViewBuilder trailingView: () -> TrailingView) {
        self.barType = .navigation
        self.title = inlineTitle
        self.onDismiss = onDismiss
        self.trailingView = trailingView()
    }
}

struct NavigationButton: View {
    
    let image: ImageResource
    let tint: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(image)
                .renderingMode(.template)
                .foregroundColor(tint)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct NavigationBar_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            NavigationBar(title: "Search")
                .background(Color.cultured)
            NavigationBar(inlineTitle: "Sign In", onDismiss: {})
                .background(Color.cultured)
            NavigationBar()
                .background(Color.cultured)
            NavigationBar(inlineTitle: "SignIn", onDismiss: {})
            NavigationBar(inlineTitle: "SignIn", onDismiss: {}) {
                Button {} label: {
                    Image(systemName: "bag")
                        .tint(.brownJet)
                }
            }
            Color.clear
        }
    }
}
#endif
