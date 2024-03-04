//
//  ApplePayPaymentHandler.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 24.02.2023.
//

import Foundation
import StripeApplePay
import Stripe
import PassKit

final class ApplePayPaymentHandler: NSObject {
    
    //MARK: - Actions
    enum PaymentResult {
        case success(CheckoutCart)
        case failure(Error?)
        case orderSubmitted(CheckoutCart)
        case cancelled
    }
    
    //MARK: - Payment properties
    private var checkoutCart: CheckoutCart
    private var shippingMethodsResponse: ShippingMethodsResponse?
    private let purchasedBrandName: String
    private var paymentInformation: PKPayment?
    
    let paymentCallback: (PaymentResult) -> Void
    private weak var paymentAuthorizationController: PKPaymentAuthorizationController?
    
    //MARK: - Summary Items
    private var summaryItems: [PKPaymentSummaryItem] {
        return checkoutCart.bags.first!.skus.map { sku in
            PKPaymentSummaryItem(
                label: sku.productName,
                amount: NSDecimalNumber(value: sku.salePrice / 100)
            )
        }
    }
    private func paymentSummaryItem(totalAmount: NSDecimalNumber) -> PKPaymentSummaryItem {
        return PKPaymentSummaryItem(label: Strings.Payment.paymentLabel(brandName: purchasedBrandName), amount: totalAmount)
    }
    
    private let requiredContactFields: Set<PKContactField> = [.name, .emailAddress, .postalAddress]
    
    //MARK: - Services
    private let checkoutService: CheckoutServiceProtocol
    
    init(checkoutCart: CheckoutCart, purchasedBrandName: String, checkoutService: CheckoutServiceProtocol, callback: @escaping (PaymentResult) -> Void) {
        
        self.checkoutCart = checkoutCart
        self.purchasedBrandName = purchasedBrandName
        self.checkoutService = checkoutService
        self.paymentCallback = callback
        super.init()
        
        StripeAPI.defaultPublishableKey = Constants.ApplePay.STRIPE_KEY
    }
    
    func showApplePay() {
        guard StripeAPI.deviceSupportsApplePay() else {
            let passKitLibrary = PKPassLibrary()
            if passKitLibrary.isSecureElementPassActivationAvailable {
                passKitLibrary.openPaymentSetup()
            } else {
                paymentCallback(.failure(PaymentError.applePayError))
            }
            return
        }
        
        let paymentRequest = StripeAPI.paymentRequest(withMerchantIdentifier: Constants.ApplePay.MERCHANT_IDENTIFIER,
                                                      country: Locale.current.region?.identifier ?? Constants.ApplePay.DEFAULT_REGION,
                                                      currency: Constants.ApplePay.DEFAULT_CURRENCY)
        
        paymentRequest.requiredBillingContactFields = requiredContactFields
        paymentRequest.requiredShippingContactFields = requiredContactFields
        paymentRequest.paymentSummaryItems = configurePaymentSummaryItems(checkoutCart: checkoutCart)
        paymentRequest.shippingType = .shipping

        if let applePayContext = STPApplePayContext(paymentRequest: paymentRequest, delegate: self) {
            applePayContext.presentApplePay { [weak self] in
                let child = Mirror(reflecting: applePayContext).descendant("authorizationController")
                self?.paymentAuthorizationController = child as? PKPaymentAuthorizationController
            }
        } else {
            paymentCallback(.failure(PaymentError.applePayError))
        }
    }
}

//MARK: - Payment helpers
private extension ApplePayPaymentHandler {
    
    func updateShippingAddress(contact: PKContact) async throws -> PaymentIntentResponse {
        return try await checkoutService.createPaymentIntent(
            cartId: checkoutCart.violetCartId,
            shippingAddress: try ShippingAddress(contact: contact)
        )
    }
    
