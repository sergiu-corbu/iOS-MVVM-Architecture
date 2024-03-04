//
//  UICollectionView+CompositionalLayout.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.01.2023.
//

import Foundation
import UIKit

extension UICollectionViewLayout {
    
    static func horizontalCompositionalLayout(
        scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior = .groupPaging,
        groupLayoutSize: NSCollectionLayoutSize,
        interItemSpacing: CGFloat = 16,
        contentInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16),
        onCustomizeLayoutSection: ((NSCollectionLayoutSection) -> Void)? = nil
    ) -> UICollectionViewCompositionalLayout {
        
        let item = NSCollectionLayoutItem(layoutSize: groupLayoutSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupLayoutSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = interItemSpacing
        section.orthogonalScrollingBehavior = scrollingBehaviour
        section.contentInsets = contentInsets
        onCustomizeLayoutSection?(section)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    static func verticalCompositionalLayout(
        scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior = .groupPaging,
        groupLayoutSize: NSCollectionLayoutSize,
        interItemSpacing: CGFloat = 16,
        contentInsets: NSDirectionalEdgeInsets = .zero,
        onCustomizeLayoutSection: ((NSCollectionLayoutSection) -> Void)? = nil
    ) -> UICollectionViewCompositionalLayout {
        
        let item = NSCollectionLayoutItem(layoutSize: groupLayoutSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupLayoutSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = interItemSpacing
        section.orthogonalScrollingBehavior = scrollingBehaviour
        section.contentInsets = contentInsets

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        onCustomizeLayoutSection?(section)
        
        return UICollectionViewCompositionalLayout(section: section, configuration: config)
    }
}
