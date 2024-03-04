//
//  BrandProfileView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.05.2023.
//

import SwiftUI

struct BrandProfileView: View {
        
    @ObservedObject var viewModel: BrandProfileViewModel
    
    var spacing: CGFloat = 16
    
    @State private var showMinimizedProfile = false
    @Namespace private var brandProfileNamespace
    
    //Constants
    private let headerSectionID = "profileHeaderSectionID"
    private let navBarHeight: CGFloat = 28
    private let primaryButtonHeight: CGFloat = 52
    
    private var brand: Brand {
        return viewModel.brand
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            contentView
            ProfileComponents.NavigationBar(
                isMinimized: showMinimizedProfile,
                username: brand.name, imageURL: brand.logoPictureURL,
                addionalNavigationBarContent: navigationBarContent
            )
        }
        .overlayLoadingIndicator(viewModel.isLoading, tint: .cultured, scale: 1)
        .errorToast(error: $viewModel.error)
    }
     
    private var contentView: some View {
        ProfileComponents.ProfileHeaderView { availableSize in
            ScrollViewReader { scrollViewProxy in
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    brandProfileContent(availableSize: availableSize)
                        .id(headerSectionID)
                    ProfileComponents.ProfileSections(
                        selectedSection: $viewModel.selectedSection, profileType: .brand,
                        isMinimizedState: showMinimizedProfile, namespace: brandProfileNamespace,
                        sectionContent: {
                            VStack(alignment: .leading, spacing: 16) {
                                brandSectionsContent
                            }
                        }, onContentOffsetChanged: { proxyFrame in
                            updateMinimizedStateIfNeeded(proxyFrame.verticalOffset)
                        }
                    )
                }
                .onReceive(viewModel.$selectedSection) { _ in
                    scrollViewProxy.scrollTo(headerSectionID, delay: 0.1, animation: .easeOut(duration: 0.5))
                    viewModel.reloadCollaborationsDataIfNeeded()
                }
            }
        }
    }
    
    //MARK: - Navigation bar
    private func navigationBarContent() -> some View {
        ZStack {
            Buttons.BackButton(action: {
                viewModel.brandProfileActionHandler(.back)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            Buttons.ShareButton(tint: .white, onShare: viewModel.generateShareLink)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    //MARK: - Brand content
    private func brandProfileContent(availableSize: CGSize) -> some View {
        ZStack(alignment: .bottomLeading) {
            ProfileComponents.ProfileImageView(
                imageURL: brand.coverPictureURL,
                placeholderString: Strings.Profile.brand,
                availableSize: availableSize
            )
            VStack(alignment: .leading, spacing: 16) {
                BrandAvatarView(name: brand.name, imageURL: brand.logoPictureURL, followers: brand.followerCount ?? 0)
                FollowButton(viewModel: viewModel)
            }
            .animation(.easeInOut, value: brand)
        }
    }
    
    @ViewBuilder private var brandSectionsContent: some View {
        switch viewModel.selectedSection {
        case .about:
            ProfileComponents.BioSectionView(bio: brand.description, isEditable: false)
            ProfileComponents.LocationSectionView(location: brand.location)
        case .products:
            ProfileComponents.ProductsGridView(
                viewModel: viewModel.productsGridViewModel,
                onProductSelected: {
                    viewModel.brandProfileActionHandler(.selectProduct($0))
                }
            )
        case .shows:
            ProfileComponents.ShowsGridView(viewModel: viewModel.showsGridViewModel)
        }
    }
    
    //MARK: - Minimized header
    private func updateMinimizedStateIfNeeded(_ verticalOffset: CGFloat) {
        let newValue = verticalOffset <= 28 + safeAreaInsets.top
        if newValue != showMinimizedProfile {
            showMinimizedProfile = newValue
        }
    }
    
    struct FollowButton: View {
        
        @ObservedObject var viewModel: BrandProfileViewModel
        
        var isFollowingBrand: Bool {
            return viewModel.followViewModel.isFollowing
        }
        
        var body: some View {
            FollowContainerView(followViewModel: viewModel.followViewModel, content: {
                Buttons.FilledRoundedButton(
                    title: viewModel.followViewModel.followState.labelString,
                    isLoading: viewModel.followViewModel.isLoading,
                    fillColor: .white.opacity(isFollowingBrand ? 0.1 : 1),
                    tint: isFollowingBrand ? .paleSilver : .jet,
                    action: viewModel.handleFollowBrandAction
                )
            })
        }
    }
}

#if DEBUG
struct BrandProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        BrandProfileView(viewModel: BrandProfileViewModel(
            brand: .armani, brandService: MockBrandService(), deeplinkProvider: MockDeeplinkProvider(), showStreamBuilder: .mockedBuilder,
            brandProfileActionHandler: { _ in}, showDetailInteractionHandler: { _ in }, showSelectionHandler: { _, _ in })
        )
    }
}
#endif