    func configurePaymentSummaryItems(checkoutCart: CheckoutCart) -> [PKPaymentSummaryItem] {
        // item description
        var summaryItems: [PKPaymentSummaryItem] = summaryItems
        // discount
        if let discount = checkoutCart.discount, checkoutCart.discountTotal > 0 {
            let discountSummary = PKPaymentSummaryItem(
                label: Strings.Payment.discount + " \"\(discount.code)\"",
                amount: NSDecimalNumber(value: -(checkoutCart.discountTotal / 100))
            )
            summaryItems.append(discountSummary)
        }
        // shipping
        if let shippingTotal = checkoutCart.shippingTotal {
            let shippingSummary = PKPaymentSummaryItem(
                label: Strings.Payment.shipping,
                amount: NSDecimalNumber(value: shippingTotal / 100)
            )
            summaryItems.append(shippingSummary)
        }
        // tax
        if let taxTotal = checkoutCart.taxTotal {
            let taxesSummary = PKPaymentSummaryItem(label: Strings.Payment.tax, amount: NSDecimalNumber(value: taxTotal / 100))
            summaryItems.append(taxesSummary)
        }
        // total
        let price = checkoutCart.total ?? checkoutCart.subTotal
        let paymentSummary = paymentSummaryItem(totalAmount: NSDecimalNumber(value: price / 100))
        summaryItems.append(paymentSummary)
        return summaryItems
    }
    
    func configureShippingMethods(_ shippingMethods: [ShippingMethod]) -> [PKShippingMethod] {
        return shippingMethods.map {
            let method = PKShippingMethod(label: $0.label, amount: NSDecimalNumber(value: $0.price / 100))
            method.identifier = $0.shippingMethodId
            method.detail = $0.carrier
            return method
        }
    }
}

//MARK: - Delegate methods
extension ApplePayPaymentHandler: STPApplePayContextDelegate {
   
    //MARK: - Payment method
    func applePayContext(_ context: StripeApplePay.STPApplePayContext,
                         didCreatePaymentMethod paymentMethod: StripePayments.STPPaymentMethod,
                         paymentInformation: PKPayment,
                         completion: @escaping StripeApplePay.STPIntentClientSecretCompletionBlock) {
        
        do {
            try validateCustomerContact(paymentInformation.shippingContact, contactType: .shipping)
            try validateCustomerContact(paymentInformation.billingContact, contactType: .billing)
            self.paymentInformation = paymentInformation
            completion(checkoutCart.paymentIntentClientSecret, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    //MARK: - Shipping
    func applePayContext(_ context: STPApplePayContext,
                         didSelectShippingContact contact: PKContact,
                         handler: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        
        Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                let response = try await self.updateShippingAddress(contact: contact)
                self.checkoutCart = response.productCart
                
                var shippingContactUpdate = PKPaymentRequestShippingContactUpdate(
                    errors: nil,
                    paymentSummaryItems: self.configurePaymentSummaryItems(checkoutCart: response.productCart),
                    shippingMethods: []
                )

                guard let shippingMethods = response.shippingMethods?.first?.shippingMethods else {
                    shippingContactUpdate.errors = [PaymentError.missingShippingInformation]
                    handler(shippingContactUpdate)
                    return
                }
                shippingContactUpdate.shippingMethods = self.configureShippingMethods(shippingMethods)
                handler(shippingContactUpdate)
            } catch {
                handler(processShippingContactError(error))
            }
        }
    }
    
    func applePayContext(_ context: STPApplePayContext,
                         didSelect shippingMethod: PKShippingMethod,
                         handler: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        
        guard let shippingMethodId = shippingMethod.identifier, let bagId = checkoutCart.bags.first?.id else {
            handler(PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: configurePaymentSummaryItems(checkoutCart: checkoutCart)))
            return
        }
        Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                let updatedCart = try await self.checkoutService.updateShippingMethod(
                    cartId: self.checkoutCart.violetCartId, [(bagId, shippingMethodId)]
                )
                self.checkoutCart = updatedCart
                handler(PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: self.configurePaymentSummaryItems(checkoutCart: updatedCart)))
            } catch {
                handler(PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: self.configurePaymentSummaryItems(checkoutCart: self.checkoutCart)))
            }
        }
    }
    
    //MARK: - Payment result
    func applePayContext(_ context: STPApplePayContext,
                         willCompleteWithResult authorizationResult: PKPaymentAuthorizationResult,
                         handler: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        switch authorizationResult.status {
        case .success:
            Task(priority: .userInitiated) { @MainActor [weak self] in
                guard let self else { return }
                do {
                    guard let paymentInformation else {
                        throw PaymentError.missingPaymentIntent
                    }
                    let updatedcheckoutCart = try await self.checkoutService.submitCart(
                        self.checkoutCart.violetCartId,
                        shippingAddress: try ShippingAddress(contact: paymentInformation.shippingContact),
                        billingAddress: try BillingAddress(contact: paymentInformation.billingContact),
                        customer: try Customer(pkContact: paymentInformation.shippingContact)
                    )
                    self.checkoutCart = updatedcheckoutCart
                    self.paymentCallback(.orderSubmitted(updatedcheckoutCart))
                    handler(PKPaymentAuthorizationResult(status: .success, errors: nil))
                } catch {
                    paymentCallback(.failure(error))
                    handler(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
                }
            }
        case .failure:
            paymentCallback(.failure(authorizationResult.errors.first))
            handler(PKPaymentAuthorizationResult(status: .failure, errors: authorizationResult.errors))
        default: break
        }
    }
    
    func applePayContext(_ context: StripeApplePay.STPApplePayContext, didCompleteWith status: StripePayments.STPPaymentStatus, error: Error?) {
        switch status {
        case .error:
            paymentCallback(.failure(error))
        case .success:
            paymentCallback(.success(checkoutCart))
        case .userCancellation:
            paymentCallback(.cancelled)
        }        
    }
}

