//
//  ShowsGridView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.06.2023.
//

import SwiftUI
import Combine

extension ProfileComponents {
    
    struct ShowsGridView: View {
        
        @ObservedObject var viewModel: ShowsGridViewModel
        
        private let gridItem = GridItem(.flexible(), spacing: 12, alignment: .top)
        
        var body: some View {
            Group {
                if viewModel.showPlaceholderView {
                    ProfileComponents.SectionPlaceholderView(
                        image: .mediaPlayerIcon, accessLevel: viewModel.accessLevel,
                        text: viewModel.showsPlaceholderMessage,
                        action: viewModel.handlePlacehoderAction
                    )
                } else {
                    showsGridView
                }
            }
            .animation(.easeInOut, value: viewModel.shows)
            .transition(.opacity.animation(.easeInOut))
            .task(priority: .userInitiated) {
                if viewModel.isInitialLoad {
                    await viewModel.loadShows()
                }
            }
        }
        
        private var showsGridView: some View {
            LazyVGrid(columns: Array(repeating: gridItem, count: 2), spacing: 16) {
                PaginatedFeedView(items: viewModel.shows, itemView: { show in
                    Button {
                        if show.isProcessingVideo { return }
                        viewModel.actionHandler?.onSelectShow(show)
                    } label: {
                        ProfileComponents.ShowCardView(show: show, profileType: viewModel.type, creatorCanStartLiveStream: viewModel.accessLevel == .readWrite)
                    }
                    .buttonStyle(.plain)
                }, onLoadMore: { lastShowID in
                    viewModel.loadMoreShowsIfNeeded(lastShowID)
                })
            }
            .padding(16)
            .overlayLoadingIndicator(viewModel.isLoading, alignment: viewModel.isFirstLoad ? .center : .bottom, shouldDisableInteraction: false)
        }
    }
    
    struct ShowCardView: View {
        
        let show: Show
        var profileType: ProfileType = .user
        var creatorCanStartLiveStream: Bool = false
        var cardHeight: CGFloat = 356
        
        private var scheduledShowLabel: String {
            if case .liveStream = show.type, creatorCanStartLiveStream {
                return Strings.Buttons.goLive
            } else {
                return Strings.Profile.scheduledShow
            }
        }
        
        var body: some View {
            VStack(spacing: 10) {
                showThumbnailWithFeaturedProducts
                    .overlay(content: supplementaryShowHiglightView)
                    .animation(.easeInOut, value: show.status)
                showInformationView
            }
            .padding(.bottom, 8)
            .frame(maxHeight: cardHeight, alignment: .top)
            .background(Color.cultured)
            .cornerRadius(6)
            .roundedBorder(show.status == .live ? Color.orangish : Color.midGrey, cornerRadius: 6)
        }
        
        private var showThumbnailWithFeaturedProducts: some View {
            GeometryReader { proxy in
                let availableWidth = proxy.size.width
                ZStack(alignment: .bottom) {
                    AsyncImageView(
                        imageURL: show.thumbnailUrl,
                        cancelOnDisappear: true,
                        placeholder: {
                            ZStack {
                                Color.cappuccino.cornerRadius(6)
                                Image(.mediaPlayerIcon)
                                    .renderingMode(.template)
                                    .foregroundColor(.paleSilver)
                            }
                        }
                    )
                    .aspectRatio(contentMode: .fill)
                    .frame(width: availableWidth, height: proxy.size.height)
                    .clipped(antialiased: true)
                    if let products = show.featuredProducts {
                        let cellWidth = (availableWidth - 12) / 4
                        featuredProductsContainerView(products, cellWidth: abs(cellWidth))
                    }
                }
            }
            .frame(height: cardHeight * 0.7)
        }
        
        private func featuredProductsContainerView(_ featuredProducts: [Product], cellWidth: CGFloat) -> some View {
            ZStack(alignment: .leading) {
                Color.lightGrey
                HStack(spacing: 0) {
                    ForEach(featuredProducts.prefix(3), id: \.id) { product in
                        AsyncImageView(imageURL: product.primaryMediaImageURL, cancelOnDisappear: true, placeholder: {
                            Image(.fashionIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.horizontal, 8)
                        })
                        .downsampled(targetSize: CGSize(width: cellWidth, height: 44))
                        .scaledToFit()
                        .frame(width: cellWidth)
                    }
                    let remainingProducts = featuredProducts.count - 3
                    if remainingProducts > 0 {
                        Text("+\(remainingProducts)")
                            .font(kernedFont: .Secondary.p1BoldKerned)
                            .foregroundColor(.darkGreen)
                            .lineLimit(1)
                            .frame(width: cellWidth)
                    }
                }
            }
            .cornerRadius(6)
            .frame(height: 44)
            .padding(6)
        }
        
