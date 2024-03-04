//
//  ProfileActionHandler.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.09.2023.
//

import Foundation

struct BaseProfileAction {
    var onSelectFollowSection: VoidClosure<FollowSectionType>?
    var onSelectFavoriteProduct: VoidClosure<Product>?
    var onPresentShareLink: VoidClosure<ShareLinkActivityViewController>?
    var onSelectCreatorProfile: VoidClosure<Creator>?
    var onSelectProducts: VoidClosure<ProductSelectableDTO>?
    var onSelectBrand: VoidClosure<Brand>?
    var onRequestAuthentication: NestedCompletionHandler?
    var onSelectShow: VoidClosure<(shows: [Show], selectedShow: Show)>?
}

struct ProfileActionHandler {
    let onShowOrders: () -> Void
    let onShowFavorites: () -> Void
    let onShowPersonalDetails: () -> Void
    let onManageAccount: () -> Void
    let onShowSettings: () -> Void
    let onEditProfile: () -> Void
    let onPresentCart: () -> Void
    
    //MARK: CommonActions
    let onApplyToSell: () -> Void
    let onContactUs: () -> Void
    
    //MARK: GuestActions
    let onStartOnboardingFlow: (OnboardingType) -> Void
    let onSelectFollowSection: () -> Void
    
    let onUploadShow: () -> Void
    let onUpdateBio: () -> Void
    let onUpdateSocialLinks: () -> Void
    let onUploadProfilePicture: () -> Void
    
    #if DEBUG
    static let emptyActions = ProfileActionHandler(
        onShowOrders: {}, onShowFavorites: {}, onShowPersonalDetails: {}, onManageAccount: {}, onShowSettings: {}, onEditProfile: {}, onPresentCart: {}, onApplyToSell: {}, onContactUs: {}, onStartOnboardingFlow: {_ in},
        onSelectFollowSection: {}, onUploadShow: {}, onUpdateBio: {}, onUpdateSocialLinks: {}, onUploadProfilePicture: {})
    #endif
}
