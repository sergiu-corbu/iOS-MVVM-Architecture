//
//  ContentCreationCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.11.2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine

private class BrandsAndProductsSelectionStore {
    var selectedBrandsIDs: Set<String> {
        Set(currentSelection.keys)
    }
    
    var selectedProducts: Set<Product> {
        var products = Set<Product>()
        for (_, value) in currentSelection {
            products.formUnion(value)
        }
        
        return products
    }
    
    private var currentSelection = [String: Set<Product>]()
    
    func update(selectedBrandsIDs: Set<String>) {
        var newSelection = [String: Set<Product>]()
        selectedBrandsIDs.forEach { newSelection[$0] = currentSelection[$0] ?? Set<Product>() }
        currentSelection = newSelection
    }
    
    func update(selectedProducts: Set<Product>) {
        var newSelection = [String: Set<Product>]()
        var selectedProductsToParse = selectedProducts
        for (key, _) in currentSelection {
            let newProducts = selectedProductsToParse.filter { product in
                product.brand.id == key
            }
            newSelection[key] = newProducts
            //we substract the already parsed products so that we don't iterate them again
            selectedProductsToParse = selectedProductsToParse.subtracting(newProducts)
        }
        
        currentSelection = newSelection
    }
}

class ContentCreationCoordinator {
    
    //MARK: - Properties
    weak var navigationController: UINavigationController?
    let startFromGiftRequest: Bool
    
    //MARK: - Services
    let dependencyContainer: DependencyContainer
    private let pushNotificationHandler: PushNotificationsPermissionHandler
    private var contentCreationType: ContentCreationType!
    private var productsDetailCoordinator: ProductsDetailCoordinator?
    private let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    private lazy var brandsAndProductsSelectionStore = BrandsAndProductsSelectionStore()
    
    var onFinishedInteraction: (_ success: Bool) -> Void = {_ in}
    private var cancellables = Set<AnyCancellable>()
    
    init(dependencyContainer: DependencyContainer, startFromGiftingRequest: Bool = false, navigationController: UINavigationController?) {
        self.dependencyContainer = dependencyContainer
        self.pushNotificationHandler = dependencyContainer.pushNotificationsManager
        self.navigationController = navigationController
        self.startFromGiftRequest = startFromGiftingRequest
    }
    
    func start(animated: Bool = true, onFinishedInteraction: @escaping (_ success: Bool) -> Void) {
        self.onFinishedInteraction = onFinishedInteraction
        if startFromGiftRequest {
            showBrandsSelection(multipleSelectionEnabled: false, animated: animated)
        } else {
            showContentCreationView(animated: animated)
        }
    }
    
    private func showContentCreationView(animated: Bool) {
        let contentCreationTypeView = ContentCreationTypeView(actionHandler: { [weak self] action in
            switch action {
            case .cancel:
                self?.onFinishedInteraction(false)
            case .selectCreationType(let selectedContentCreationType):
                self?.contentCreationType = selectedContentCreationType
                self?.showBrandsSelection(animated: animated)
            case .requestProduct:
                self?.showBrandsSelection(multipleSelectionEnabled: false, animated: true)
            }
        })
        
        let contentCreationTypeVC = UIHostingController(rootView: contentCreationTypeView)
        contentCreationTypeVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(contentCreationTypeVC, animated: animated)
    }
    
    private func showBrandsSelection(multipleSelectionEnabled: Bool = true, animated: Bool) {
        let brandSelectionViewModel = BrandsSelectionViewModel(
            multipleSelectionEnabled: multipleSelectionEnabled,
            previouslySelectedBrandIDs: brandsAndProductsSelectionStore.selectedBrandsIDs,
            userProvider: dependencyContainer.userRepository,
            brandSelectionActionHandler: { [weak self] action in
                switch action {
                case .cancel:
                    self?.onFinishedInteraction(false)
                case .back(let currentBrandsSelection):
                    if self?.startFromGiftRequest == true {
                        self?.onFinishedInteraction(false)
                    } else {
                        self?.brandsAndProductsSelectionStore.update(selectedBrandsIDs: currentBrandsSelection)
                        self?.navigationController?.popViewController(animated: animated)
                    }
                case .brandsSelected(let selectedBrands):
                    self?.brandsAndProductsSelectionStore.update(selectedBrandsIDs: Set(selectedBrands.map(\.id)))
                    self?.showProductsSelection(selectedBrands, animated: animated)
                case .brandForGiftRequestSelected(let selectedBrand):
                    self?.brandsAndProductsSelectionStore.update(selectedBrandsIDs: Set([selectedBrand.id]))
                    self?.showProductsSelection([selectedBrand], isRequestingProducts: true, animated: animated)
                    self?.trackGiftingRequestEvent(
                        properties: [
                            .select_gifting_brand: AnalyticsService.mappedProperties(Brand(partnershipBrand: selectedBrand).baseAnalyticsProperties)
                        ]
                    )
                }
            }
        )
        
        let brandSelectionView = BrandsSelectionView(
            viewModel: brandSelectionViewModel,
            headerTitle: multipleSelectionEnabled ? Strings.ContentCreation.brandSelection : Strings.ContentCreation.brandForGiftRequestMessage
        )
        let brandsSelectionVC = UIHostingController(rootView: brandSelectionView)
        brandsSelectionVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(brandsSelectionVC, animated: animated)
        
        trackGiftingRequestEvent(properties: [.start_gifting_flow: true])
    }
    
