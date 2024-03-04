//
//  DiscoverFeed+Actions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2023.
//

import Foundation

struct DiscoverFeedActionsHandler {
    //Common
    let onPresentCart: () -> Void
    let onSelectProduct: (Product) -> Void
    let onSelectBrand: (Brand) -> Void
    let onSelectCreator: (Creator) -> Void
    let onSelectShow: (_ showsSection: ShowsFeedDiscoverSection) -> Void
    let onSelectExpandedSectionContent: (ExpandedSectionContentType) -> Void
    
    //Creator only
    let onCreateContent: () -> Void
    
    //Shopper only
    let onApplyAsCreator: () -> Void
}

enum ExpandedSectionContentType {
    case brands
    case creators
    case products(DiscoverProductsFeedType)
    case shows(DiscoverShowsFeedType)
    
    var title: String {
        switch self {
        case .shows(let discoverShowsFeedType): return discoverShowsFeedType.title
        case .products(let discoverProductsFeedType): return discoverProductsFeedType.title
        case .creators: return Strings.Discover.shopByCreator
        case .brands: return Strings.Discover.topBrands
        }
    }
}

#if DEBUG
extension DiscoverFeedActionsHandler {
    static let previewActions = DiscoverFeedActionsHandler(
        onPresentCart: {}, onSelectProduct: {_ in}, onSelectBrand: {_ in},
        onSelectCreator: {_ in}, onSelectShow: {_ in}, onSelectExpandedSectionContent: {_ in},
        onCreateContent: { }, onApplyAsCreator: {}
    )
}
#endif