        private var showInformationView: some View {
            VStack(alignment: .leading, spacing: 10) {
//                FollowingUserWrapperView(userID: show.creatorID) {
//                    Label {
//                        Text(show.views, format: .number.notation(.compactName))
//                            .font(kernedFont: .Secondary.p3RegularKerned)
//                            .foregroundColor(.ebony)
//                    } icon: {
//                        Image(.eye)
//                            .renderingMode(.template)
//                            .foregroundColor(.paleSilver)
//                    }
//                }
                if profileType == .brand, let creatorUsername = show.creator?.formattedUsername {
                    Text(creatorUsername)
                        .font(kernedFont: .Secondary.p4RegularKerned)
                        .foregroundColor(.ebony)
                        .lineLimit(1)
                }
                Text(show.title ?? "N/A")
                    .font(kernedFont: .Main.p1RegularKerned)
                    .foregroundColor(.jet)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
        }
        
        /// - Note: to be used as overlay
        @ViewBuilder private func supplementaryShowHiglightView() -> some View {
            switch show.status {
            case .live:
                FadedLiveStreamIndicatorView()
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            case .scheduled:
                VStack(spacing: 0) {
                    Text(scheduledShowLabel.uppercased())
                        .font(kernedFont: .Secondary.p3BoldKerned)
                    if let scheduledDate = show.publishingDate {
                        Text(scheduledDate.dateString(formatType: .compactDateAndTime))
                            .font(kernedFont: .Secondary.p3BoldKerned)
                    }
                }
                .foregroundColor(.orangish)
                .showAdditionalTagView(isDisabled: show.isProcessingVideo)
            case .compressingVideo:
                ProcessingVideoDetailView(showStatus: .compressingVideo)
                    .showAdditionalTagView(isDisabled: show.isProcessingVideo)
            case .uploadingVideo:
                ProcessingVideoDetailView(showStatus: .uploadingVideo)
                    .showAdditionalTagView(isDisabled: show.isProcessingVideo)
            case .convertingVideo:
                VStack(spacing: 4) {
                    Text(Strings.ContentCreation.videoIsProcessing.uppercased())
                        .font(kernedFont: .Secondary.p3BoldExtraKerned)
                        .minimumScaleFactor(0.9)
                        .lineLimit(3)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.paleSilver)
                        .frame(width: 20, height: 1)
                    Text(Strings.ContentCreation.videoIsProcessingDescription)
                        .font(kernedFont: .Secondary.p4MediumKerned)
                }
                .foregroundColor(.ebony)
                .multilineTextAlignment(.center)
                .showAdditionalTagView(isDisabled: show.isProcessingVideo)
            default: EmptyView()
            }
        }
        
        struct ProcessingVideoDetailView: View, Animatable {
            
            let showStatus: ShowStatus
            
            var animatableData: Int {
                get { return progressValue }
                set { progressValue = newValue }
            }
            
            //Internal
            @EnvironmentObject private var videoProcessingContainer: VideoUploadProgressContainer
            @State private var progressValue: Int = 0
            private var progressPublisher: AnyPublisher<Int, Never>? {
                return videoProcessingContainer.progressPublishers[showStatus]?.eraseToAnyPublisher()
            }
            
            var body: some View {
                if let processingData = showStatus.processingData {
                    let content = contentView(label: processingData.label, description: processingData.description)
                    if let progressPublisher {
                        content.onReceive(progressPublisher) { value in
                            progressValue = value
                        }
                    } else {
                        content
                    }
                }
            }
            
            private func contentView(label: String, description: String) -> some View {
                VStack(spacing: 8) {
                    VStack(spacing: 0) {
                        Text(label.uppercased())
                            .font(kernedFont: .Secondary.p3BoldExtraKerned)
                            .foregroundColor(.ebony)
                        Text(description)
                            .font(kernedFont: .Secondary.p4MediumKerned)
                            .foregroundColor(.middleGrey)
                    }
                    if progressPublisher != nil {
                        Text("\(progressValue) %")
                            .font(kernedFont: .Secondary.p5RegularKerned)
                            .foregroundColor(.brightGold)
                    }
                }
                .multilineTextAlignment(.center)
                .animation(.default, value: progressValue)
            }
        }
    }
}

extension View {
    
    func showAdditionalTagView(isDisabled: Bool) -> some View {
        ZStack {
            if isDisabled {
                Color.paleSilver.opacity(0.5)
            }
            self
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                .background(Color.beige, in: RoundedRectangle(cornerRadius: 5))
                .padding(.horizontal, 16)
        }
    }
}

#if DEBUG
struct ProfileShows_Previews: PreviewProvider {
    
    static let progressContainer = VideoUploadProgressContainer()
    
    static var previews: some View {
        Group {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                    ForEach(Show.allShows) {
                        ProfileComponents.ShowCardView(show: $0)
                    }
                }
                .padding()
                .previewLayout(.sizeThatFits)
            }
            .previewDisplayName("Show Cards")
            
            ProfileComponents.ShowsGridView(viewModel: ProfileComponents.ShowsGridViewModel(ownerID: "", type: .user, showService: MockShowService(), accessLevel: .readWrite, actionHandler: nil))
                .previewDisplayName("Creator ShowsGridView")
            ProfileComponents.ShowsGridView(viewModel: ProfileComponents.ShowsGridViewModel(ownerID: "", type: .brand, showService: MockShowService(), accessLevel: .readOnly, actionHandler: nil))
                .previewDisplayName("Brand ShowsGridView")
        }
        .padding(.top, 32)
        .environmentObject(progressContainer)
        .onAppear {
            progressContainer.sendMockUploadProgress()
        }
    }
}
#endif
