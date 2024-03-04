//
//  PreviewShowDetailView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.01.2023.
//

import SwiftUI

struct PreviewShowDetailView: View {
    
    @ObservedObject var viewModel: PreviewShowDetailViewModel
    
    var videoPlayerService: PreviewVideoPlayerService {
        viewModel.videoPlayerService
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            let globalFrame = geometryProxy.frame(in: .global)
            let didPassMidBounds = viewModel.cellScrolledPastMidVisibleBounds(for: globalFrame)
            let scale = didPassMidBounds ? 1 : 0.925
            let gradientOpacity = didPassMidBounds ? 0 : 0.35
            
            ZStack {
                AVPlayerView(avPlayer: videoPlayerService.videoPlayer)
                AsyncImageView(imageURL: viewModel.show.thumbnailUrl)
                    .aspectRatio(contentMode: .fill)
                    .frame(size: globalFrame.size)
                    .opacity(videoPlayerService.isVideoPlayerReadyToPlay ? 0 : 1)
                    .animation(.easeInOut(duration: 0.25), value: videoPlayerService.isVideoPlayerReadyToPlay)
            }
            .animation(.easeInOut(duration: 1), value: videoPlayerService.playerStatus)
            .background(Color.cultured)
            .overlay(gradientView)
            .overlay(Color.jet.opacity(gradientOpacity))
            .animation(.smooth, value: gradientOpacity)
            .overlay(alignment: .topLeading, content: liveTagIndicatorView)
            .overlay(alignment: .bottomLeading) {
                AdditionalShowDetailView(show: viewModel.show, onSelectCreator: viewModel.onSelectCreator, onSelectBrand: viewModel.onSelectBrand)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(scale, anchor: .leading)
            .animation(.smooth, value: scale)
        }
    }
    
    @ViewBuilder private func liveTagIndicatorView() -> some View {
        if viewModel.show.status == .live {
            FadedLiveStreamIndicatorView()
                .padding([.leading, .top], 16)
                .transition(.opacity)
        }
    }
    
    private var gradientView: some View {
        GeometryReader { geometryProxy in
            let gradientProvider = IncreasingGradient(endValue: 0.65)
            LinearGradient(gradient: gradientProvider.makeGradient(.jet),
                           startPoint: .top, endPoint: .bottom)
                .frame(height: geometryProxy.size.height / 2)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

private extension PreviewShowDetailView {
    
    struct AdditionalShowDetailView: View {

        let show: Show
        let onSelectCreator: (Creator) -> Void
        let onSelectBrand: (Brand) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                if case .scheduled = show.status, let publishingDate = show.publishingDate {
                    upcomingShowTagView(publishingDate)
                }
                VStack(alignment: .leading, spacing: 12) {
                    if let creator = show.creator {
                        MinimizedCreatorProfileView(creator: creator, onSelect: {
                            onSelectCreator(creator)
                        })
                    }
                    Text(show.title ?? "")
                        .textStyle(.showTitle)
                    let brands = show.uniqueFeaturedBrands
                    if !brands.isEmpty {
                        featuredBrandsStackView(brands)
                    }
                }
            }
            .padding(16)
        }
        
        private func upcomingShowTagView(_ publishDate: Date) -> some View {
            let formattedPublishDate = publishDate.dateString(formatType: .fullDateAndTime)
            return Text((Strings.Discover.upcoming + " " + formattedPublishDate).uppercased())
                .font(kernedFont: .Secondary.p3RegularExtraKerned)
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                .background(Color.ebony.opacity(0.35).blur(radius: 1))
                .shadow(color: .white.opacity(0.15), radius: 3)
        }
        
        private func featuredBrandsStackView(_ brands: OrderedSet<Brand>) -> some View {
            GeometryReader { geometryProxy in
                let cellWidth = 48 + 16
                let fittingBrandsCount = max((Int(geometryProxy.size.width) - cellWidth) / cellWidth, 0)
                let remainingBrandsCount = brands.count - fittingBrandsCount

                HStack(spacing: 12) {
                    ForEach(brands.prefix(fittingBrandsCount)) { brand in
                        Button {
                            onSelectBrand(brand)
                        } label: {
                            BrandLogoView(imageURL: brand.logoPictureURL, diameterSize: 48)
                        }
                        .buttonStyle(.plain)
                    }
                    if remainingBrandsCount > 0 {
                        Circle()
                            .fill(Color.battleshipGray.opacity(0.55))
                            .frame(width: 48, height: 48)
                            .overlay {
                                Text("+\(remainingBrandsCount)")
                                    .font(kernedFont: .Secondary.p4BoldKerned)
                                    .foregroundColor(.white)
                            }
                    }
                }
            }
            .frame(height: 48)
        }
    }
}

#if DEBUG
struct PreviewShowDetailPreview: PreviewProvider {

    static var previews: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                HStack {
                    ForEach([Show.liveStream, .sample, .scheduled]) { show in
                        PreviewShowDetailWrapper(show: show)
                            .frame(width: proxy.size.width / 2, height: 280)
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
        }
        .frame(height: 280)
    }
    
    private struct PreviewShowDetailWrapper: View {
        
        @StateObject var viewModel: PreviewShowDetailViewModel
        
        init(show: Show, creatorCanStartLive: Bool = false) {
            self._viewModel = StateObject(wrappedValue: PreviewShowDetailViewModel.preview(show: show))
            if creatorCanStartLive {
                viewModel.currentUserID = show.creatorID
            }
        }
        
        var body: some View {
            PreviewShowDetailView(viewModel: viewModel)
        }
    }
}
#endif
