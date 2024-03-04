//
//  ProductDetailsViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.02.2023.
//

import Foundation
import UIKit
import Combine

class ProductDetailsViewModel: NSObject, ObservableObject {
    
    //MARK: - Properties
    @Published private(set) var products: [Product]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isProcessingCheckout: Bool = false
    @Published var isVariantsSelectionBannerPresented = false
    @Published var isClearCartWarningSheetPresented = false
    @Published var selectedProductIndex: Int {
        willSet {
            handleNewProductSelected(at: newValue)
        }
    }
    let productsContext: ProductSelectableDTO
    private var initialSelectedIndex: Int?
    weak private var productsCollectionView: UICollectionView?
    var variantsSelectionViewModel: ProductVariantsSelectionViewModel
    
    private var cancellable: AnyCancellable?
    private var loadTask: VoidTask?
    
    //MARK: Getters
    var selectedProduct: Product {
        return products[selectedProductIndex]
    }
    var pageIndicatorString: String {
        return "\(selectedProductIndex + 1)" + "/" + products.count.description
    }
    var isPrimaryButtonEnabled: Bool {
        return isRequestedProductAvailable && variantsSelectionViewModel.didSelectAllVariants
    }
    var isRequestedProductAvailable: Bool {
        return variantsSelectionViewModel.currentProductSKU?.isInStock == true
    }
    var isAffiliateProduct: Bool {
        selectedProduct.type == .affiliate
    }
    
    //MARK: - Actions
    var productDetailsCallback: (Action) -> Void = {_ in}
    enum Action {
        case dismiss
        case showProductDetailView(ProductDetailsViewModel)
        case selectBrand(Brand)
        case productRequested((product: Product, skuID: String))
        case checkout(CheckoutCart)
        case share(Product)
        case openAffiliateWebPage(URL)
    }
    
    var productSaleAction: ProductSaleDetailView.Action {
        return ProductSaleDetailView.Action(onSelectBrand: { [weak self] in
            if let self {
                self.productDetailsCallback(.selectBrand(self.selectedProduct.brand))
            }
        }, onShare: { [weak self] in
            self?.shareAction()
        })
    }
    
    //MARK: - Publishers
    let selectedProductPublisher: CurrentValueSubject<Product, Never>
    let selectedProductImageURLPublisher: CurrentValueSubject<URL?, Never> = .init(nil)
    
    //MARK: - Services
    let showService: ShowRepositoryProtocol
    let favoritesManager: FavoritesManager
    let checkoutCartManager: CheckoutCartManager
    let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    init(productsContext: ProductSelectableDTO, showService: ShowRepositoryProtocol,
         checkoutCartManager: CheckoutCartManager, favoritesManager: FavoritesManager,
         productsDetailAction: @escaping (Action) -> Void) {
        
        self.products = productsContext.products
        self.productsContext = productsContext
        self.showService = showService
        self.checkoutCartManager = checkoutCartManager
        self.favoritesManager = favoritesManager
        self.selectedProductIndex = productsContext.selectedIndex
        self.initialSelectedIndex = productsContext.initialSelectedIndex
        self.productDetailsCallback = productsDetailAction
        self.selectedProductPublisher = CurrentValueSubject(productsContext.selectedProduct)
        self.variantsSelectionViewModel = ProductVariantsSelectionViewModel(product: productsContext.selectedProduct)
        super.init()
        
        subscribeToVariantChanges()
        trackProductViewedEvent(selectedProduct, at: 0)
        
        loadTask = Task(priority: .userInitiated) { @MainActor [weak self] in
            self?.loadTask?.cancel()
            self?.isLoading = true
            defer { self?.isLoading = false }
            
            guard let showID = self?.productsContext.showID,
                  let updatedProducts = try? await self?.showService.getProductsForShow(showID: showID) else {
                return
            }
            self?.products = updatedProducts
            if let selectedProduct = self?.selectedProduct {
                self?.variantsSelectionViewModel = ProductVariantsSelectionViewModel(product: selectedProduct)
                self?.subscribeToVariantChanges()
            }
        }
    }
    
    deinit {
        cancellable?.cancel()
        loadTask?.cancel()
    }
    
