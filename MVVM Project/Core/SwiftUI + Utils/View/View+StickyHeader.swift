//
//  View+StickyHeader.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.01.2023.
//

import SwiftUI

extension View {
    
    func stickyHeaderEffect(minHeight: CGFloat?) -> some View {
        return self.modifier(StickyHeaderModifier(minHeight: minHeight))
    }
}

struct StickyHeaderModifier: ViewModifier {
    
    let minHeight: CGFloat?
    
    func body(content: Content) -> some View {
        GeometryReader { geometryProxy in
            let minY = geometryProxy.frame(in: .global).minY
            let size = geometryProxy.size
            
            if minY <= .zero {
                content
                    .frame(width: size.width, height: size.height, alignment: .center)
            } else {
                content
                    .offset(y: -minY)
                    .frame(width: size.width, height: size.height + minY)
            }
        }
        .frame(minHeight: minHeight)
    }
}
