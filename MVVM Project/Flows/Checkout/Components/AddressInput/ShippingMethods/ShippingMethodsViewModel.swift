//
//  ShippingMethodsViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.01.2024.
//

import Foundation

class ShippingMethodsViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published private(set) var shippingMethods: [ShippingMethod]
    @Published private(set) var selectedShippingMethod: ShippingMethod?
    @Published private(set) var shippingMethodSelectionState: ShippingMethodSelectionState = .enterShippingAddress
        
    //MARK: - Services
    let checkoutService: CheckoutServiceProtocol?
    
    init(checkoutService: CheckoutServiceProtocol) {
        self.shippingMethods = []
        self.checkoutService = checkoutService
    }
    
    init(shippingMethods: [ShippingMethod]) {
        self.shippingMethods = shippingMethods
        self.checkoutService = nil
    }
    
    //MARK: - Functionality
    func selectShippingMethod(_ shippingMethod: ShippingMethod) {
        defer {
            shippingMethodSelectionState = .shippingMethodSelected(shippingMethod.price)
        }
        if selectedShippingMethod == shippingMethod {
            return
        }
        selectedShippingMethod = shippingMethod
    }
    
    func validateShippingMethodSelected() -> Bool {
        return selectedShippingMethod != nil
    }
    
    @MainActor func getShippingMethods(cartID: UInt, preselectedShippingMethodID: String? = nil) async throws {
        shippingMethodSelectionState = .calculating
        do {
            shippingMethods = try await checkoutService?.getShippingMethods(cartId: cartID).first?.shippingMethods ?? []
            if let preselectedShippingMethod = shippingMethods.first(where: { $0.shippingMethodId == preselectedShippingMethodID }) ?? shippingMethods.first {
                selectShippingMethod(preselectedShippingMethod)
            }
        } catch {
            shippingMethodSelectionState = .enterShippingAddress
        }
    }
    
    @discardableResult
    @MainActor func updateShippingMethod(cart: CheckoutCart?, selectedShippingMethodID: String) async throws -> CheckoutCart? {
        guard let cartID = cart?.violetCartId, let bagID = cart?.bags.first?.id else {
            throw CheckoutError.missingCart
        }
        
        shippingMethodSelectionState = .calculating
        do {
            let cart =  try await checkoutService?.updateShippingMethod(cartId: cartID, [(bagID, selectedShippingMethodID)])
            shippingMethodSelectionState = .shippingMethodSelected(cart?.bags.first?.shippingMethod?.price ?? .zero)
            return cart
        } catch {
            if let price = shippingMethods.first?.price {
                shippingMethodSelectionState = .shippingMethodSelected(price)
            } else {
                shippingMethodSelectionState = .enterShippingAddress
            }
            
            throw error
        }
    }
        
    func resetShippingMethods() {
        shippingMethods = []
        selectedShippingMethod = nil
        shippingMethodSelectionState = .enterShippingAddress
    }
}

#if DEBUG
extension ShippingMethodsViewModel {
    static let previewViewModel = ShippingMethodsViewModel(shippingMethods: [.economy, .standard])
}
#endif
