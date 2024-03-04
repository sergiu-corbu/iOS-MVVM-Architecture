//
//  CustomerInputFieldsViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.12.2023.
//

import Foundation
import Combine

class CustomerInputFieldsViewModel: BaseInputFieldsViewModel {

    //MARK: - Properties
    let customerRole: User.Role?
    
    init(customerRole: User.Role?) {
        self.customerRole = customerRole
        super.init(requiredInputTypes: [.email, .firstName, .lastName], inputCompleted: customerRole != nil)
    }
    
    convenience init(customerRole: User.Role?, inputFields: [InputFieldType: String]?) {
        self.init(customerRole: customerRole)
        if let inputFields {
            applyFields(inputFields)
        }
    }
    
    func computeCustomer() -> Customer? {
        guard let email = value(for: .email),
              let firstName = value(for: .firstName),
              let lastName = value(for: .lastName) else {
            return nil
        }
        return Customer(email: email, firstName: firstName, lastName: lastName)
    }
    
    //MARK: - Functionality
    @discardableResult
    func validateCustomerFields() -> Bool {
        guard customerRole == nil else {
            requiredInputCompletedPublisher.send(true)
            return true
        }

        var inputCompleted = true
        for fieldType in requiredInputTypes {
            do {
                if case .email = fieldType {
                    try inputFields[.email]?.isValidEmail()
                }
                let didSetError = setErrorIfEmpty(fieldType: fieldType)
                if didSetError {
                    inputCompleted = false
                }
            } catch {
                setError(fieldType: fieldType, error: error)
                inputCompleted = false
            }
        }
        
        requiredInputCompletedPublisher.send(inputCompleted)
        return inputCompleted
    }
    
    //MARK: - Helpers
    func applyExistingCustomer(_ customer: User) {
        var inputFields = [InputFieldType:String]()
        inputFields[.firstName] = customer.firstName
        inputFields[.lastName] = customer.lastName
        inputFields[.phoneNumber] = customer.phoneNumber
        inputFields[.email] = customer.email
        applyFields(inputFields)
    }
    
    func applyExistingCustomer(shippingAddress: ShippingAddress) {
        var inputFields = [InputFieldType:String]()
        inputFields[.firstName] = shippingAddress.firstName
        inputFields[.lastName] = shippingAddress.lastName
        inputFields[.phoneNumber] = shippingAddress.phoneNumber
        applyFields(inputFields)
    }
}
