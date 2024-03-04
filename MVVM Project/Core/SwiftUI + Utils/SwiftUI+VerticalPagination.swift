//
//  SwiftUI+VerticalPagination.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.01.2023.
//

import SwiftUI

extension View {
    
    func verticalPaginated<Selection>(_ selection: Binding<Selection>?) -> some View where Selection: Hashable {
        return self.modifier(VerticalPaginatedViewModifier(selection: selection))
    }
}

struct VerticalPaginatedViewModifier<SelectionValue: Hashable>: ViewModifier {
    
    var selection: Binding<SelectionValue>?
    
    func body(content: Content) -> some View {
        GeometryReader { geometryProxy in
            TabView(selection: selection) {
                Group {
                    content
                }
                .rotationEffect(.degrees(-90))
                .frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
            }
            .frame(width: geometryProxy.size.height, height: geometryProxy.size.width)
            .rotationEffect(.degrees(90), anchor: .topLeading)
            .offset(x: geometryProxy.size.width)
            .ignoresSafeArea(.container, edges: .horizontal)
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}
