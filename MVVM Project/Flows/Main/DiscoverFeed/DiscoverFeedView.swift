//
//  DiscoverFeedView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.11.2023.
//

import SwiftUI

struct DiscoverFeedView: View {
    
    @ObservedObject var viewModel: DiscoverFeedViewModel
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading, spacing: 28) {
                FeaturedShowsView(viewModel: viewModel.featuredShowsViewModel)
                PromotionalBannerView(viewModel: viewModel.promotionalBannerViewModel)
                DiscoverFeedSectionsView(viewModel: viewModel.discoverFeedSectionsViewModel)
            }
        }
        .background(Color.cappuccino)
        .safeAreaInset(edge: .top, spacing: 16, content: headerView)
        .overlay(alignment: .bottomTrailing, content: userShortcutActionButtons)
        .refreshable {
            await Task {
                viewModel.reloadAllContent()
            }.value
        }
        .onAppear(perform: viewModel.onViewAppeared)
    }
}

//MARK: - Views
private extension DiscoverFeedView {
    
    func headerView() -> some View {
        VStack(spacing: 8) {
            NavigationBar()
            DividerView()
        }
        .background(Color.cappuccino)
    }
    
    func userShortcutActionButtons() -> some View {
        VStack(spacing: 8) {
            MinimizedCartView(
                cartManager: viewModel.checkoutCartManager,
                onPresentCart: viewModel.actionsHandler.onPresentCart
            )
            CreateContentShortcutView(
                currentUserPublisher: viewModel.currentUserPublisher,
                onCreateContent: viewModel.actionsHandler.onCreateContent
            )
        }
        .padding([.bottom, .trailing], 8)
    }
}

#if DEBUG
#Preview {
    DiscoverFeedView(viewModel: .mocked)
}
#endif
