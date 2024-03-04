//
//  CheckoutCoordinator.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 11.10.2023.
//

import Foundation
import Combine
import UIKit
import SwiftUI

final class CheckoutCoordinator {
    
    //MARK: - Properties
    weak var navigationController: UINavigationController?
    let analyticsContext: CheckoutAnalyticsContext?
    let onFinishedInteraction: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    private let internalNavigationController = CustomNavigationController()
    
    //MARK: - Services
    private let userSession: UserSession
    private let userRepository: UserRepository
    private let checkoutCartManager: CheckoutCartManager
    private let analyticsService: AnalyticsServiceProtocol
    private var mailActionController: MailActionSheetController?
    
    init(dependencyContainer: DependencyContainer, navigationController: UINavigationController?,
         analyticsContext: CheckoutAnalyticsContext? = nil, onFinishedInteraction: (() -> Void)? = nil) {
        
        self.navigationController = navigationController
        self.checkoutCartManager = dependencyContainer.checkoutCartManager
        self.userSession = dependencyContainer.userSession
        self.userRepository = dependencyContainer.userRepository
        self.analyticsService = AnalyticsService.shared
        self.analyticsContext = analyticsContext
        self.onFinishedInteraction = onFinishedInteraction
        
        internalNavigationController.modalPresentationStyle = .fullScreen
        setupCartBindings()
    }
    
    func start(animated: Bool) {
        self.showPreviewProductCart(animated: animated)
    }
    
    //Screens
    private func showPreviewProductCart(animated: Bool) {
        let previewProductCart = PreviewProductCartView(viewModel: BaseProductCheckoutViewModel(checkoutCartManager: checkoutCartManager), onDismiss: { [weak self] in
            self?.navigationController?.dismiss(animated: animated)
        }, onCheckout: { [weak self] discountContext in
            if let checkoutCart = self?.checkoutCartManager.checkoutCart {
                self?.presentCheckoutScreen(checkoutCart, discountContext: discountContext, animated: animated)
            }
        })
        internalNavigationController.setViewControllers([UIHostingController(rootView: previewProductCart)], animated: false)
        navigationController?.present(internalNavigationController, animated: animated)
    }
    
    //MARK: - Checkout
    private func presentCheckoutScreen(_ productCart: CheckoutCart, discountContext: DiscountContext?, animated: Bool) {
        let checkoutResultCompletion: (CheckoutActionType) -> Void = { [weak self] checkoutResult in
            switch checkoutResult {
            case .dismiss:
                self?.navigationController?.dismiss(animated: true)
            case .openEmail:
                self?.mailActionController = MailActionSheetController(presentationViewController: self?.navigationController?.presentedViewController, shouldComposeMessage: true)    
            case .success(let cart):
                self?.checkoutCartManager.clearCart()
                self?.showPurchaseCompletedView(
                    cart.violetCartId,
                    brandName: productCart.vendorName,
                    animated: true
                ) // this also dismisses the checkout screen
                if self?.userSession.isValid == true {
                    Task.detached(priority: .background) { [weak self] in
                        await self?.userRepository.getCurrentUser(loadFromCache: false)
                    }
                }
            case .error(let error):
                guard let vc = self?.navigationController?.presentedViewController else {
                    return
                }
                ToastDisplay.showErrorToast(from: vc, error: error)
            case .orderSubmitted(let cart):
                self?.trackOrderCompletedEvent(checkoutCart: cart)
            }
        }
        
        let checkoutViewModel = ProductCheckoutViewModel(
            checkoutCartManager: checkoutCartManager, userRepository: userRepository, discountContext: discountContext,
            checkoutResultActionHandler: checkoutResultCompletion
        )
        
        internalNavigationController.pushViewController(ProductCheckoutViewController(viewModel: checkoutViewModel), animated: animated)
    }
    
    //MARK: - Purchase Completed
    private func showPurchaseCompletedView(_ confirmationNumber: UInt, brandName: String, animated: Bool) {
        let purchaseCompletedView = PurchaseCompletedView(
            orderNumber: Int(confirmationNumber), brandName: brandName,
            onContinueShopping: { [weak self] in
                DispatchQueue.main.asyncAfter(seconds: 2) {
                    self?.userSession.showRateTheAppAlert()
                }
                self?.navigationController?.dismiss(animated: animated, completion: {
                    self?.onFinishedInteraction?()
                })
            }
        )
        internalNavigationController.pushViewController(
            InteractivenessHostingController(rootView: purchaseCompletedView, statusBarStyle: .lightContent),
            animated: animated
        )
        analyticsService.trackActionEvent(.checkout_cart_opened, properties: nil)
    }
}

struct CheckoutAnalyticsContext {
    let creator: Creator?
    let showID: String?
}

private extension CheckoutCoordinator {
    
    func setupCartBindings() {
        checkoutCartManager.onCartDeletedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigationController?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
}

//MARK: - Analytics
private extension CheckoutCoordinator {
    func trackOrderCompletedEvent(checkoutCart: CheckoutCart) {
        guard var totalPrice = checkoutCart.total else {
            return
        }
        
        totalPrice = totalPrice / 100
        let taxes = (checkoutCart.taxTotal ?? 0) / 100
        
        var properties = AnalyticsProperties()
        properties[.order_id] = checkoutCart.violetCartId
        properties[.affiliation] = checkoutCart.products.first?.brandName
        properties[.total] = totalPrice
        properties[.revenue] = totalPrice - taxes
        properties[.shipping] = (checkoutCart.shippingTotal ?? 0) / 100
        properties[.tax] = taxes
        properties[.currency] = checkoutCart.currency
        properties[.creator_username] = analyticsContext?.creator?.formattedUsername
        properties[.creator_id] = analyticsContext?.creator?.id
        properties[.show_id] = analyticsContext?.showID
        properties[.products] = checkoutCart.products.map { product in
            Dictionary(uniqueKeysWithValues: product.baseAnalyticsProperties.map { ($0.key.rawValue, $0.value)} )
        }
        
        analyticsService.trackActionEvent(.orderCompleted, properties: properties)
    }
}
