//
//  FavoriteIconView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 04.09.2023.
//

import SwiftUI

struct FavoriteIconWrapperView: View {
    
    let favoriteID: String
    let type: FavoriteType
    let style: FavoriteIconView.Style
    @EnvironmentObject private var favoritesManager: FavoritesManager
    
    //Internal
    @State private var isFavorite: Bool = false
    
    var body: some View {
        FavoriteIconView(isFavorite: $isFavorite, style: style, onValueChanged: handleValueChanged(_:))
            .onReceive(favoritesManager.updatePublisher.receive(on: DispatchQueue.main)) { updateContext in
                guard self.favoriteID == updateContext.objectID else { return }
                self.isFavorite = updateContext.isFavorite
            }
            .onAppear {
                isFavorite = favoritesManager.getFavoriteState(type: type, objectID: favoriteID)
            }
    }
    
    private func handleValueChanged(_ newValue: Bool) {
        let context = FavoriteUpdateContext(objectID: favoriteID, favoriteType: type, isFavorite: newValue)
        favoritesManager.processFavoriteAction(updateContext: context, onFailure: {
            self.isFavorite = false
        })
    }
}

struct FavoriteIconView: View {
    
    //Properties
    @Binding var isFavorite: Bool
    var style: Style = .circle
    var onValueChanged: ((Bool) -> Void)?
    
    //Internal
    @State private var bouncyAnimationInProgress = false
    private let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private let animationDuration: TimeInterval = 0.4
    
    var body: some View {
        Button {
            toggleFavoriteAction()
        } label: {
            baseView
                .frame(width: style.edgeLength, height: style.edgeLength)
                .overlay(
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(Color.darkGreen)
                        .scaleEffect(bouncyAnimationInProgress ? style.scales.maxScale : style.scales.minScale)
                        .animation(.spring(response: animationDuration), value: bouncyAnimationInProgress)
                )
        }
        .buttonStyle(.scaled)
    }
    
    @ViewBuilder private var baseView: some View {
        let fillColor = Color.cultured.opacity(0.9)
        switch style {
        case .circle: Circle().fill(fillColor)
        case .square:
            RoundedRectangle(cornerRadius: 2).fill(fillColor)
        case .squareLarge:
            RoundedRectangle(cornerRadius: 2).fill(fillColor)
                .roundedBorder(Color.cappuccino, cornerRadius: 5)
        }
    }
    
    private func toggleFavoriteAction() {
        isFavorite.toggle()
        onValueChanged?(isFavorite)
        hapticFeedbackGenerator.impactOccurred()
        
        if isFavorite {
            bouncyAnimationInProgress = true
            DispatchQueue.main.asyncAfter(seconds: animationDuration) {
                bouncyAnimationInProgress = false
            }
        }
    }
}

extension FavoriteIconView {
    enum Style {
        case circle
        case square
        case squareLarge
        
        var edgeLength: CGFloat {
            switch self {
            case .circle: return 56
            case .square: return 24
            case .squareLarge: return 44
            }
        }
    
        var scales: (minScale: CGFloat, maxScale: CGFloat) {
            switch self {
            case .circle, .squareLarge: return (1, 1.2)
            case .square: return (0.6, 0.8)
            }
        }
    }
}

#if DEBUG
struct FavoriteIconView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(false) { isFavoriteBinding in
            HStack {
                FavoriteIconView(isFavorite: isFavoriteBinding, style: .circle)
                FavoriteIconView(isFavorite: isFavoriteBinding, style: .square)
                FavoriteIconView(isFavorite: isFavoriteBinding, style: .squareLarge)
            }
        }
        .padding()
        .background(Color.cultured)
        .previewLayout(.sizeThatFits)
    }
}
#endif
