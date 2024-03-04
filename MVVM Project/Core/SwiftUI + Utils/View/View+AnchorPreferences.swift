//
//  View+AnchorPreferences.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.11.2022.
//

import Foundation
import SwiftUI

struct AnchorPreferenceKey: PreferenceKey {
    
    typealias Value = Anchor<CGRect>?
    
    static var defaultValue: Value = nil
    
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

struct FramePreferenceKey: PreferenceKey {
    
    static var defaultValue: ProxyFrame = ProxyFrame()
    
    static func reduce(value: inout ProxyFrame, nextValue: () -> ProxyFrame) {
        value = nextValue()
    }
}

struct ProxyFrame: Equatable {
    
    let verticalOffset: CGFloat
    let horizontalOffset: CGFloat
    let size: CGSize
}

extension ProxyFrame {
    
    init(proxy: GeometryProxy, coordinateSpace: CoordinateSpace) {
        let frame = proxy.frame(in: coordinateSpace)
        self.verticalOffset = frame.minY
        self.horizontalOffset = frame.minX
        self.size = frame.size
    }
    
    init() {
        self.verticalOffset = .zero
        self.horizontalOffset = .zero
        self.size = .zero
    }
}

extension View {
    
    func contentOffsetChanged(coordinateSpace: CoordinateSpace = .global,
                              _ onOffsetChanged: @escaping (ProxyFrame) -> Void) -> some View {
        background(content: {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: FramePreferenceKey.self, value: ProxyFrame(proxy: proxy, coordinateSpace: coordinateSpace))
                    .onPreferenceChange(FramePreferenceKey.self, perform: { frame in
                        DispatchQueue.main.async {
                            onOffsetChanged(frame)
                        }
                    })
            }
        })
    }
}
