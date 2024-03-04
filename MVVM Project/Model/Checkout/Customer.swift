//
//  Customer.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 21.02.2023.
//

import Foundation
import PassKit

struct Customer: Codable {
    let email: String
    let firstName: String
    let lastName: String
}

extension Customer {
    
    static let sampleCustomer = Customer(email: "sergiu.corbu@tapptitude.com", firstName: "Sergiu", lastName: "Corbu")
    
    init(pkContact: PKContact?) throws {
        guard let email = pkContact?.emailAddress,
              let firstName = pkContact?.name?.givenName,
              let lastName = pkContact?.name?.familyName else {
            
            throw PaymentError.missingContactInformation
        }
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
}
