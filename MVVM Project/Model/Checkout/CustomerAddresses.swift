//
//  CustomerAddresses.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 21.02.2023.
//

import Foundation
import PassKit
import MapKit

typealias ShippingAddress = CustomerAddress
typealias BillingAddress = CustomerAddress

struct CustomerAddress: Codable, Hashable {
    
    let primaryAddress: String?
    var secondaryAddress: String?
    let city: String
    let postalCode: String
    let country: String
    var state: String?
    
    var phoneNumber: String?
    var firstName: String?
    var lastName: String?

    var fullName: String? {
        return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
    var fullAddress: String? {
        [primaryAddress, secondaryAddress].compactMap { $0 }.joined(separator: " ")
    }
    var checkouShippingAddress: String {
        return [fullAddress, postalCode, city, state, country].compactMap { $0 }.joined(separator: ", ")
    }
    
    enum CodingKeys: String, CodingKey {
        case city
        case country
        case postalCode
        case state
        case firstName
        case lastName
        case phoneNumber = "phone"
        case primaryAddress = "address1"
        case secondaryAddress = "address2"
    }
}

extension CustomerAddress {
    
    init(contact: PKContact?) throws {
        guard let address = contact?.postalAddress else {
            throw PaymentError.missingContactInformation
        }
        self.city = address.city
        self.country = address.isoCountryCode
        self.state = address.state
        self.postalCode = address.postalCode
        self.primaryAddress = address.street
        self.secondaryAddress = address.subAdministrativeArea
        self.firstName = contact?.name?.givenName ?? ""
        self.lastName = contact?.name?.familyName ?? ""
        self.phoneNumber = contact?.phoneNumber?.stringValue
    }
    
    init?(placemark: MKPlacemark) {
        guard let country = placemark.country, let city = placemark.locality else {
            return nil
        }
        
        self.primaryAddress = placemark.thoroughfare
        self.secondaryAddress = placemark.subThoroughfare
        self.state = placemark.administrativeArea
        self.city = city
        self.postalCode = placemark.postalCode ?? ""
        self.country = country
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(city, forKey: .city)
        try container.encode(country, forKey: .country)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(state, forKey: .state)
        try container.encodeIfPresent(primaryAddress, forKey: .primaryAddress)
        try container.encodeIfPresent(secondaryAddress, forKey: .secondaryAddress)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
    }
}

struct InvalidCustomerAddressError: LocalizedError {
    
    var errorDescription: String? {
        return "Could not find the location"
    }
}

extension Locale {
    
    var currentCountryName: String {
        if let region {
            return localizedString(forRegionCode: region.identifier) ?? identifier
        }
        return identifier
    }
}

#if DEBUG
extension CustomerAddress {
    
    static let sampleAddress = CustomerAddress(primaryAddress: "Lunii 2A", secondaryAddress: nil, city: "Cluj", postalCode: "443000", country: "Romania", state: "CJ", firstName: "Sergiu", lastName: "C")
}
#endif
