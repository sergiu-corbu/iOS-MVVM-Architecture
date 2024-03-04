//
//  ProductDetailsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.02.2023.
//

import SwiftUI
import Combine

struct ProductDetailsView: View {
    
    @ObservedObject var viewModel: ProductDetailsViewModel
    var isGrabIndicatorVisible = true
    
    var body: some View {
        VStack(spacing: 8) {
            if isGrabIndicatorVisible {
                GrabberView()
            }
            productsDetailContent
                .scrollableVariantsSectionContainer(scrollPublisher: viewModel.$isVariantsSelectionBannerPresented.eraseToAnyPublisher())
            ProductsDetailFooterView(viewModel: viewModel)
        }
        .roundedCorners(.topCorners, radius: 12)
        .primaryBackground()
        .productVariantsSelectionBanner(isPresented: viewModel.isVariantsSelectionBannerPresented)
        .clearCheckoutCartWarningSheet(
            isPresented: $viewModel.isClearCartWarningSheetPresented,
            onAddProduct: { viewModel.addToCartAction(forceCreateCart: true) }
        )
        .debounce(publisher: viewModel.$selectedProductIndex, for: 1, viewModel.incrementProductView)
    }
    
    private var productsDetailContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 8) {
                productsPageIndicatorView
                CollectionView(
                    dataSource: viewModel.products,
                    collectionViewLayout: SnappyFlowLayout(itemSize: CGSize(width: 120, height: 160), spacing: 12),
                    cellProvider: {
                        compactProductDetailView($0)
                    }, customizeCollectionView: { collectionView in
                        viewModel.configureCollectionView(collectionView)
                    }, onContextUpdated: {
                        viewModel.scrollToInitialSelectedIndex(animated: false)
                    }
                )
                .frame(height: 160)
                ProductSaleDetailView(
                    productDisplayable: viewModel.selectedProduct,
                    customPrices: viewModel.variantsSelectionViewModel.customPrices,
                    configuration: .centered,
                    actionHandler: viewModel.productSaleAction
                )
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                DividerView()
                
                if !viewModel.isAffiliateProduct {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(Color.darkGreen)
                    } else {
                        ProductVariantsSelectionView(viewModel: viewModel.variantsSelectionViewModel)
                    }
                    AdditionalProductInformationsView(brand: viewModel.selectedProduct.brand)
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
                }
            }
            .animation(.easeInOut, value: viewModel.selectedProductIndex)
        }
    }
    
    private func compactProductDetailView(_ product: Product) -> some View {
        Button {
            viewModel.handleProductCellSelection(product)
        } label: {
            ProductShortDetailsView(
                product: product,
                selectedProductPublisher: viewModel.selectedProductPublisher.eraseToAnyPublisher(),
                imageURLPublisher: viewModel.selectedProductImageURLPublisher.eraseToAnyPublisher()
            )
            .environmentObject(viewModel.favoritesManager)
        }
        .buttonStyle(.plain)
    }
    
    struct ProductShortDetailsView: View {
        
        let product: Product
        let selectedProductPublisher: AnyPublisher<Product, Never>
        let imageURLPublisher: AnyPublisher<URL?, Never>
        
        @State private var imageURL: URL?
        @State private var isSelected = false
        
        var body: some View {
            AsyncImageView(imageURL: imageURL ?? product.primaryMediaImageURL, placeholderImage: .fashionIcon)
            .aspectRatio(contentMode: .fit)
            .cornerRadius(8)
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(.expandIcon)
                        .padding([.top, .trailing], 4)
                        .transition(.opacity)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                FavoriteIconWrapperView(favoriteID: product.id, type: .products, style: .square)
                    .padding([.bottom, .trailing], 8)
            }
            .frame(height: 160)
            .opacity(isSelected ? 1 : 0.5)
            .animation(.easeInOut, value: isSelected)
            .onReceive(selectedProductPublisher) { selectedProduct in
                isSelected = selectedProduct.id == product.id
                if !isSelected {
                    imageURL = nil
                }
            }
            .onReceive(imageURLPublisher) { imageURL in
                if isSelected {
                    self.imageURL = imageURL
                }
            }
        }
    }
}

//MARK: Helper views
private extension ProductDetailsView {
    
    private var productsPageIndicatorView: some View {
        Text(viewModel.pageIndicatorString)
            .font(kernedFont: .Secondary.p1BoldKerned)
            .monospacedDigit()
            .foregroundColor(.middleGrey)
            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.ebony.opacity(0.15)))
    }
}

#if DEBUG
struct ProductDetails_Previews: PreviewProvider {
    
    static var previews: some View {
        Color.clear
            .sheet(isPresented: .constant(true)) {
                ProductDetailsPreview()
                    .presentationDetents([.fraction(0.85)])
            }
    }

    private struct ProductDetailsPreview: View {

        @StateObject var viewModel = ProductDetailsViewModel.mockedProductsDetailVM()

        var body: some View {
            ProductDetailsView(viewModel: viewModel)
                .environmentObject(FavoritesManager.mockedFavoritesManager)
        }
    }
}
#endif
