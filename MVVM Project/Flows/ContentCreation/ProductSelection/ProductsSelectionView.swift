//
//  ProductsSelectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.12.2022.
//

import SwiftUI
import Combine

struct ProductsSelectionView: View {
    
    @ObservedObject var viewModel: ProductsSelectionViewModel
    var animationDuration: TimeInterval = 0.25
    
    @FocusState private var isFocused: Bool
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 8) {
            navigationView
            ScrollView {
                contentView
                    .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.immediately)
            .setViewportLayoutSize($contentSize)
            if !isFocused {
                footerSection
            }
        }
        .primaryBackground()
        .errorToast(error: $viewModel.backendError)
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !isFocused {
                Text(viewModel.headerMessageString)
                    .font(kernedFont: .Main.h1MediumKerned)
                    .foregroundColor(.jet)
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            searchBarWithCategories
            giftingView
            if viewModel.loadingSourceType == .new {
                LoadingResultsView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 82)
            } else {
                ProductsSelectionGridView(
                    products: viewModel.displayedProducts,
                    brands: viewModel.selectedBrands,
                    showBrandsHeader: !viewModel.isRequestingProducts,
                    contentSize: contentSize,
                    productCellContent: { product in
                        SelectableProductView(
                            product: product,
                            isSelected: viewModel.selectedProducts.contains(product),
                            selectionStyle: viewModel.isRequestingProducts ? .removeLabel : .checkmark,
                            isAutoSelectable: !viewModel.isRequestingProducts,
                            selectionPublisher: viewModel.selectionPublisher.eraseToAnyPublisher()
                        ) { _ in
                            isFocused = false
                            viewModel.updateProductSelection(product)
                        }
                    }, onReachedLastPage: { lastItemID in
                        viewModel.loadMoreIfNeeded(lastItemID)
                    }
                )
                .overlayLoadingIndicator(viewModel.loadingSourceType == .paged, scale: 1, alignment: .bottom)
                .transition(.opacity.animation(.easeInOut(duration: animationDuration)))
                .animation(.easeInOut(duration: animationDuration), value: viewModel.displayedProducts)
                DividerView()
            }
        }
        .animation(.easeInOut(duration: animationDuration), value: isFocused)
    }
    
    //MARK: Gifting
    @ViewBuilder private var giftingView: some View {
        if let instructions = viewModel.selectedBrands.first?.giftRequestInstruction, viewModel.isRequestingProducts {
            GiftingInstructionsView(instructions: instructions)
                .transition(.opacity)
        }
    }
    
    //MARK: SearchBar
    private var searchBarWithCategories: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: -8) {
                InputField(
                    inputText: $viewModel.queryInput,
                    scope: nil,
                    placeholder: Strings.TextFieldScope.searchProduct,
                    submitLabel: .search, onSubmit: viewModel.searchProducts,
                    leadingView: {
                        Image(.searchIcon)
                    }, trailingView: {
                        if !viewModel.queryInput.isEmpty {
                            searchBarClearButton
                        }
                    }
                )
                .defaultFieldStyle(hint: nil)
                .focused($isFocused)
                .textInputAutocapitalization(.never)
                if isFocused || viewModel.showDismissSearch {
                    searchBarTrailingButton
                }
            }
            ProductCategoriesContainerView(productCategories: viewModel.productCategories) { tagID in
                viewModel.handleCategoryTagSelection(tagID)
            }
            DividerView()
                .padding(.top, 6)
        }
        .disabled(viewModel.loadingSourceType != nil)
    }
    
    //MARK: NavigationView
    private var navigationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationBar(
                inlineTitle: Strings.NavigationTitles.chooseProducts,
                onDismiss: {
                    viewModel.productSelectionActionHandler(.back(viewModel.selectedProducts))
                }, trailingView: {
                    Buttons.QuickActionButton { viewModel.productSelectionActionHandler(.cancel) }
                }
            )
            if !isFocused {
                _StepProgressView(selectedProductsCountPublisher: viewModel.selectedProductsCountPublisher)
            }
        }
        .animation(.easeIn(duration: animationDuration), value: isFocused)
    }
    
    //MARK: FooterSection
    private var footerSection: some View {
        ProductSelectionButton(
            isRequestingProducts: viewModel.isRequestingProducts,
            selectedProductsCountPublisher: viewModel.selectedProductsCountPublisher,
            isEnabled: viewModel.loadingSourceType == nil,
            action: viewModel.continueWithSelectedProducts
        )
    }
}

