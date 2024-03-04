//
//  BaseShowDetailView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.01.2023.
//

import SwiftUI
import AVKit

struct ProductSelectableDTO {
    
    let products: [Product]
    let selectedIndex: Int
    var isRequestingGiftProduct: Bool = false
    
    var selectedProduct: Product {
        return products[selectedIndex]
    }
    var initialSelectedIndex: Int? {
        selectedIndex == 0 ? nil : selectedIndex
    }
    
    //Populated when the products are bound to a show or creator profile
    var creator: Creator?
    //NOTE: `showID` will be nil in case the show is selected from a public profile - favorites section
    var showID: String?
}

extension ProductSelectableDTO {
    
    init(product: Product, creator: Creator? = nil, isRequestingGiftProduct: Bool = false) {
        self.products = [product]
        self.creator = creator
        self.isRequestingGiftProduct = isRequestingGiftProduct
        self.selectedIndex = 0
    }
}

struct BaseShowDetailView<ShowStreamComposableView: View, AdditionalNavigationBarContent: View>: View {
        
    @ObservedObject var viewModel: BaseShowDetailViewModel
    
    let namespaceID: Namespace.ID?
    @ViewBuilder let showStreamComposableLayoutView: ShowStreamComposableView
    @ViewBuilder let additionalNavigationBarContent: AdditionalNavigationBarContent
    
    private var show: Show {
        return viewModel.show
    }
    
    var body: some View {
        VStack(spacing: 16) {
            navigationBarContent
                .zIndex(1)
            if let namespaceID {
                showStreamComposableLayoutView
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .matchedGeometryEffect(id: show.id, in: namespaceID, properties: .frame)
            } else {
                showStreamComposableLayoutView
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .primaryBackground()
        .overlayLoadingIndicator(viewModel.isLoading)
        .errorToast(error: $viewModel.error)
        .successToast(isPresented: $viewModel.showReminderToast, message: Strings.Alerts.remindersSet)
        .animation(.easeInOut, value: viewModel.show)
        .task(priority: .userInitiated) {
            await viewModel.incrementShowViewsCountAndGetLatestShow()
        }
    }
    
    private var navigationBarContent: some View {
        ZStack {
            HStack(spacing: 16) {
                Spacer()
                Buttons.ShareButton(onShare: viewModel.generateShareLink)
                Button {
                    viewModel.handleCloseShowDetailAction()
                } label: {
                    Image(.closeIcon)
                        .renderingMode(.template)
                        .resizedToFill(width: 20, height: 20)
                        .foregroundColor(.ebony)
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, 16)
            
            additionalNavigationBarContent
        }
    }
}

#if DEBUG
struct BaseShowDetailPreview: PreviewProvider {
    
    static func baseViewModel(show: Show) -> BaseShowDetailViewModel {
        return BaseShowDetailViewModel(
            show, showService: MockShowService(), deeplinkProvider: MockDeeplinkProvider(), pushNotificationsPermissionHandler: MockPushNotificationsHandler(), onShowDetailInteraction: {_ in}
        )
    }
    
    static var previews: some View {
        BaseShowDetailView(viewModel: baseViewModel(show: .scheduled), namespaceID: nil, showStreamComposableLayoutView: {
            Color.random
        }, additionalNavigationBarContent: {
            EmptyView()
        })
    }
}
#endif
