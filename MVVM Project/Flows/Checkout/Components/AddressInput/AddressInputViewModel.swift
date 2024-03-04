//
//  AddressInputViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.12.2023.
//

import Foundation

class AddressInputViewModel: BaseInputFieldsViewModel {
    
    //MARK: - Properties
    @Published var saveAddressCheckbox: Bool?
    let showAddressCheckbox: Bool
    let addressScope: AddressType
    lazy var addressSuggestionsViewModel = AddressSuggestionViewModel(onFinishedSearch: { [weak self] selectedAddress in
        self?.updateInputFields(with: selectedAddress, useISOCodeFormat: false)
    })
    
    //MARK: - Getters
    lazy var countriesList: [Country] = {
        return Locale.isoRegionCodes.compactMap {
            guard let countryName = Locale.current.localizedString(forRegionCode: $0) else {
                return nil
            }
            return Country(isoCode: $0, name: countryName)
        }
    }()
    
    init(addressScope: AddressType = .shipping, showAddressCheckbox: Bool = false) {
        self.addressScope = addressScope
        self.showAddressCheckbox = showAddressCheckbox
        var requiredInputTypes: [InputFieldType] = [.country, .address, .postalCode, .city, .state]
        if case .billing = addressScope {
            requiredInputTypes.append(contentsOf: [.firstName, .lastName])
        }
        super.init(requiredInputTypes: Set(requiredInputTypes))
        if showAddressCheckbox {
            saveAddressCheckbox = true
        }
    }
    
    convenience init(addressScope: AddressType, inputFields: [InputFieldType: String]?, saveAddressCheckbox: Bool?) {
        self.init(addressScope: addressScope)
        self.saveAddressCheckbox = saveAddressCheckbox
        if let inputFields {
            applyFields(inputFields)
        }
    }
    
    func computeAddress() -> CustomerAddress {
        return CustomerAddress(
            primaryAddress: value(for: .address),
            secondaryAddress: value(for: .secondaryAddress),
            city: value(for: .city) ?? "",
            postalCode: value(for: .postalCode) ?? "",
            country: getCountry(name: value(for: .country), useISOCodeFormat: false)?.isoCode ?? Locale.current.identifier,
            state: value(for: .state),
            phoneNumber: value(for: .phoneNumber), // billing only
            firstName: value(for: .firstName), //billing only
            lastName: value(for: .lastName) //billing only
        )
    }
    
    /// Silent check does not trigger the publisher
    @discardableResult
    func validateFieldsCompletion(silentCheck: Bool = false) -> Bool {
        var inputCompleted = true
        for fieldType in requiredInputTypes {
            let didSetError = setErrorIfEmpty(fieldType: fieldType)
            if didSetError {
                inputCompleted = false
            }
        }
        if !silentCheck {
            requiredInputCompletedPublisher.send(inputCompleted)
        }
        return inputCompleted
    }
    
    //Address Selection Precompletion
    func updateInputFields(with precompletedAddress: CustomerAddress, useISOCodeFormat: Bool = true) {
        var precompletedFields = [InputFieldType:String]()
        precompletedFields[.address] = precompletedAddress.primaryAddress
        precompletedFields[.secondaryAddress] = precompletedAddress.secondaryAddress
        precompletedFields[.city] = precompletedAddress.city
        precompletedFields[.postalCode] = precompletedAddress.postalCode
        precompletedFields[.state] = precompletedAddress.state
        precompletedFields[.country] = getCountry(name: precompletedAddress.country, useISOCodeFormat: useISOCodeFormat)?.name
        
        applyFields(precompletedFields)
        validateFieldsCompletion()
    }
    
    func updateFieldsCompletionState() {
        requiredInputCompletedPublisher.send(requiredFieldsCompleted)
    }
    
    private func getCountry(name: String?, useISOCodeFormat: Bool) -> Country? {
        return countriesList.first(where: { (useISOCodeFormat ? $0.isoCode : $0.name) == name })
    }
}

#if DEBUG
extension AddressInputViewModel {
    static let shippingVM = AddressInputViewModel(addressScope: .shipping, showAddressCheckbox: true)
    static let billingVM = AddressInputViewModel(addressScope: .billing)
}
#endif
