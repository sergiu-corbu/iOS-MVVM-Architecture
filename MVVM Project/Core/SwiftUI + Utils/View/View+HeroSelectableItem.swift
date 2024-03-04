//
//  View+HeroSelectableItem.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.05.2023.
//

import SwiftUI

extension View {
    
    func heroSelectableItem<Item: Hashable>(
        _ item: Item?,
        @ViewBuilder itemContent: @escaping (Item) -> some View
    ) -> some View {
        
        ZStack {
            self
            if let item {
                itemContent(item)
                    .zIndex(1)
            }
        }
        .animation(.hero, value: item)
    }
}
