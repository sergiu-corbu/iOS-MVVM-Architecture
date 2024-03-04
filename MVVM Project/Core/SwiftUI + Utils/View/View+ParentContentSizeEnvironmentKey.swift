//
//  View+ParentContentSizeEnvironmentKey.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.12.2023.
//

import SwiftUI

struct ParentContentSizeEnvironmentKey: EnvironmentKey {
    
    static var defaultValue: CGSize = UIApplication.shared.keyWindow?.bounds.size ?? .zero
}

extension EnvironmentValues {
    
    var parentContentSize: CGSize {
        get { return self[ParentContentSizeEnvironmentKey.self] }
        set { self[ParentContentSizeEnvironmentKey.self] = newValue }
    }
}

extension View {
    
    func parentContentSize(_ contentSize: CGSize) -> some View {
        environment(\.parentContentSize, contentSize)
    }
}
