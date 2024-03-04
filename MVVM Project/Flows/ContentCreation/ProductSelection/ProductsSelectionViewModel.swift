//
//  ProductsSelectionViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.12.2022.
//

import Foundation
import Combine
import UIKit

typealias LoadingSourceType = DataSourceType

class ProductsSelectionViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var queryInput: String = ""
    @Published var products = [Product]()
    @Published private(set) var searchedProducts = [Product]()
    @Published private(set) var loadingSourceType: LoadingSourceType?
    @Published var backendError: Error?
    
    let isRequestingProducts: Bool
    
    @Published private(set) var selectedBrands: [Brand]
    private let selectedBrandIDs: Set<String>
    let selectedProductsCountPublisher: CurrentValueSubject<Int, Never> = .init(0)
    let selectionPublisher = PassthroughSubject<ProductSelection, Never>()
    private var isShowingSearchResult: Bool = false
    private(set) var selectedProducts = Set<Product>() {
        didSet {
            handleSelectionChange()
        }
    }
    private(set) var selectedProductsIDsSKUIDs = [String:String]()
    private var selectedCategoriesIDs = Set<String>()
    private(set) var productCategories = [ProductCategory]()
    
    //MARK: - Services
    private let contentCreationService: ContentCreationServiceProtocol
    private let brandService: BrandServiceProtocol
    private var productsDataSourceConfiguration: any DataSourceConfiguration
    private var searchDataSourceConfiguration: any DataSourceConfiguration
    private let imageDownloader: ImageDownloader
    private var getProductsTask: Task<Void, Never>?
    
    //MARK: - Actions
    enum Action {
        case back(_ currentProductsSelection: Set<Product>)
        case cancel
        case productSelected(Product, ProductsSelectionViewModel)
        case interactionFinished((products: Set<Product>, productSKUIds: [String]))
    }
    let productSelectionActionHandler: (Action) -> Void
    
    //MARK: - Computed
    var displayedProducts: [Product] {
        return isShowingSearchResult ? searchedProducts : products
    }
    var showDismissSearch: Bool {
        return !queryInput.isEmpty || !selectedCategoriesIDs.isEmpty
    }
    var headerMessageString: String {
        return isRequestingProducts ? Strings.ContentCreation.productsRequestMessage : Strings.ContentCreation.productsSelectionMessage
    }
    
    init(partnershipBrands: [PartnershipBrand],
         isRequestingProducts: Bool = false,
         previouslySelectedProducts: Set<Product> = Set<Product>(),
         brandService: BrandServiceProtocol,
         contentCreationService: ContentCreationServiceProtocol,
         imageDownloader: ImageDownloader = KFImageDownloader(),
         productSelectionActionHandler: @escaping (Action) -> Void) {
        
        self.brandService = brandService
        self.contentCreationService = contentCreationService
        self.isRequestingProducts = isRequestingProducts
        self.selectedProducts = previouslySelectedProducts
        self.imageDownloader = imageDownloader
        self.selectedBrands = partnershipBrands.map { Brand(partnershipBrand: $0)}.sorted(using: KeyPathComparator(\.name, order: .forward))
        self.selectedBrandIDs = Set(partnershipBrands.map(\.id))
        self.productsDataSourceConfiguration = PaginatedDataSourceConfiguration(pageSize: 30)
        self.searchDataSourceConfiguration = PaginatedDataSourceConfiguration(pageSize: 20)
        self.productSelectionActionHandler = productSelectionActionHandler
        
        handleSelectionChange()
        
        getBrandForGiftingRequest()
        getProductsAndCategories()
    }
    
    deinit {
        getProductsTask?.cancel()
    }
    
    private func handleSelectionChange() {
        selectedProductsCountPublisher.send(selectedProducts.count)
    }
    
    private func getProductsAndCategories() {
        Task(priority: .userInitiated) { @MainActor in
            do {
                loadingSourceType = .new
                self.productCategories = try await contentCreationService.getProductCategories(brandIDs: selectedBrandIDs)
                let retrievedProducts = try await contentCreationService.searchProducts(
                    queryInput,
                    brandIDs: selectedBrandIDs,
                    productCategoryIDs: nil,
                    lastProductID: productsDataSourceConfiguration.lastItemID,
                    pageSize: productsDataSourceConfiguration.pageSize,
                    inStockOnly: isRequestingProducts
                )
                productsDataSourceConfiguration.processResult(results: retrievedProducts)
                self.products = await imageDownloader.prefetchImages(objects: retrievedProducts)
            } catch {
                backendError = error
            }
            loadingSourceType = nil
        }
    }
    
    private func getBrandForGiftingRequest() {
        guard isRequestingProducts, let brandID = selectedBrands.first?.id else {
            return
        }
        Task(priority: .userInitiated) { @MainActor [weak self] in
            if let brand = try? await self?.brandService.getBrand(id: brandID) {
                self?.selectedBrands = [brand]
            }
        }
    }
    
    func searchProducts() {
        guard !queryInput.isEmpty || !selectedCategoriesIDs.isEmpty else {
            return
        }
        isShowingSearchResult = true
        searchDataSourceConfiguration.reset()
        searchedProducts = []
        getProducts(sourceType: .new, isFromSearch: true)
    }
    
    private func getProducts(sourceType: DataSourceType, isFromSearch: Bool = false) {
        loadingSourceType = sourceType
        getProductsTask?.cancel()
        getProductsTask = Task(priority: .userInitiated) { @MainActor in
            do {
                let dataSourceConfig: any DataSourceConfiguration = isFromSearch ? searchDataSourceConfiguration : productsDataSourceConfiguration
                var retrievedProducts = try await contentCreationService.searchProducts(
                    queryInput, brandIDs: selectedBrandIDs,
                    productCategoryIDs: selectedCategoriesIDs,
                    lastProductID: dataSourceConfig.lastItemID,
                    pageSize: dataSourceConfig.pageSize,
                    inStockOnly: isRequestingProducts
                )
                if isFromSearch {
                    searchDataSourceConfiguration.processResult(results: retrievedProducts)
                    retrievedProducts = await imageDownloader.prefetchImages(objects: retrievedProducts)
                    switch sourceType {
                    case .paged: searchedProducts.append(contentsOf: retrievedProducts)
                    case .new: searchedProducts = retrievedProducts
                    }
                } else {
                    productsDataSourceConfiguration.processResult(results: retrievedProducts)
                    retrievedProducts = await imageDownloader.prefetchImages(objects: retrievedProducts)
                    products.append(contentsOf: retrievedProducts)
                }
            } catch {
                backendError = error
            }
            loadingSourceType = nil
        }
    }
    
    func updateProductSelection(_ product: Product) {
        if isRequestingProducts {
            if selectedProducts.contains(product) {
                handleProductDetailSelection(product, skuID: nil, isSelected: false)
            } else {
                productSelectionActionHandler(.productSelected(product, self))
            }
            return
        }
        selectedProducts.updateOrRemove(product)
    }
    
    func handleProductDetailSelection(_ product: Product, skuID: String?, isSelected: Bool) {
        guard isRequestingProducts else {
            return
        }
        selectedProducts.updateOrRemove(product)
        if let skuID {
            selectedProductsIDsSKUIDs.updateValue(skuID, forKey: product.id)
        } else {
            selectedProductsIDsSKUIDs.removeValue(forKey: product.id)
        }
        
        selectionPublisher.send((product.id, isSelected))
    }
    
    func handleCategoryTagSelection(_ categoryTagID: String) {
        selectedCategoriesIDs.updateOrRemove(categoryTagID)
        searchProducts()
    }
    
    func clearSearchInput() {
        queryInput = ""
        searchDataSourceConfiguration.reset()
    }
    
    func dismissSearchAction() {
        isShowingSearchResult = false
        queryInput = ""
        searchedProducts = []
        searchDataSourceConfiguration.reset()
    }
    
    func loadMoreIfNeeded(_ itemID: String) {
        guard loadingSourceType == nil else {
            return
        }
        
        if isShowingSearchResult {
            if searchDataSourceConfiguration.shouldLoadMore(itemID: itemID) {
                getProducts(sourceType: .paged, isFromSearch: true)
            }
        } else {
            if productsDataSourceConfiguration.shouldLoadMore(itemID: itemID) {
                getProducts(sourceType: .paged)
            }
        }
    }
        
    func continueWithSelectedProducts() {
        productSelectionActionHandler(.interactionFinished((selectedProducts, selectedProductsIDsSKUIDs.values.map { $0 } )))
    }
}
