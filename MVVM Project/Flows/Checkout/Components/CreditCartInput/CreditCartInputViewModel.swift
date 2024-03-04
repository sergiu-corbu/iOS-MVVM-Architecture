//
//  CreditCartInputViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.12.2023.
//

import Foundation
import Stripe

class CreditCartInputViewModel: BaseInputFieldsViewModel {
    
    //MARK: - Properties
    @Published var creditCardParameters: STPPaymentMethodParams?
    let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    init(creditCardParameters: STPPaymentMethodParams? = nil) {
        self.creditCardParameters = creditCardParameters
        super.init(requiredInputTypes: [.creditCard])
    }
    
    @discardableResult
    func validateCreditCardParameters() -> Bool {
        guard let creditCardParameters else {
            setError(fieldType: .creditCard, error: CreditCardError())
            requiredInputCompletedPublisher.send(false)
            return false
        }
        var isValidCreditCardInput = false
        switch STPCardValidator.validationState(forCard: STPCardParams(paymentMethodParams: creditCardParameters)) {
        case .valid:
            removeError(for: .creditCard)
            isValidCreditCardInput = true
        case .invalid, .incomplete:
            setError(fieldType: .creditCard, error: CreditCardError())
        }
        requiredInputCompletedPublisher.send(isValidCreditCardInput)
        return isValidCreditCardInput
    }
    
    func update(with creditCardParameters: STPPaymentMethodParams?) {
        self.creditCardParameters = creditCardParameters
    }
    
    struct CreditCardError: LocalizedError {
        let errorDescription: String? = "Credit Card is invalid or incomplete"
    }
}

extension STPPaymentMethodCardParams {
    var label: String {
        return STPCardBrandUtilities.stringFrom(STPCardValidator.brand(forNumber: self.number ?? "")) ?? "Unknown"
    }
}