    func showProductsSelection(_ partnershipBrands: [PartnershipBrand], isRequestingProducts: Bool = false, animated: Bool) {
        let productsSelectionViewModel = ProductsSelectionViewModel(
            partnershipBrands: partnershipBrands,
            isRequestingProducts: isRequestingProducts,
            previouslySelectedProducts: brandsAndProductsSelectionStore.selectedProducts,
            brandService: dependencyContainer.brandService,
            contentCreationService: dependencyContainer.contentCreationService,
            productSelectionActionHandler: { [weak self] action in
                switch action {
                case .back(let currentProductsSelection):
                    self?.brandsAndProductsSelectionStore.update(selectedProducts: currentProductsSelection)
                    self?.navigationController?.popViewController(animated: animated)
                case .cancel:
                    self?.showCancelActionAlert(animated: animated)
                case .productSelected(let product, let viewModel):
                    self?.showProductDetail(product, completionHandler: { [weak viewModel] isSelected, productSKUId in
                        self?.brandsAndProductsSelectionStore.update(selectedProducts: Set([product]))
                        self?.navigationController?.dismiss(animated: animated)
                        viewModel?.handleProductDetailSelection(product, skuID: productSKUId, isSelected: isSelected)
                        if isSelected {
                            self?.trackGiftingRequestEvent(properties: [.select_gifting_product: AnalyticsService.mappedProperties(product.baseAnalyticsProperties)])
                        }
                    }, animated: animated)
                case .interactionFinished(let completion):
                    self?.brandsAndProductsSelectionStore.update(selectedProducts: completion.products)
                    if isRequestingProducts {
                        self?.showGiftingRequest(products: Array(completion.products), productsSkuIDs: completion.productSKUIds, animated: animated)
                    } else {
                        self?.showSetupRoom(selectedProductsForCollaboration: completion.products, animated: animated)
                    }
                }
            }
        )
        
        let productsSelectionVC = UIHostingController(rootView: ProductsSelectionView(viewModel: productsSelectionViewModel))
        productsSelectionVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(productsSelectionVC, animated: animated)
    }
    
    private func showProductDetail(_ product: Product, completionHandler: @escaping (_ isSelected: Bool, _ skuID: String?) -> Void, animated: Bool) {
        productsDetailCoordinator = ProductsDetailCoordinator(
            productSelectable: ProductSelectableDTO(product: product, isRequestingGiftProduct: true),
            dependencyContainer: dependencyContainer,
            presentingNavigationController: navigationController,
            onFinishedInteraction: { [weak self] in
                self?.productsDetailCoordinator = nil
            }
        )
        productsDetailCoordinator?.onProductRequestSelectionAction = completionHandler
        productsDetailCoordinator?.start(animated: animated)
    }
    
    private func showSetupRoom(selectedProductsForCollaboration: Set<Product>, animated: Bool) {
        let setupRoomViewModel = SetupRoomViewModel(
            selectedProductsForCollaboration: selectedProductsForCollaboration,
            contentCreationType: self.contentCreationType,
            contentCreationService: dependencyContainer.contentCreationService,
            uploadService: dependencyContainer.uploadService
        )
        setupRoomViewModel.onBack.sink { [unowned self] in
            self.navigationController?.popViewController(animated: animated)
        }.store(in: &cancellables)
        setupRoomViewModel.onCancel.sink { [unowned self] in
            self.showCancelActionAlert(animated: animated)
        }.store(in: &cancellables)
        setupRoomViewModel.onShowPublished.sink { [weak self] show in
            switch self?.contentCreationType {
            case .recordedVideo:
                self?.showPublishedShowView(animated: animated)
            case .liveStream:
                self?.showScheduledLiveShowView(show: show, animated: animated)
            case .none:
                self?.onFinishedInteraction(false)
            }
        }.store(in: &cancellables)
        
        let setupRoomVC = SetupRoomViewController(viewModel: setupRoomViewModel)
        setupRoomVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(setupRoomVC, animated: animated)
    }
    
