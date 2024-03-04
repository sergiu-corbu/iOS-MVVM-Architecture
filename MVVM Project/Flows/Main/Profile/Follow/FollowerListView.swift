//
//  FollowerListView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.08.2023.
//

import SwiftUI

struct FollowerListView: View {

    @ObservedObject var viewModel: FollowerListViewModel
    private var currentUser: User {
        return viewModel.user
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SelectableHeaderSectionView(
                selectedSection: Binding(get: {
                    return viewModel.selectedFollowType.id
                }, set: { newValue in
                    viewModel.selectedFollowType = FollowType(rawValue: newValue) ?? .user
                }), sections: [
                    SectionItem(followType: .user, count: viewModel.followingCounts.users),
                    SectionItem(followType: .brand, count: viewModel.followingCounts.brands)
                ], sectionTitle: viewModel.contentType.name, onBack: {
                    viewModel.followerListActionHandler(.back)
                }
            )
            .padding(.bottom, 8)
            contentView
                .refreshable {
                    viewModel.loadInitialContent(forceRefresh: true)
                }
        }
        .primaryBackground()
        .errorToast(error: $viewModel.backendError)
    }
    
    @ViewBuilder private var contentView: some View {
        switch viewModel.selectedFollowType {
        case .user:
            FollowTypeListView(items: viewModel.usersDataStore.items, followType: viewModel.selectedFollowType) { item in
                let user = item.user
                Button {
                    viewModel.followerListActionHandler(.selectUser(user))
                } label: {
                    CreatorCardDetailView(creator: user, followViewModel: viewModel.viewModel(from: user))
                }
                .buttonStyle(.plain)
                .task {
                    do {
                        try await viewModel.usersDataStore.loadMoreIfNeeded(item)
                    } catch {
                        viewModel.backendError = error
                    }
                }
            }
            .overlayLoadingIndicator(!viewModel.usersDataStore.didLoadFirstPage, scale: 1, shouldDisableInteraction: false)
            .task(priority: .userInitiated) {
                viewModel.loadInitialContent()
            }
            .environment(\.isLoading, viewModel.usersDataStore.loadingSourceType == .new)
        case .brand:
            FollowTypeListView(items: viewModel.brandsDataStore.items, followType: viewModel.selectedFollowType) { item in
                let brand = item.brand
                Button {
                    viewModel.followerListActionHandler(.selectBrand(brand))
                } label: {
                    BrandVView(brand: brand)
                }
                .buttonStyle(.plain)
                .task {
                    do {
                        try await viewModel.brandsDataStore.loadMoreIfNeeded(item)
                    } catch {
                        viewModel.backendError = error
                    }
                }
            }
            .overlayLoadingIndicator(!viewModel.brandsDataStore.didLoadFirstPage, scale: 1, shouldDisableInteraction: false)
            .task(priority: .userInitiated) {
                viewModel.loadInitialContent()
            }
            .environment(\.isLoading, viewModel.brandsDataStore.loadingSourceType == .new)
        }
    }
    
    struct FollowTypeListView<Item: StringIdentifiable & Equatable, ItemView: View>: View {
        
        let items: [Item]
        let followType: FollowType
        @ViewBuilder let itemView: (Item) -> ItemView
        private let gridItem = GridItem(.flexible(), spacing: 12)
        
        @Environment(\.isLoading) var isLoading: Bool
        
        var body: some View {
            let contentView = Group {
                if items.isEmpty {
                    SectionedListPlaceholderView(message: followType.placeholderMessage, image: followType.placeholderImage)
                } else {
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVGrid(columns: Array(repeating: gridItem, count: 2), spacing: 12) {
                            ForEach(items, id: \.id) { item in
                                itemView(item)
                            }
                        }
                        .padding(EdgeInsets(top: 28, leading: 16, bottom: 28, trailing: 16))
                        .animation(.easeInOut, value: items)
                    }
                }
            }
            .transition(.opacity.animation(.easeInOut))
            
            if isLoading {
                Color.clear
            } else {
                contentView
            }
        }
    }
}

fileprivate extension FollowerListView {
    
    struct SectionItem: HeaderSectionCountable {
        let id: String
        let sectionTitle: String
        let count: Int
        
        init(followType: FollowType, count: Int) {
            self.id = followType.id
            self.sectionTitle = followType.sectionTitle.uppercased()
            self.count = count
        }
    }
}

struct LoadingEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {

    var isLoading: Bool {
        get {
            return self[LoadingEnvironmentKey.self]
        }
        set {
            self[LoadingEnvironmentKey.self] = newValue
        }
    }
}

#if DEBUG
struct FollowerList_Previews: PreviewProvider {
    
    static var previews: some View {
        FollowerListPreview()
    }
    
    private struct FollowerListPreview: View {
        @StateObject var viewModel = FollowerListViewModel(user: .customer, contentType: .following, userRepository: MockUserRepository(), followService: MockFollowService(), pushNotificationsPermissionHandler: MockPushNotificationsHandler(), followerListActionHandler: {_ in} )
        
        var body: some View {
            FollowerListView(viewModel: viewModel)
                .onAppear {
                    viewModel.usersDataStore.onLoadPage {_ in
                        return FollowService.FollowingUserDTO.sampleUsers
                    }
                }
        }
    }
}
#endif
