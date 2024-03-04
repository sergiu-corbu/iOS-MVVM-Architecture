//
//  ScrollView+VisibleContentInScrollBounds.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 25.10.2023.
//

import Foundation
import SwiftUI

extension View {
    
    func visibleContentInScrollBounds<Placeholder: View>(
        viewportSize: CGSize,
        coordinateSpace: CoordinateSpace,
        @ViewBuilder placeholder: () -> Placeholder
    ) -> some View {
        
        return modifier(
            VisibleContentInScrollBounds(viewportSize: viewportSize, coordinateSpace: coordinateSpace, placeholder: placeholder)
        )
    }
}

struct VisibleContentInScrollBounds<Placeholder: View>: ViewModifier {
    
    let viewportSize: CGSize
    let coordinateSpace: CoordinateSpace
    @ViewBuilder let placeholder: Placeholder
    
    //Internal
    @State private var isContentVisible = true
    
    func body(content: Content) -> some View {
        PassthroughView {
            if isContentVisible {
                content
            } else {
                placeholder
            }
        }
        .background(
            GeometryReader { proxy -> Color in
                updateContentVisibility(bounds: proxy.frame(in: coordinateSpace))
                return Color.clear
            }
        )
    }
    
    private func updateContentVisibility(bounds: CGRect) {
        let contentHeight = bounds.size.height
        let contentYOffset = bounds.origin.y
        let buffer: CGFloat = 100 + contentHeight
        let minOffset = -buffer
        let maxOffset = viewportSize.height + buffer
        
        let isInBounds = contentYOffset > minOffset && contentYOffset < maxOffset
        
        if isContentVisible != isInBounds {
            DispatchQueue.main.async {
                isContentVisible = isInBounds
            }
        }
    }
}
