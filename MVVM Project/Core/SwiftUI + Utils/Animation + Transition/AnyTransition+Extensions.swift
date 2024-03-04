//
//  AnyTransition+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.11.2022.
//

import SwiftUI

extension AnyTransition {
    
    static func transparentMoveScale(
        duration: TimeInterval = 0.5,
        scaleDuration: TimeInterval = 0.8,
        scaleAnchor: UnitPoint = .top
    ) -> AnyTransition {
        
        let transparentTransition = Self.opacity.animation(.easeInOut(duration: duration))
        let scaleTransition = Self.scale(scale: scaleDuration, anchor: scaleAnchor).animation(.easeInOut(duration: duration))
        return Self.move(edge: .bottom)
            .combined(with: transparentTransition)
            .combined(with: scaleTransition)
    }
    
    static func moveAndFade(
        edge: Edge = .top,
        duration: TimeInterval = 0.3
    ) -> Self {
        let removeTransition = Self.move(edge: edge).combined(with: .opacity)
        return .asymmetric(
            insertion: .move(edge: edge),
            removal: removeTransition.animation(.easeInOut(duration: duration))
        )
    }
    
    static func fade(duration: TimeInterval = 0.2) -> Self {
        return .opacity.animation(.easeInOut(duration: duration))
    }
    
    static var moveBottomAndFade: Self {
        let insertionTransition = Self.move(edge: .bottom).combined(with: .opacity.animation(.easeInOut))
        return Self.asymmetric(insertion: insertionTransition, removal: .identity)
    }
    
    static func fadeAndScale(duration: TimeInterval = 0.5) -> Self {
        return Self.opacity.animation(.easeInOut(duration: duration))
            .combined(with: .scale.animation(.linear(duration: duration)))
    }
    
    static func asymetricFade(isSource: Bool, duration: TimeInterval = 0.3) -> Self {
        let fadeTransition = Self.opacity.animation(.easeInOut(duration: duration))
        return .asymmetric(insertion: isSource ? .identity : fadeTransition, removal: isSource ? .identity : fadeTransition)
    }
}