    //MARK: - Setup
    func subscribeToVariantChanges() {
        cancellable = variantsSelectionViewModel.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
            self?.selectedProductImageURLPublisher.send(
                self?.variantsSelectionViewModel.selectedVariantMediaURLs?.first
            )
        }
    }
    
    func configureCollectionView(_ collectionView: UICollectionView) {
        self.productsCollectionView = collectionView
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
    }
    
    func scrollToProduct(at index: Int, animated: Bool = true) {
        guard selectedProductIndex != index else {
            return
        }
        productsCollectionView?.scrollToItem(
            at: IndexPath(row: index, section: 0),
            at: .centeredHorizontally, animated: animated
        )
    }
    
    func scrollToProduct(_ product: Product, animated: Bool = true) {
        if let productIndex = products.firstIndex(of: product) {
            scrollToProduct(at: productIndex)
        }
    }
    
    func scrollToInitialSelectedIndex(animated: Bool) {
        guard let initialSelectedIndex else {
            return
        }
        productsCollectionView?.scrollToItem(
            at: IndexPath(row: initialSelectedIndex, section: 0),
            at: .centeredHorizontally, animated: animated
        )
        self.initialSelectedIndex = nil
    }
    
    func selectProductAction() {
        guard let selectedProductSKUId = variantsSelectionViewModel.currentProductSKU?.id else {
            return
        }
        productDetailsCallback(.productRequested((selectedProduct, String(selectedProductSKUId))))
    }
    
    func presentCheckoutCart() {
        guard let checkoutCart = checkoutCartManager.checkoutCart else {
            return
        }
        productDetailsCallback(.checkout(checkoutCart))
    }
    
    func addToCartAction(forceCreateCart: Bool = false) {
        guard variantsSelectionViewModel.didSelectAllVariants else {
            showVariantsSelectionBanner()
            return
        }
        guard let currentProductSKU = variantsSelectionViewModel.currentProductSKU else {
            ToastDisplay.showErrorToast(error: PaymentError.productOutOfStock)
            return
        }
        
        isProcessingCheckout = true
        Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                if forceCreateCart {
                    try await self.checkoutCartManager.createCart(
                        productSKUId: currentProductSKU.id,
                        creatorId: self.productsContext.creator?.id,
                        showId: self.productsContext.showID,
                        deletePreviousCart: true
                    )
                } else {
                    try await self.checkoutCartManager.addProductToCart(
                        productSKUId: currentProductSKU.id,
                        creatorId: self.productsContext.creator?.id,
                        showId: self.productsContext.showID
                    )
                }
            } catch (let error as NetworkError) {
                guard error.errorCodeString == NetworkError.ErrorCode.differentMerchant else {
                    self.isProcessingCheckout = false
                    ToastDisplay.showErrorToast(error: error)
                    return
                }
                isClearCartWarningSheetPresented = true
            } catch {
                ToastDisplay.showErrorToast(error: error)
            }
            self.isProcessingCheckout = false
        }
    }
    
    func openAffiliateProductWebPage() {
        guard isAffiliateProduct, let affiliateURL = selectedProduct.externalLink else {
            return
        }
        productDetailsCallback(.openAffiliateWebPage(affiliateURL))
    }
    
    func showVariantsSelectionBanner() {
        if isVariantsSelectionBannerPresented {
            return
        }
        
        isVariantsSelectionBannerPresented = true
        DispatchQueue.main.asyncAfter(seconds: 2) { [weak self] in
            self?.isVariantsSelectionBannerPresented = false
        }
    }
    
    //MARK: - Detail View
    func handleProductCellSelection(_ product: Product) {
        if selectedProduct.id == product.id {
            productDetailsCallback(.showProductDetailView(self))
        } else {
            scrollToProduct(product)
        }
    }
    
    //MARK: - Actions
    func shareAction() {
        productDetailsCallback(.share(selectedProduct))
    }
}

extension ProductDetailsViewModel: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let layout = productsCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let calculatedFloatIndex = (scrollView.contentOffset.x) / (layout.itemSize.width + layout.minimumLineSpacing)
        let newIndex = min(max(0, Int(round(calculatedFloatIndex))), products.count - 1)
        
        guard newIndex != selectedProductIndex else {
            return
        }
        selectedProductIndex = newIndex
    }
}

//MARK: - VariantSections
private extension ProductDetailsViewModel {
    
    func handleNewProductSelected(at newIndex: Int) {
        guard let newProduct = products[safe: newIndex] else {
            return
        }
        
        variantsSelectionViewModel = ProductVariantsSelectionViewModel(product: newProduct)
        subscribeToVariantChanges()
        selectedProductPublisher.send(newProduct)
        trackProductViewedEvent(newProduct, at: newIndex)
    }
}

//MARK: - Analytics
extension ProductDetailsViewModel {
    
    func incrementProductView() {
        Task(priority: .utility) {
            do {
                try await showService.incrementProductViewCount(id: selectedProduct.id)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func trackProductViewedEvent(_ product: Product, at index: Int) {
        var properties = product.baseAnalyticsProperties
        properties[.sku_id] = variantsSelectionViewModel.currentProductSKU?.id
        properties[.show_id] = productsContext.showID
        properties[.creator_id] = productsContext.creator?.id
        properties[.product_position] = index + 1
        
        analyticsService.trackActionEvent(.product_viewed, properties: properties)
    }
    
    func trackImageZoomInEvent() {
        analyticsService.trackActionEvent(.product_zoom, properties: selectedProduct.baseAnalyticsProperties)
    }
}

extension ProductDetailsViewModel {
    
    #if DEBUG
    static func mockedProductsDetailVM(_ products: [Product] = [.prod1, .prod2, .sampleProduct]) -> ProductDetailsViewModel {
        ProductDetailsViewModel(
            productsContext: ProductSelectableDTO(products: products, selectedIndex: Int.random(in: 0..<products.count)),
            showService: MockShowService(),
            checkoutCartManager: .mocked,
            favoritesManager: .mockedFavoritesManager,
            productsDetailAction: { _ in })
    }
    #endif
}
