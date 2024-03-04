//
//  View+SizePreference.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 11.01.2023.
//

import Foundation
import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    
    typealias Value = CGSize
    
    static var defaultValue: CGSize {
        return .zero
    }
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    
    func readContentSize(onContentSizeChanged: @escaping (CGSize) -> Void) -> some View {
        return self.background {
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                    .onPreferenceChange(SizePreferenceKey.self) { newContentSize in
                        DispatchQueue.main.async {
                            onContentSizeChanged(newContentSize)
                        }
                    }
            }
        }
    }
}
