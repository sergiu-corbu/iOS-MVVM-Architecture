//
//  HStackLayout.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.10.2023.
//

import SwiftUI

struct EquallyFilledHStackLayout: Layout {
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxSize = computeMaxSize(subviews: subviews)
        let totalSpacing = computeSpacings(subviews: subviews).reduce(0) { $0 + $1 }
        return CGSize(width: maxSize.width * CGFloat(subviews.count) + totalSpacing, height: maxSize.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let maxSize = computeMaxSize(subviews: subviews)
        let spacings = computeSpacings(subviews: subviews)
        
        let sizeProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
        var x = bounds.minX + maxSize.width / 2
        
        for index in subviews.indices {
            subviews[index].place(at: CGPoint(x: x, y: bounds.midY), anchor: .center, proposal: sizeProposal)
            x += maxSize.width + spacings[index]
        }
    }
    
    private func computeMaxSize(subviews: Subviews) -> CGSize {
        let subviewsSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxSize: CGSize = subviewsSizes.reduce(.zero) { partialResult, subviewSize in
            CGSize(width: max(partialResult.width, subviewSize.width),
                   height: max(partialResult.height, subviewSize.height)
            )
        }
        return maxSize
    }
    
    func computeSpacings(subviews: Subviews) -> [CGFloat] {
        let spacing = subviews.indices.map { index in
            guard index < subviews.count - 1 else { return CGFloat.zero }
            return subviews[index].spacing.distance(to: subviews[index + 1].spacing, along: .horizontal)
        }
        return spacing
    }
}

struct EquallyDistributedHStackLayout: Layout {
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxSize = computeMaxSize(subviews: subviews)
        
        return CGSize(
            width: proposal.width ?? maxSize.width * CGFloat(subviews.count),
            height: maxSize.height
        )
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let maxSize = computeMaxSize(subviews: subviews)
        let subviewsCount = CGFloat(subviews.count)
        
        let interItemSpacing = (bounds.width - (maxSize.width * subviewsCount)) / (subviewsCount - 1)
        let sizeProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
        var x = bounds.minX + maxSize.width / 2
        
        for index in subviews.indices {
            subviews[index].place(at: CGPoint(x: x, y: bounds.midY), anchor: .center, proposal: sizeProposal)
            x += maxSize.width + interItemSpacing
        }
    }
    
    private func computeMaxSize(subviews: Subviews) -> CGSize {
        let subviewsSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxSize: CGSize = subviewsSizes.reduce(.zero) { partialResult, subviewSize in
            CGSize(width: max(partialResult.width, subviewSize.width),
                   height: max(partialResult.height, subviewSize.height)
            )
        }
        return maxSize
    }
}


#if DEBUG
struct HStackLayout_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(spacing: 24 ) {
            let content = Group {
                Text("Apples")
                    .frame(maxWidth: .infinity)
                Text("Strawberries")
                    .frame(maxWidth: .infinity)
                Text("Mango")
                    .frame(maxWidth: .infinity)
            }.border(Color.yellow, width: 2)
            
            EquallyFilledHStackLayout {
                content
            }
            .border(Color.random)
            EquallyDistributedHStackLayout {
                content
            }
            .border(Color.random)
            HStack {
                content
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
