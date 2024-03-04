//
//  PromotionalBannerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 05.10.2023.
//

import SwiftUI

struct PromotionalBannerView: View {
    
    @ObservedObject var viewModel: PromotionalBannerViewModel
    
    //Internal
    @State private var selectedBannerIndex: Int = 0
    
    var body: some View {
        TabView(selection: $selectedBannerIndex) {
            let banners = viewModel.promotionalBanners
            if banners.isEmpty {
                Image(.promotionalBannerPlaceholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 16)
            } else {
                ForEach(banners.indexEnumeratedArray, id: \.offset) { (index, banner) in
                    Button(action: {
                        viewModel.handlePromotionalBannerSelection(for: banner)
                    }, label: {
                        CellView(
                            promotionalBanner: banner,
                            isLoading: banner.type == viewModel.loadingBannerTaskType
                        )
                        .padding(.horizontal, 16)
                        .tag(index)
                    })
                    .buttonStyle(.scaled)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 114)
        .overlay(alignment: .bottom) {
            let maxIndex = viewModel.promotionalBanners.count
            if maxIndex > 1 {
                CircularPaginatedProgressView(currentIndex: selectedBannerIndex, maxIndex: maxIndex)
                    .padding(4)
                    .background(Color.cultured.opacity(0.1), in: Capsule(style: .continuous))
                    .padding(.bottom, 4)
            }
        }
    }
    
    struct CellView: View {
        
        let promotionalBanner: PromotionalBanner
        var isLoading = false
        
        var body: some View {
            ZStack(alignment: .leading) {
                AsyncImageView(imageURL: promotionalBanner.imageURL)
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        LinearGradient(
                            colors: [.jet, .clear],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                contentView
            }
            .frame(height: 114)
            .roundedBorder(Color.brightGold, cornerRadius: 12)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .bottomTrailing) {
                if isLoading {
                    ProgressView()
                        .tint(.cultured)
                        .padding([.bottom, .trailing], 8)
                        .transition(.scale)
                }
            }
        }
        
        private var contentView: some View {
            GeometryReader { geometryProxy in
                VStack(alignment: .leading, spacing: 8) {
                    if promotionalBanner.isNew {
                        Text("NEW")
                            .font(kernedFont: .Secondary.p4BoldKerned)
                            .foregroundColor(.midGrey)
                    }
                    Text(promotionalBanner.title.uppercased())
                        .font(kernedFont: .Main.p1RegularKerned)
                        .foregroundColor(.cultured)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: (geometryProxy.size.width - 32) * 0.7, alignment: .leading)
                    Text(promotionalBanner.message)
                        .font(kernedFont: .Secondary.p1BoldKerned)
                        .foregroundColor(.brightGold)
                }
                .padding(16)
                .frame(maxHeight: .infinity)
            }
            .frame(height: 114)
        }
    }
}

#if DEBUG
#Preview {
    Group {
        ViewModelPreviewWrapper(PromotionalBannerViewModel.mocked) { vm in
            PromotionalBannerView(viewModel: vm)
        }
        PromotionalBannerView(viewModel: PromotionalBannerViewModel.mockedEmpty)
        PromotionalBannerView.CellView(promotionalBanner: PromotionalBanner.promotionalBrandBanner)
            .previewDisplayName("BannerCellView")
            .background(Color.cultured)
            .padding()
    }
}
#endif
