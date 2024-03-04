//
//  ExpandedProductDetailsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.02.2023.
//

import SwiftUI

struct ExpandedProductDetailsView: View {
    
    @ObservedObject var viewModel: ProductDetailsViewModel
    let product: Product
    let onClose: () -> Void
    
    // Internal
    @State private var currentMediaAlbumURLIndex: Int = 0
    @State private var isDescriptionExpanded = false
    @State private var availableSize: CGSize = .zero
    
    var variantsSectionVM: ProductVariantsSelectionViewModel {
        return viewModel.variantsSelectionViewModel
    }
    
    // ZoomGesture
    @GestureState private var scale: CGFloat = 1
    private var showZoomedImage: Bool {
        return scale > 1
    }
    
    // Media
    private var primaryMediaAlbumURL: URL? {
        if let firstSKUImageURL = variantsSectionVM.currentProductSKU?.mediaUrls.first {
            return firstSKUImageURL
        } else {
            return variantsSectionVM.selectedVariantMediaURLs?.first ?? product.primaryMediaImageURL
        }
    }
    private var mediaAlbumsURLs: [URL]? {
        guard var mediaAlbumsURLs = product.sortedMediaAlbumURLs else {
            return nil
        }
        if let primaryMediaAlbumURL {
            mediaAlbumsURLs.move(primaryMediaAlbumURL, to: 0)
        }
        
        return mediaAlbumsURLs
    }
    
    var body: some View {
        VStack(spacing: 12) {
            navigationBarView
            GeometryReader { geometryProxy in
                productDetailExpandedView(availableSize: geometryProxy.size)
            }
            ProductsDetailFooterView(viewModel: viewModel)
        }
        .primaryBackground()
        .productVariantsSelectionBanner(isPresented: viewModel.isVariantsSelectionBannerPresented)
        .clearCheckoutCartWarningSheet(
            isPresented: $viewModel.isClearCartWarningSheetPresented,
            onAddProduct: { viewModel.addToCartAction(forceCreateCart: true) }
        )
        .overlay {
            if showZoomedImage {
                Color.cultured
                    .overlay(productImageView(imageURL: mediaAlbumsURLs?[safe: currentMediaAlbumURLIndex]))
                    .ignoresSafeArea(.container, edges: .all)
                    .onAppear(perform: viewModel.trackImageZoomInEvent)
            }
        }
    }
    
    private var navigationBarView: some View {
        let additionalButtonsView = HStack(spacing: 16) {
            Buttons.ShareButton(tint: .middleGrey, onShare: viewModel.shareAction)
            Buttons.CloseButton(onClose: onClose)
        }
        return NavigationBar(barType: .navigation,
                             title: Strings.NavigationTitles.productDetails,
                             trailingView: { additionalButtonsView })
        .backButtonHidden(true)
    }

    private func productDetailExpandedView(availableSize: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            productImagesContainerView
            ScrollView(.vertical, showsIndicators: false) {
                productDescriptionView
                DividerView()
                ProductVariantsSelectionView(viewModel: variantsSectionVM)
            }
            .scrollableVariantsSectionContainer(scrollPublisher: viewModel.$isVariantsSelectionBannerPresented.eraseToAnyPublisher())
            .onAppear {
                self.availableSize = availableSize
            }
        }
    }
    
    @ViewBuilder private var productImagesContainerView: some View {
        if let mediaAlbumsURLs = mediaAlbumsURLs, mediaAlbumsURLs.count > 1 {
            VStack(spacing: 16) {
                TabView(selection: $currentMediaAlbumURLIndex) {
                    ForEach(0..<mediaAlbumsURLs.count, id: \.self) { imageIndex in
                        productImageView(imageURL: mediaAlbumsURLs[imageIndex])
                            .tag(imageIndex)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: availableSize.height / 2)
                .animation(.easeOut, value: currentMediaAlbumURLIndex)
                .overlay(alignment: .bottom) {
                    CircularPaginatedProgressView(currentIndex: currentMediaAlbumURLIndex, maxIndex: mediaAlbumsURLs.count)
                        .padding(4)
                        .background(Color.cultured.opacity(0.9), in: Capsule(style: .continuous))
                        .padding(.bottom, 16)
                }
            }
            .onChange(of: variantsSectionVM.selectedVariantValues) { _ in
                currentMediaAlbumURLIndex = 0
            }
        } else {
            productImageView(imageURL: primaryMediaAlbumURL)
        }
    }
}

// MARK: Zoomable product image
private extension ExpandedProductDetailsView {

    func productImageView(imageURL: URL?) -> some View {
        return AsyncImageView(imageURL: imageURL, placeholderImage: .fashionIcon)
            .aspectRatio(contentMode: .fit)
            .frame(height: availableSize.height / 2, alignment: .center)
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .scaleEffect(scale, anchor: .center)
            .zIndex(1)
            .gesture(magnificationGesture)
            .animation(.easeInOut(duration: 0.1), value: scale)
    }

    var magnificationGesture: some Gesture {
        MagnificationGesture(minimumScaleDelta: 0)
            .updating($scale) { value, scale, transaction in
                scale = max(0.9, value)
            }
    }
}

// MARK: Product Description
private extension ExpandedProductDetailsView {

    var productDescriptionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProductSaleDetailView(
                productDisplayable: viewModel.selectedProduct,
                customPrices: variantsSectionVM.customPrices,
                actionHandler: .init(onSelectBrand: viewModel.productSaleAction.onSelectBrand, onShare: nil)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 44)
            .overlay(alignment: .trailing) {
                FavoriteIconWrapperView(favoriteID: product.id, type: .products, style: .squareLarge)
                    .environmentObject(viewModel.favoritesManager)
            }

            let kernedFont = KernedFont.Secondary.p1RegularKerned
            Text(product.description)
                .lineLimitedTextView(
                    isExpanded: $isDescriptionExpanded,
                    text: product.description,
                    font: kernedFont.font, kern: kernedFont.kern
                )
                .foregroundColor(.ebony)
                .overlay(alignment: .bottomTrailing) {
                    if !isDescriptionExpanded {
                        Button {
                            isDescriptionExpanded = true
                        } label: {
                            Text("... " + Strings.Buttons.more)
                                .font(kernedFont: .Secondary.p2BoldKerned)
                                .foregroundColor(.darkGreen)
                        }
                        .buttonStyle(.plain)
                        .background(Color.cultured)
                    }
                }
            AdditionalProductInformationsView(brand: product.brand)
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview {
    ViewModelPreviewWrapper(ProductDetailsViewModel.mockedProductsDetailVM()) { vm in
        ExpandedProductDetailsView(viewModel: vm, product: vm.products.randomElement()!, onClose: {})
    }
}
#endif
