//
//  PinterestLayout.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 14.10.2023.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct PinterestLayout: Layout {
    
    var configuration: PinterestLayoutConfiguration = .standard
    var onLayoutSizeChanged: ((CGSize) -> Void)? = nil
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        if cache.layoutItems.count != subviews.count {
            cache.invalidate()
            cache.processLayoutSubviews(subviews)
        }
        let layoutSize = CGSize(width: proposal.width ?? .zero, height: cache.layoutSize.height)
        cache.layoutSize = layoutSize
        return layoutSize
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let cachedSubviews = cache.layoutItems
        let yInset = bounds.origin.y
        
        updateLayoutSize(from: cache)
        
        for subview in cachedSubviews {
            let subviewXLocation = bounds.origin.x + (subview.size.width + configuration.interitemSpacing) * CGFloat(subview.column - 1)
            subviews[safe: subview.index]?.place(
                at: CGPoint(x: subviewXLocation, y: subview.yPosition + yInset),
                proposal: proposal
            )
        }
    }
   
    func makeCache(subviews: Subviews) -> Cache {
        var cache = Cache(configuration: configuration)
        cache.processLayoutSubviews(subviews)
        return cache
    }
    
    private func updateLayoutSize(from cache: Cache) {
        let layoutSize = cache.layoutSize
        DispatchQueue.main.async {
            onLayoutSizeChanged?(layoutSize)
        }
    }
}

extension PinterestLayout {
    
    struct Cache {
        
        let configuration: PinterestLayoutConfiguration
        var layoutSize: CGSize = .zero
        private var columnsOffsetMap: [Int: CGFloat]
        fileprivate private(set) var layoutItems = [LayoutItem]()
        
        private var smallestColumnIndex: Int {
            columnsOffsetMap.sorted(by: {$0.key < $1.key}).min(by: { $0.value < $1.value })?.key ?? 1
        }
                
        init(configuration: PinterestLayoutConfiguration) {
            self.configuration = configuration
            self.columnsOffsetMap = Dictionary(uniqueKeysWithValues: Array(1...configuration.columns).map { ($0, CGFloat.zero) })
        }
        
        mutating func processLayoutSubviews(_ layoutSubviews: Layout.Subviews) {
            for (index, subview) in layoutSubviews.enumerated() {
                let subviewSize = subview.sizeThatFits(.unspecified)
                let column = smallestColumnIndex
                let yPosition = columnsOffsetMap[column] ?? .zero
                
                layoutItems.append(
                    LayoutItem(index: index, column: column, size: subviewSize, yPosition: yPosition)
                )
                columnsOffsetMap.updateValue(yPosition + subviewSize.height + configuration.lineSpacing, forKey: column)
            }
            
            if let maxHeight = columnsOffsetMap.values.max() {
                layoutSize.height = maxHeight
            }
        }
        
        mutating func invalidate() {
            for key in columnsOffsetMap.keys {
                columnsOffsetMap[key] = .zero
            }
            layoutSize = .zero
            layoutItems = []
        }
    }
    
    fileprivate struct LayoutItem: Equatable {
        let index: Int
        let column: Int
        let size: CGSize
        let yPosition: CGFloat
    }
}

struct PinterestLayoutConfiguration {
    
    let columns: Int
    let lineSpacing: CGFloat
    let interitemSpacing: CGFloat
    let loadMoreTreshold: LoadMoreTreshold
    static let scrollContentNamespace = "pinterestScrollContentNamespace"
    
    var columnInteritemSpacing: CGFloat {
        interitemSpacing * CGFloat(columns - 1)
    }
    
    static let standard = PinterestLayoutConfiguration(columns: 2, lineSpacing: 12, interitemSpacing: 12, loadMoreTreshold: .fraction(1/2))
    static let triple = PinterestLayoutConfiguration(columns: 3, lineSpacing: 16, interitemSpacing: 12, loadMoreTreshold: .fraction(1/2))
}

enum LoadMoreTreshold {
    case fraction(Double)
    case constant(Double)
}

extension LoadMoreTreshold {
    
    static func halfPage(viewportHeight: Double) -> Self {
        return .fraction(viewportHeight / 2)
    }
    static func thirdPage(viewportHeight: Double) -> Self {
        return .fraction(viewportHeight / 3)
    }
    static func quarterPage(viewportHeight: Double) -> Self {
        return .fraction(viewportHeight / 4)
    }
    static func fullPage(viewportHeight: Double) -> Self {
        return .fraction(viewportHeight)
    }
}

extension View {
    
    /// Retrieves the scrolling content view's size and updates the value via a Binding
    /// Should be set on the scrolling container, not the whole parent
    func setViewportLayoutSize(_ layoutSize: Binding<CGSize>) -> some View {
        return self.readContentSize { newValue in
            if layoutSize.wrappedValue != newValue {
                layoutSize.wrappedValue = newValue
            }
        }
    }
}
