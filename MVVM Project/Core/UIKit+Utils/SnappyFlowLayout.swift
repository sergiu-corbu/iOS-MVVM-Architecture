//
//  SnappyFlowLayout.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.11.2023.
//

import Foundation
import UIKit

class SnappyFlowLayout: UICollectionViewFlowLayout {
    
    init(itemSize: CGSize, spacing: CGFloat) {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = spacing
        self.itemSize = itemSize
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        guard let collectionView else {
            return
        }
        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: .zero, left: horizontalInsets, bottom: .zero, right: horizontalInsets)
        
        super.prepare()
    }
    
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {

        guard let collectionView else {
            return .zero
        }
        let targetRect = CGRect(
            x: proposedContentOffset.x, y: 0,
            width: collectionView.frame.width, height: collectionView.frame.height
        )
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else {
            return .zero
        }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2
        
        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
