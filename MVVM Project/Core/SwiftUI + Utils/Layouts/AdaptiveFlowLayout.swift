//
//  AdaptiveFlowLayout.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.11.2022.
//

import SwiftUI

@available(iOS 16.0, *)
struct AdaptiveFlowLayout: Layout {
    
    var interitemSpacing: CGFloat = 16
    var lineSpacing: CGFloat = 16
    
    // the default proposed size for the layout container
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let proposedWidth = (proposal.width ?? .zero)
        var currentPoint: CGPoint = .zero
        var lineHeight: CGFloat = .zero

        for childSize in sizes {
            if currentPoint.x + childSize.width + interitemSpacing > proposedWidth {
                currentPoint.x = .zero
                currentPoint.y += lineHeight + lineSpacing
                lineHeight = .zero
            }
            lineHeight = max(lineHeight, childSize.height)
            currentPoint.x += childSize.width + interitemSpacing
        }
        
        return CGSize(width: proposedWidth, height: currentPoint.y + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        let maxWidth = bounds.width
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            let idealSubviewWidth = subviewSize.width + interitemSpacing
            
            if origin.x + subviewSize.width > maxWidth + interitemSpacing {
                origin.y += subviewSize.height + lineSpacing
                origin.x = bounds.origin.x
                subview.place(at: origin, proposal: proposal)
                origin.x += idealSubviewWidth
            } else {
                subview.place(at: origin, proposal: proposal)
                origin.x += idealSubviewWidth
            }
        }
    }
}