//MARK: SearchBar additional buttons
private extension ProductsSelectionView {
    
    var searchBarClearButton: some View {
        Button {
            viewModel.clearSearchInput()
        } label: {
            Text(Strings.Buttons.clear.uppercased())
                .font(kernedFont: .Secondary.p3BoldKerned)
                .foregroundColor(.ebony)
        }
        .buttonStyle(.plain)
        .transition(.opacity.animation(.easeInOut))
    }
    
    var searchBarTrailingButton: some View {
        Button {
            isFocused = false
            viewModel.dismissSearchAction()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.cappuccino)
                    .frame(width: 56, height: 56)
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .resizedToFit(width: 14, height: 14)
                    .foregroundColor(.ebony)
            }
        }
        .buttonStyle(.plain)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .identity)
        )
        .transaction { trailingButton in
            if viewModel.queryInput.isEmpty {
                trailingButton.animation = .easeOut.delay(animationDuration)
            }
        }
        .padding(.trailing, 16)
    }
}

fileprivate extension ProductsSelectionView {
        
    struct ProductSelectionButton: View {
        
        @State private var selectedProductsCount: Int = 0
        var isRequestingProducts = false
        let selectedProductsCountPublisher: CurrentValueSubject<Int, Never>
        
        let isEnabled: Bool
        let action: () -> Void
        
        private var buttonLabelString: String {
            return isRequestingProducts ? Strings.Buttons.confirmForGifting(selectedProductsCount) : Strings.Buttons.confirmForShow(selectedProductsCount)
        }
        
        var body: some View {
            PassthroughView {
                if selectedProductsCount > 0 {
                    Buttons.FilledRoundedButton(title: buttonLabelString, isEnabled: isEnabled, action: action)
                        .transition(.moveBottomAndFade)
                }
            }
            .zIndex(1)
            .onReceive(selectedProductsCountPublisher) { productCount in
                self.selectedProductsCount = productCount
            }
        }
    }
    
    struct _StepProgressView: View {
        
        @State private var progressStates = ProgressState.createStaticStates(currentIndex: 2)
        let selectedProductsCountPublisher: CurrentValueSubject<Int, Never>
        
        var body: some View {
            PassthroughView {
                StepProgressView(currentIndex: 2, progressStates: progressStates)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            .onReceive(selectedProductsCountPublisher) { productsCount in
                progressStates[2] = productsCount > 0 ? .progress(1) : .idle
            }
        }
    }
}

#if DEBUG
struct ProductsSelectionView_Previews: PreviewProvider {

    static var previews: some View {
        ProductsSelectionViewPreview()
        ProductsSelectionViewPreview(isRequestingProducts: true)
            .previewDisplayName("Requesting Gift Products")
    }

    private struct ProductsSelectionViewPreview: View {
        
        init(isRequestingProducts: Bool = false) {
            self._viewModel = StateObject(wrappedValue: ProductsSelectionViewModel(partnershipBrands: PartnershipBrand.allBrands, isRequestingProducts: isRequestingProducts, brandService: MockBrandService(), contentCreationService: MockContentCreationService(), productSelectionActionHandler: { _ in}))
        }

        @StateObject var viewModel: ProductsSelectionViewModel
        
        var body: some View {
            ProductsSelectionView(viewModel: viewModel)
        }
    }
}
#endif
