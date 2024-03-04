//
//  BaseProductCheckoutViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 05.01.2024.
//

import Foundation
import Combine

class BaseProductCheckoutViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var discountCodeString: String = ""
    /// The discount state that results from the first Discount object in the bag
    /// - Note: Currently we are making sure that each cart contains a single bag.
    /// - Important: The current implementation works under the assumption that only one discount code is applied at a given time.
    @Published var discountState: DiscountCodeState = .idle
    @Published private(set) var removingProductSKUID: UInt?
    var cancellables = Set<AnyCancellable>()
    
    //MARK: - Services
    let checkoutCartManager: CheckoutCartManager
    
    //MARK: - Computed
    var discountContext: DiscountContext {
        return DiscountContext(discountCode: discountCodeString, discountState: discountState)
    }
    var isDiscountFieldDisabled: Bool {
        switch discountState {
        case .idle, .error:
            return false
        case .loading, .validCode, .invalidCode:
            return true
        }
    }
    var isCheckoutButtonDisabled: Bool {
        return discountState.isLoading || removingProductSKUID != nil
    }
    
    var productCart: CheckoutCart? {
        return checkoutCartManager.checkoutCart
    }
    var discountedPrice: Double? {
        productCart?.total ?? productCart?.subTotal
    }
    
    init(checkoutCartManager: CheckoutCartManager) {
        self.checkoutCartManager = checkoutCartManager
        setup()
    }
    
    private func setup() {
        checkoutCartManager.objectWillChange.receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        computeDiscountState()
    }
    
    //MARK: - Product Actions
    @MainActor func removeProductFromCart(productSKUId: UInt) async throws {
        defer {
            removingProductSKUID = nil
        }
        removingProductSKUID = productSKUId
        try await checkoutCartManager.removeProductFromCart(productSKUId: productSKUId)
    }
    
    //MARK: - Discount
    func applyCartDiscount() {
        discountState = .loading
        Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let discountCode = self?.discountCodeString else { return }
            do {
                try await self?.checkoutCartManager.applyDiscountCode(discountCode)
                self?.computeDiscountState()
            } catch {
                self?.discountState = .error(error: error)
            }
        }
    }
    
    func clearCartDiscount() {
        if productCart?.discount == nil {
            return
        }
        discountState = .loading
        Task(priority: .userInitiated) { @MainActor [weak self] in
            do {
                try await self?.checkoutCartManager.removeDiscount()
                self?.discountCodeString = ""
                self?.computeDiscountState()
            } catch {
                self?.discountState = .error(error: error)
            }
        }
    }
    
    private func computeDiscountState() {
        guard let discount = productCart?.discount else {
            discountState = .idle
            return
        }
        switch discount.status {
        case .applied, .pending:
            discountState = .validCode(discount: discount)
            discountCodeString = discount.code
        case .invalid, .notSupported, .error:
            discountState = .invalidCode(discount: discount)
            discountCodeString = discount.code
        case .expired:
            discountState = .invalidCode(discount: discount)
            discountCodeString = discount.code
        }
    }
}

struct DiscountContext {
    let discountCode: String
    let discountState: DiscountCodeState
}

#if DEBUG
extension BaseProductCheckoutViewModel {
    static let previewVM = BaseProductCheckoutViewModel(checkoutCartManager: .mocked)
}
#endif
