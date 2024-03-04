//
//  PaginatedFeedView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.01.2023.
//

import SwiftUI

struct PaginatedFeedView<Item: Hashable & Identifiable, ItemView: View>: View where Item.ID == String {
    
    let items: Array<Item>
    @ViewBuilder var itemView: (Item) -> ItemView
    var onLoadMore: (Item.ID) -> Void
    
    var body: some View {
        ForEach(items.indexEnumeratedArray, id: \.offset) { (index, item) in
            itemView(item)
                .onAppear {
                    if index == items.count - 1 {
                        onLoadMore(item.id)
                    }
                }
        }
    }
}
