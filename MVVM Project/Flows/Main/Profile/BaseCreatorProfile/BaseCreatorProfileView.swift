//
//  BaseCreatorProfileView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.02.2023.
//

import SwiftUI

struct BaseCreatorProfileView<NavBarView: View, ProfileContent: View>: View {
    
    @ObservedObject var viewModel: BaseCreatorProfileViewModel

    let showVideoStreamBuilder: ShowVideoStreamBuilder
    let accessLevel: ProfileAccessLevel
    var spacing: CGFloat = 16
    @ViewBuilder let navigationBarView: NavBarView
    @ViewBuilder let profileContentView: ProfileContent
    
    @State private var showMinimizedProfile = false
    @Namespace private var creatorProfileNamespace
    
    private let headerSectionID = "creatorProfileHeaderSectionID"
    private let navBarHeight: CGFloat = 28
    private let primaryButtonHeight: CGFloat = 52
    
    var body: some View {
        ZStack(alignment: .top) {
            contentView
            ProfileComponents.NavigationBar(
                isMinimized: showMinimizedProfile,
                username: viewModel.creator.username,
                imageURL: viewModel.creator.profilePictureUrl,
                addionalNavigationBarContent: {
                    navigationBarView
                })
        }
        .overlayLoadingIndicator(viewModel.isLoading, tint: .cultured, scale: 1)
        .errorToast(error: $viewModel.error)
    }
    
    private var contentView: some View {
        ProfileComponents.ProfileHeaderView { availableSize in
            ScrollViewReader { scrollViewProxy in
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    profileSectionView(in: availableSize)
                        .id(headerSectionID)
                    ProfileComponents.ProfileSections(
                        selectedSection: $viewModel.selectedSection, profileType: .user,
                        isMinimizedState: showMinimizedProfile, namespace: creatorProfileNamespace,
                        sectionContent: {
                            ZStack {
                                Color.cultured
                                profileSectionsContent
                            }
                        }, onContentOffsetChanged: { proxyFrame in
                            updateMinimizedStateIfNeeded(proxyFrame.verticalOffset)
                        }
                    )
                }
                .onReceive(viewModel.$selectedSection) { _ in
                    scrollViewProxy.scrollTo(headerSectionID, delay: 0.1, animation: .easeOut(duration: 0.5))
                    viewModel.reloadShowsSectionDataIfNeeded()
                }
            }
        }
    }
}

//MARK: ProfileImage
private extension BaseCreatorProfileView {
    
    func profileSectionView(in size: CGSize) -> some View {
        ZStack(alignment: .bottom) {
            let creator = viewModel.creator
            ProfileComponents.ProfileImageView(
                imageURL: creator.profilePictureUrl,
                localImage: viewModel.localProfileImage,
                isEditable: accessLevel == .readWrite,
                placeholderString: Strings.Profile.creator,
                availableSize: size, onUploadImage: {
                    viewModel.creatorProfileAction?.onUploadProfilePicture()
                }
            )
            VStack(spacing: 16) {
                UserHeaderInformationView(
                    user: viewModel.creator,
                    configuration: viewModel.headerViewconfiguration,
                    accessLevel: accessLevel,
                    onSelectSection: { section in
                        viewModel.baseProfileAction.onSelectFollowSection?(section)
                    }
                )
                profileContentView
            }
        }
    }
}

//MARK: Profile Sections
private extension BaseCreatorProfileView {
    
    var profileSectionsContent: some View {
        Group {
            switch viewModel.selectedSection {
            case .about:
                let creator = viewModel.creator
                ProfileComponents.AboutSectionContainer(
                    bio: creator.bio,
                    brands: creator.partnershipBrands,
                    socialLinks: creator.socialNetworks,
                    isEditable: viewModel.creatorAccessLevel == .readWrite,
                    actionHandler: { action in
                        switch action {
                        case .updateBio:
                            viewModel.handleCreatorAction {
                                viewModel.creatorProfileAction?.onUpdateBio()
                            }
                        case .selectBrand(let brand):
                            viewModel.baseProfileAction.onSelectBrand?(brand)
                        case .updateSocialLinks:
                            viewModel.handleCreatorAction {
                                viewModel.creatorProfileAction?.onUpdateSocialLinks()
                            }
                        }
                    }
                )
            case .shows:
                ProfileComponents.ShowsGridView(viewModel: viewModel.creatorShowsViewModel)
            case .products:
                ProfileComponents.ProductsGridView(
                    viewModel: viewModel.productsGridViewModel,
                    onProductSelected: {
                        viewModel.handleFavoriteProductSelected($0)
                    }
                )
            }
        }
        .transition(.opacity)
    }
}

//MARK: - Minimized header
private extension BaseCreatorProfileView {
    
    func updateMinimizedStateIfNeeded(_ verticalOffset: CGFloat) {
        let newValue = verticalOffset <= navBarHeight + safeAreaInsets.top
        if newValue != showMinimizedProfile {
            showMinimizedProfile = newValue
        }
    }
}

#if DEBUG
struct BaseCreatorProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        BaseCreatorProfilePreview(accessLevel: .readWrite)
            .previewDisplayName("Private profile")
        BaseCreatorProfilePreview(accessLevel: .readOnly)
            .previewDisplayName("Public profile")
    }
    
    private struct BaseCreatorProfilePreview: View {
        
        @StateObject var viewModel: BaseCreatorProfileViewModel
        
        init(accessLevel: ProfileAccessLevel) {
            let viewModel = BaseCreatorProfileViewModel(creator: User.creator, creatorAccessLevel: accessLevel, showService: MockShowService(), creatorService: MockCreatorService(), analyticsService: MockAnalyticsService(), creatorProfileAction: .emptyActions)
            self._viewModel = StateObject(wrappedValue: viewModel)
        }
        
        var body: some View {
            BaseCreatorProfileView(viewModel: viewModel, showVideoStreamBuilder: .mockedBuilder, accessLevel: .readWrite, navigationBarView: {
                
            }, profileContentView: {
                Buttons.FilledRoundedButton(title: "Some Action", fillColor: .white.opacity(0.1), action: {})
            })
        }
    }
}
#endif
