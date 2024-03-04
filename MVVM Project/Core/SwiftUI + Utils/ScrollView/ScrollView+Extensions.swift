//
//  ScrollView+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 10.11.2022.
//

import SwiftUI

extension ScrollViewProxy {
    
    func scrollTo<ID: Hashable>(
        _ id: ID,
        anchor: UnitPoint? = .zero,
        delay: TimeInterval? = nil,
        animation: Animation? = .easeOut
    ) {
        guard let delay else {
            withAnimation(animation) {
                scrollTo(id, anchor: anchor)
            }
            return
        }
        DispatchQueue.main.asyncAfter(seconds: delay) {
            withAnimation(animation) {
                scrollTo(id, anchor: anchor)
            }
        }
    }
}

extension View {
    
    func disableScrollBounces() -> some View {
        self.modifier(DisableScrollBounceModifier())
    }
    
}

struct DisableScrollBounceModifier: ViewModifier {
    
    private let scrollAppearance = UIScrollView.appearance()
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                scrollAppearance.bounces = false
            }
            .onDisappear {
                scrollAppearance.bounces = true
            }
    }
}
