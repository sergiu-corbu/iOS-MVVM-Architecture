//
//  ProductsDetailCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.02.2023.
//

import Foundation
import UIKit
import SwiftUI

class ProductsDetailCoordinator {
    
    //MARK: - Properties
    let productsContext: ProductSelectableDTO
    private var requestedProductID: String?
    
    var products: [Product] {
        return productsContext.products
    }
    
    weak var presentingNavigationController: UINavigationController?
    private var navigationController: CustomNavigationController?
    
    private lazy var checkoutCoordinator = CheckoutCoordinator(
        dependencyContainer: dependencyContainer, navigationController: navigationController,
        analyticsContext: CheckoutAnalyticsContext(creator: productsContext.creator, showID: productsContext.showID),
        onFinishedInteraction: { [weak self] in
            self?.presentingNavigationController?.dismiss(animated: true)
            self?.onFinishedInteraction()
        }
    )
        
    lazy private var shareableProvider = ShareableProvider(deeplinkProvider: self.dependencyContainer.deeplinkService, onPresentShareLink: { [weak self] shareVC in
        let presentationViewController = self?.navigationController?.presentedViewController ?? self?.navigationController        
        presentationViewController?.present(shareVC, animated: true)
    })
    
    //MARK: - Actions
    let onFinishedInteraction: () -> Void
    var onProductRequestSelectionAction: ((_ isSelected: Bool, _ skuID: String?) -> Void)?
    var onSelectBrand: ((Brand) -> Void)?
    
    //MARK: Services
    private let favoritesManager: FavoritesManager
    private var analyticsService: AnalyticsService = .shared
    let dependencyContainer: DependencyContainer
    
    init(productSelectable: ProductSelectableDTO, dependencyContainer: DependencyContainer,
         presentingNavigationController: UINavigationController?, onFinishedInteraction: @escaping () -> Void) {
        
        self.productsContext = productSelectable
        self.dependencyContainer = dependencyContainer
        self.favoritesManager = dependencyContainer.favoritesManager
        self.presentingNavigationController = presentingNavigationController
        self.onFinishedInteraction = onFinishedInteraction
        
        trackProductClickedEvent(productSelectable: productSelectable)
        Task(priority: .utility) { [weak self] in
            await self?.favoritesManager.processProducts(self?.products ?? [])
        }
    }
    
    func start(animated: Bool = true) {
        if products.count == 1, products.first?.type == .affiliate, let sourceURL = products.first?.externalLink {
            showAffiliateProductWebView(sourceURL: sourceURL, animated: animated)
            analyticsService.trackActionEvent(.affiliate_product_selected, properties: nil)
        } else {
            showProductsDetailView(animated: animated)
        }
    }
    
    private func showProductsDetailView(animated: Bool) {
        let productsDetailViewModel = ProductDetailsViewModel(
            productsContext: productsContext, showService: dependencyContainer.showRepository,
            checkoutCartManager: dependencyContainer.checkoutCartManager, favoritesManager: favoritesManager,
            productsDetailAction: { [weak self] actionType in
                switch actionType {
                case .dismiss:
                    self?.navigationController?.dismiss(animated: animated)
                    self?.handleRequestedProductCompletion()
                    self?.onFinishedInteraction()
                case .selectBrand(let brand):
                    let completion = self?.onSelectBrand
                    self?.presentingNavigationController?.dismiss(animated: animated, completion: {
                        completion?(brand)
                    })
                case .showProductDetailView(let viewModel):
                    self?.showExpandedProductDetailView(productDetailViewModel: viewModel, animated: animated)
                case .productRequested(let completion):
                    self?.requestedProductID = completion.product.id
                    self?.onProductRequestSelectionAction?(true, completion.skuID)
                case .checkout(_):
                    self?.navigationController?.dismissPresentedViewControllerIfNeeded(animated: animated, completion: {
                        self?.checkoutCoordinator.start(animated: animated)
                    })
                case .share(let product):
                    var shareable = product.shareableObject
                    if let creatorID = self?.productsContext.creator?.id {
                        shareable.shareParameters = [.creatorID: creatorID]
                    }
                    self?.shareableProvider.generateShareURL(shareable)
                case .openAffiliateWebPage(let affiliateURL):
                    self?.showAffiliateProductWebView(sourceURL: affiliateURL, animated: animated)
                    self?.analyticsService.trackActionEvent(.ssense_product_selected, properties: nil)
                }
            }
        )
        
        let productsDetailViewController = ProductDetailsViewController(rootView: ProductDetailsView(viewModel: productsDetailViewModel))
        productsDetailViewController.onDissappear = { [weak self] in
            self?.onFinishedInteraction()
        }
        let navigationController = CustomNavigationController(rootViewController: productsDetailViewController)
        self.navigationController = navigationController
        
        presentingNavigationController?.present(navigationController, animated: animated)
    }
    
    private func handleRequestedProductCompletion() {
        guard productsContext.isRequestingGiftProduct else {
            return
        }
        onProductRequestSelectionAction?(requestedProductID != nil, nil)
    }
    
    private func showExpandedProductDetailView(productDetailViewModel: ProductDetailsViewModel, animated: Bool) {
        let expandedProductDetailView = ExpandedProductDetailsView(
            viewModel: productDetailViewModel,
            product: productDetailViewModel.selectedProduct,
            onClose: { [weak self] in
                self?.navigationController?.dismiss(animated: animated)
            }
        )
        let expandedProductDetailVC = UIHostingController(rootView: expandedProductDetailView)
        expandedProductDetailVC.modalPresentationStyle = .overFullScreen
        
        navigationController?.present(expandedProductDetailVC, animated: animated)
    }
    
    private func showAffiliateProductWebView(sourceURL: URL, animated: Bool) {
        presentingNavigationController?.dismissPresentedViewControllerIfNeeded(animated: animated, completion: {
            self.presentingNavigationController?.present(WebViewController(sourceURL: sourceURL), animated: animated)
        })
    }
}

//MARK: - Analytics
extension ProductsDetailCoordinator {
    func trackProductClickedEvent(productSelectable: ProductSelectableDTO) {
        var properties = productSelectable.selectedProduct.baseAnalyticsProperties
        properties[.show_id] = productSelectable.showID
        properties[.creator_id] = productSelectable.creator?.id
        properties[.creator_username] = productSelectable.creator?.formattedUsername
        properties[.product_position] = productSelectable.selectedIndex + 1
        
        analyticsService.trackActionEvent(.product_clicked, properties: properties)
    }
}
