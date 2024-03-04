//
//  PinterestGridView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 11.01.2023.
//

import Foundation
import SwiftUI

struct PinterestGridView<CellContent: View, GridItem: StringIdentifiable & Equatable>: View {
    
    let gridItems: Array<GridItem>
    let viewportSize: CGSize
    var configuration: PinterestLayoutConfiguration = .standard
    @ViewBuilder let cellContent: (GridItem) -> CellContent
    var onReachedLastPage: ((GridItem) -> Void)? = nil
    
    //Internal
    @State private var layoutSize: CGSize?
    
    var body: some View {
        let cellWidth = (viewportSize.width - configuration.columnInteritemSpacing) / CGFloat(configuration.columns)
        let layoutContent = PinterestLayout(configuration: configuration, onLayoutSizeChanged: { layoutSize = $0 }) {
            ForEach(gridItems) { gridItem in
                cellContent(gridItem)
                    .frame(width: abs(cellWidth))
            }
        }
        .animation(.snappy, value: gridItems)
        
        if onReachedLastPage != nil {
            layoutContent
                .scrollContentOffset(coordinateSpace: .named(PinterestLayoutConfiguration.scrollContentNamespace)) {
                    handleContentOffsetChanged($0)
                }
        } else {
            layoutContent
        }
    }
    
    private func handleContentOffsetChanged(_ contentOffset: CGPoint) {
        guard let layoutSize, let lastItem = gridItems.last else {
            return
        }
        
        let maxVisibileY = layoutSize.height - viewportSize.height - contentOffset.y
        let tresholdY: CGFloat
        switch configuration.loadMoreTreshold {
        case .fraction(let fraction):
            tresholdY = viewportSize.height * fraction
        case .constant(let constant): 
            tresholdY = constant
        }
        
        if maxVisibileY <= tresholdY + viewportSize.height {
            onReachedLastPage?(lastItem)
        }
    }
}

#if DEBUG
#Preview {
    StatefulPreviewWrapper(Array(0..<30)) { data in
        GeometryReader { proxy in
            ScrollView {
                PinterestGridView(
                    gridItems: data.wrappedValue,
                    viewportSize: CGSize(width: proxy.size.width - 24, height: proxy.size.height),
                    cellContent: { index in
                        Rectangle()
                            .fill(Color.random)
                            .frame(height: CGFloat.random(in: 50..<200))
                            .overlay(Text(index.description).bold())
                    }, onReachedLastPage: { lastIndex in
                        data.wrappedValue.append(contentsOf: Array(lastIndex + 1 ..< lastIndex + 1 + 15))
                    }
                ).padding()
            }
        }
    }
}
#endif
