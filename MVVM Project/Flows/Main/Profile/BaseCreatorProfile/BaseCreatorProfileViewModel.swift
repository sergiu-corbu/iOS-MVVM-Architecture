//
//  BaseCreatorProfileViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.02.2023.
//

import Foundation
import UIKit
import SwiftUI

class BaseCreatorProfileViewModel: ObservableObject {
    
    //MARK: Properties
    @Published var selectedSection: ProfileSectionType = .products
    @Published var localProfileImage: UIImage?
    @Published var isLoading = false
    @Published var creator: Creator
    @Published var error: Error?
    
    private(set) lazy var creatorShowsViewModel: CreatorShowsViewModel = {
        let showsViewModel = CreatorShowsViewModel(ownerID: creator.id, type: .user, showService: showService, accessLevel: creatorAccessLevel, actionHandler: ProfileShowsGridAction(
            onSelectShow: { [weak self] selectedShow in
                self?.handleShowSelection(selectedShow)
            }, onCreateShow: { [weak self] in
                self?.handleCreatorAction {
                    self?.creatorProfileAction?.onUploadShow()
                }
            }, onErrorReceived: { [weak self] error in
                self?.error = error
            })
        )
        return showsViewModel
    }()
    
    private(set) lazy var productsGridViewModel: ProfileComponents.ProductsGridViewModel = {
        let favoriteProductsVM = ProfileComponents.ProductsGridViewModel(
            ownerID: creator.id, type: .user,
            favoriteProductsProvider: FavoriteProductsProvider(brandService: nil, creatorService: creatorService), accessLevel: creatorAccessLevel
        )
        favoriteProductsVM.onErrorReceived = { [weak self] error in
            self?.error = error
        }
        return favoriteProductsVM
    }()
    let creatorAccessLevel: ProfileAccessLevel
    
    //MARK: Actions
    var baseProfileAction = BaseProfileAction()
    let creatorProfileAction: ProfileActionHandler?
    
    //MARK: Services
    let showService: ShowRepositoryProtocol
    let creatorService: CreatorServiceProtocol
    let analyticsService: AnalyticsServiceProtocol
    
    init(creator: Creator, creatorAccessLevel: ProfileAccessLevel,
         showService: ShowRepositoryProtocol, creatorService: CreatorServiceProtocol,
         analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared, creatorProfileAction: ProfileActionHandler?) {
        
        self.creator = creator
        self.creatorAccessLevel = creatorAccessLevel
        self.showService = showService
        self.creatorService = creatorService
        self.analyticsService = analyticsService
        self.creatorProfileAction = creatorProfileAction
    }

    //MARK: Computed
    var creatorHasImage: Bool {
        return creator.profilePictureUrl != nil
    }
    var headerViewconfiguration: UserHeaderInformationView.Configuration {
        UserHeaderInformationView.Configuration(
            primaryColor: creatorHasImage || creatorAccessLevel == .readOnly ? .white : .brownJet,
            secondaryColor: creatorHasImage ? .white : .ebony,
            tint: creatorHasImage ? .midGrey : .middleGrey
        )
    }
    
    //MARK: Actions
    func presentShareLink(_ shareLinkVC: ShareLinkActivityViewController) {
        //Analytics..
        baseProfileAction.onPresentShareLink?(shareLinkVC)
    }
    
    func reloadShowsSectionDataIfNeeded() {
        guard selectedSection == .shows else {
            return
        }
            
        Task(priority: .userInitiated) {
            await creatorShowsViewModel.loadShows()
        }
    }
    
    func handleFavoriteProductSelected(_ product: Product) {
        baseProfileAction.onSelectFavoriteProduct?(product)
    }
    
    func handleShowSelection(_ show: Show?) {
        guard let show else {
            return
        }
        baseProfileAction.onSelectShow?((creatorShowsViewModel.shows, show))
    }
    
    func handleCreatorAction(_ action: @escaping () -> Void) {
        guard creatorAccessLevel == .readWrite else {
            return
        }
        action()
    }
}

enum ProfileSectionType: Int, CaseIterable {
    
    case products
    case shows
    case about
    
    static let tabIndicatorID: String = "profileSelectedTabIndicator"
    
    func title(for profileType: ProfileType = .user) -> String {
        switch self {
        case .products: return profileType == .user ? Strings.Profile.myStore : Strings.Profile.products
        case .shows: return Strings.Profile.shows
        case .about: return Strings.Profile.about
        }
    }
}

enum ProfileAccessLevel {
    case readOnly
    case readWrite
}