    private func showGiftingRequest(products: [Product], productsSkuIDs: [String], animated: Bool) {
        let giftingRequestViewModel = GiftingRequestViewModel(
            products: products, productsSkuIDs: productsSkuIDs, userRepository: dependencyContainer.userRepository,
            contentCreationService: dependencyContainer.contentCreationService,
            giftingRequestActionHandler: { [weak self] action in
                switch action {
                case .back:
                    self?.navigationController?.popViewController(animated: animated)
                case .cancel:
                    self?.showCancelActionAlert(animated: animated)
                case .submitRequest:
                    self?.trackGiftingProductsRequest(products)
                    self?.showProductRequestSuccess(animated: animated)
                }
            }
        )
        
        navigationController?.pushViewController(UIHostingController(rootView: GiftingRequestView(viewModel: giftingRequestViewModel)), animated: animated)
        trackGiftingRequestEvent(properties: [.review_gifting_delivery_details: true])
    }
    
    private func showPublishedShowView(animated: Bool) {
        let publishedShowView = PublishedShowView { [weak self] in
            self?.onFinishedInteraction(true)
        }
        let publishedShowVC = InteractivenessHostingController(rootView: publishedShowView, statusBarStyle: .lightContent)
        publishedShowVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(publishedShowVC, animated: animated)
    }
    
    private func showScheduledLiveShowView(show: Show, animated: Bool) {
        let scheduledLiveShowView = ScheduledLiveSuccessView(
            show: show, deeplinkProvider: dependencyContainer.deeplinkService,
            onFinishedInteraction: { [weak self] in
                guard let self else { return }
                Task(priority: .userInitiated) { @MainActor in
                    let pushNotificationStatus = await self.pushNotificationHandler.getCurrentAuthorizationStatus()
                    if pushNotificationStatus == .notDetermined {
                        self.showPushNotificationPermissionView(animated: animated)
                    } else {
                        self.onFinishedInteraction(true)
                    }
                }
            }
        )
        
        navigationController?.pushHostingController(scheduledLiveShowView, animated: animated)
    }
    
    func showProductRequestSuccess(animated: Bool) {
        let productRequestSucessView = ProductRequestSuccessView(onFinishedInteraction: { [weak self] in
            self?.onFinishedInteraction(false)
        })
        navigationController?.pushViewController(InteractivenessHostingController(rootView: productRequestSucessView, statusBarStyle: .lightContent), animated: animated)
        trackGiftingRequestEvent(properties: [.submit_gifting_success_screen: true])
    }
    
    func showPushNotificationPermissionView(animated: Bool) {
        let pushNotificationPermissionView = LegacyPushNotificationPermissionView(
            permissionType: .scheduledShowsReminder, pushNotificationsHandler: pushNotificationHandler,
            notificationsInteractionFinished: { [weak self] _ in
                self?.onFinishedInteraction(true)
            }
        )
        
        navigationController?.pushHostingController(pushNotificationPermissionView, animated: animated)
    }
}

private extension ContentCreationCoordinator {
    
    func showCancelActionAlert(animated: Bool) {
        let alertController = UIAlertController.dismissActionAlert(onReturn: { [weak self] in
            self?.navigationController?.dismiss(animated: animated)
        }, destructiveAction: { [weak self] in
            self?.onFinishedInteraction(false)
        })
        navigationController?.present(alertController, animated: animated)
    }
}

private extension ContentCreationCoordinator {
    
    func trackGiftingRequestEvent(properties: AnalyticsProperties) {
        analyticsService.trackActionEvent(.creator_gifting_steps, properties: properties)
    }
    
    func trackGiftingProductsRequest(_ products: [Product]) {
        var properties = AnalyticsProperties()
        var uniqueBrands = Set<Brand>()
        properties[.products] = products.map { product in
            uniqueBrands.insert(product.brand)
            return AnalyticsService.mappedProperties(product.baseAnalyticsProperties)
        }
        properties[.brands] = uniqueBrands.map { brand in
            return AnalyticsService.mappedProperties(brand.baseAnalyticsProperties)
        }
        
        trackGiftingRequestEvent(properties: [.submit_gifting_request: AnalyticsService.mappedProperties(properties)])
    }
}
