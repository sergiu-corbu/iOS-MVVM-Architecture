//
//  BrandProfileViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.05.2023.
//

import Foundation

class BrandProfileViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published private(set) var brand: Brand
    @Published var selectedSection: ProfileSectionType
    @Published var isLoading = false
    @Published var error: Error?
    
    let followViewModel: FollowViewModel
    lazy var showsGridViewModel: ProfileComponents.ShowsGridViewModel = {
        let showsVM = ProfileComponents.ShowsGridViewModel(
            ownerID: brand.id ?? "", type: .brand,
            showService: showService, accessLevel: .readOnly,
            actionHandler: ProfileShowsGridAction(onSelectShow: { [weak self] selectedShow in
                self?.showSelectionHandler(self?.showsGridViewModel.shows ?? [], selectedShow)
            }, onErrorReceived: { [weak self] error in
                self?.error = error
            })
        )
        showsVM.showsPlaceholderMessage = Strings.Placeholders.guestShows(owner: ProfileType.brand.rawValue)
        return showsVM
    }()
    lazy var productsGridViewModel: ProfileComponents.ProductsGridViewModel = {
        let favoriteVM = ProfileComponents.ProductsGridViewModel(
            ownerID: brand.id ?? "", type: .brand,
            favoriteProductsProvider: FavoriteProductsProvider(brandService: brandService, creatorService: nil), accessLevel: .readOnly
        )
        favoriteVM.onErrorReceived = { [weak self] error in
            self?.error = error
        }
        favoriteVM.placeholderMessage = Strings.Placeholders.guestFavorites(owner: ProfileType.brand.rawValue)
        return favoriteVM
    }()
    
    //MARK: - Services
    let brandService: BrandServiceProtocol
    let showService: ShowRepositoryProtocol
    let showStreamBuilder: ShowVideoStreamBuilder
    let deeplinkProvider: DeeplinkProvider
    lazy private var shareableProvider = ShareableProvider(deeplinkProvider: deeplinkProvider, onPresentShareLink: { [weak self] shareVC in
        self?.brandProfileActionHandler(.shareLink(shareVC))
    })

    
    //MARK: - Actions
    let brandProfileActionHandler: (BrandProfileAction) -> Void
    let showDetailInteractionHandler: ShowDetailInteraction
    let showSelectionHandler: (_ showArray: [Show], _ selectedShow: Show) -> Void
    
    init(brand: Brand, preselectedSection: ProfileSectionType = .products, brandService: BrandServiceProtocol, deeplinkProvider: DeeplinkProvider, showStreamBuilder: ShowVideoStreamBuilder,
         brandProfileActionHandler: @escaping (BrandProfileAction) -> Void, showDetailInteractionHandler: @escaping ShowDetailInteraction, showSelectionHandler: @escaping (_ showArray: [Show], _ selectedShow: Show) -> Void) {
        self.brand = brand
        self.selectedSection = preselectedSection
        self.brandService = brandService
        self.showService = showStreamBuilder.showRepository
        self.showStreamBuilder = showStreamBuilder
        self.brandProfileActionHandler = brandProfileActionHandler
        self.showDetailInteractionHandler = showDetailInteractionHandler
        self.deeplinkProvider = deeplinkProvider
        self.showSelectionHandler = showSelectionHandler        
        self.followViewModel = FollowViewModel(
            followingID: brand.id ?? "", followType: .brand,
            userRepository: showStreamBuilder.userRepository, followService: showStreamBuilder.followService,
            pushNotificationsPermissionHandler: showStreamBuilder.pushNotificationsHandler,
            onRequestAuthentication: { completion in
                brandProfileActionHandler(.requestSignIn(completion))
            }
        )
        
        Task(priority: .userInitiated) {
            await getBrandData()
        }
    }
    
    @MainActor
    func getBrandData() async {
        guard let brandID = brand.id else {
            return
        }
        isLoading = true
        
        do {
            if let brand = try await brandService.getBrand(id: brandID) {
                self.brand = brand
            }
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func reloadCollaborationsDataIfNeeded() {
        guard selectedSection == .shows else {
            return
        }
        
        Task(priority: .userInitiated) {
            await showsGridViewModel.loadShows()
        }
    }
    
    func handleFollowBrandAction() {
        followViewModel.handleFollowAction(completionHandler: { [weak self] in
            guard let self else { return }
            let currentFollowersCount = self.brand.followerCount ?? 0
            if self.followViewModel.isFollowing {
                self.brand.followerCount = currentFollowersCount + 1
            } else {
                self.brand.followerCount = max(0, currentFollowersCount - 1)
            }
        })
    }
    
    func handleShowDetailInteraction(_ interaction: ShowDetailInteractionType) {
        if case .close(let shouldProcessLiveStreamEnded) = interaction {
            if shouldProcessLiveStreamEnded {
                Task(priority: .userInitiated) { @MainActor in
                    await showsGridViewModel.loadShows(sourceType: .new)
                }
            }
        } else {
            showDetailInteractionHandler(interaction)
        }
    }
    
    func generateShareLink() {
        guard let shareable = brand.shareableObject else {
            return
        }
        shareableProvider.generateShareURL(shareable)
    }
}
