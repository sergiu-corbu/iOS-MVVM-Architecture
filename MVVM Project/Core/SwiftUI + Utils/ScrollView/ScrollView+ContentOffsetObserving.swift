//
//  ScrollView+ContentOffsetObserving.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.10.2023.
//

import SwiftUI

extension View {

    //This modifier should be applied on the content inside the scrollview
    func scrollContentOffset(
        coordinateSpace: CoordinateSpace = .global,
        _ onOffsetChanged: @escaping (CGPoint) -> Void
    ) -> some View {
        return modifier(ScrollContentOffsetViewModifier(coordinateSpace: coordinateSpace, onOffsetChanged: onOffsetChanged))
    }
}

fileprivate struct ScrollContentOffsetViewModifier: ViewModifier {
    
    let coordinateSpace: CoordinateSpace
    let onOffsetChanged: (CGPoint) -> Void
    
    func body(content: Content) -> some View {
        content
            .coordinateSpace(name: coordinateSpace)
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: PositionPreferenceKey.self,
                        value: geometry.frame(in: .named(coordinateSpace)).origin
                    )
                }
            )
            .onPreferenceChange(PositionPreferenceKey.self) { position in
                DispatchQueue.main.async {
                    onOffsetChanged(CGPoint(x: position.x, y: -position.y))
                }
            }
    }
}

struct PositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint { .zero }
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
}

#if DEBUG
#Preview {
    StatefulPreviewWrapper(CGSize.zero) { sizeBinding in
        ScrollView {
            LazyVStack {
                ForEach(0..<20, id: \.self) { num in
                    Text(num.description)
                        .padding()
                        .frame(width: 290, height: 70)
                }
            }
            .scrollContentOffset { point in
                if sizeBinding.wrappedValue == .zero {
                    return
                }
                let currentOffset = point.y
                let maximumOffset = sizeBinding.wrappedValue.height - UIScreen.main.bounds.height
                print(currentOffset)
                if maximumOffset - currentOffset <= 50.0 {
                    print("load more")
                }
            }
            .readContentSize { contentSize in
                sizeBinding.wrappedValue = contentSize
                print("Content size " + contentSize.height.description)
            }
        }
    }
}
#endif