//MARK: - Error handling
private extension ApplePayPaymentHandler {
    
    func processShippingContactError(_ error: Error) -> PKPaymentRequestShippingContactUpdate {
        guard let backendError = error as? NetworkError else {
            dismissAndSendError(error)
            return PKPaymentRequestShippingContactUpdate(errors: [error], paymentSummaryItems: configurePaymentSummaryItems(checkoutCart: checkoutCart), shippingMethods: [])
        }
        
        if backendError.statusCode == 422, backendError.errorCodeString == NetworkError.ErrorType.violetError {
            dismissAndSendError(error)
            return PKPaymentRequestShippingContactUpdate(errors: [error], paymentSummaryItems: configurePaymentSummaryItems(checkoutCart: checkoutCart), shippingMethods: [])
        }
        
        let shippingError = PKPaymentRequest.paymentShippingAddressUnserviceableError(
            withLocalizedDescription: PaymentError.deliveryNotAvailable.errorDescription
        )
        
        return PKPaymentRequestShippingContactUpdate(
            errors: [shippingError],
            paymentSummaryItems: configurePaymentSummaryItems(checkoutCart: checkoutCart),
            shippingMethods: []
        )
    }
    
    func dismissAndSendError(_ error: Error?) {
        paymentAuthorizationController?.dismiss()
        paymentCallback(.failure(error))
    }
    
    func validateCustomerContact(_ contact: PKContact?, contactType: CustomerContactType) throws {
        guard let address = contact?.postalAddress else {
            throw contactType.contactError
        }
        
        if address.city.isEmpty || address.postalCode.isEmpty {
            throw contactType.contactError
        }
    }
}

typealias AddressType = CustomerContactType

enum CustomerContactType: String {
    case shipping
    case billing
    
    var name: String {
        switch self {
        case .shipping: Strings.Payment.shippingAddress
        case .billing: Strings.Payment.billingAddress
        }
    }
    
    var contactError: Error {
        switch self {
        case .shipping:
            return PKPaymentRequest.paymentShippingAddressInvalidError(
                withKey: "shipping_error",
                localizedDescription: PaymentError.missingShippingInformation.errorDescription
            )
        case .billing:
            return PKPaymentRequest.paymentBillingAddressInvalidError(
                withKey: "billing_error",
                localizedDescription: PaymentError.missingBillingInformation.errorDescription
            )
        }
    }
}
