//
//  GiftingRequestViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.07.2023.
//

import Foundation

class GiftingRequestViewModel: ObservableObject {
    
    //MARK: - Properties
    let products: [Product]
    let productsSkuIDs: [String]
    
    @Published var country: String = "" {
        willSet { updateTypingField(fieldType: .country, newValue: newValue) }
    }
    @Published var city: String = "" {
        willSet { updateTypingField(fieldType: .city, newValue: newValue) }
    }
    @Published var address: String = "" {
        willSet { updateTypingField(fieldType: .address, newValue: newValue) }
    }
    @Published var postalCode: String = "" {
        willSet { updateTypingField(fieldType: .postalCode, newValue: newValue) }
    }
    @Published var state: String = "" //NOTE: is optional
    @Published var phoneNumber: String = "" {
        willSet { updateTypingField(fieldType: .postalCode, newValue: newValue) }
    }
    
    @Published var inputFieldsErrors = [InputFieldType:Error]()
    @Published var error: Error?
    @Published var isLoading = false
    
    private(set) var user: User?
    
    //MARK: - Computed
    var allFieldsCompleted: Bool {
        return !country.isEmpty && !city.isEmpty && !address.isEmpty && !postalCode.isEmpty && !phoneNumber.isEmpty
    }
    
    //MARK: - Actions
    enum Action {
        case back
        case cancel
        case submitRequest
    }
    let giftingRequestActionHandler: (Action) -> Void
    
    //MARK: - Services
    let userRepository: UserRepository
    let contentCreationService: ContentCreationServiceProtocol
    
    init(products: [Product], productsSkuIDs: [String], userRepository: UserRepository, contentCreationService: ContentCreationServiceProtocol, giftingRequestActionHandler: @escaping (Action) -> Void) {
        self.products = products
        self.productsSkuIDs = productsSkuIDs
        self.userRepository = userRepository
        self.contentCreationService = contentCreationService
        self.giftingRequestActionHandler = giftingRequestActionHandler
        
        Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            await self.loadExistingData()
        }
    }
    
    func submitGiftingRequest() {
        guard allFieldsCompleted else {
            return
        }
            
        isLoading = true
        Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else {
                self?.isLoading = false
                return
            }
            
            do {
                try await self.userRepository.updateUser(values: [.phoneNumber: phoneNumber])
                try await self.contentCreationService.requestGifting(
                    skuIDs: productsSkuIDs,
                    shippingAddress: ShippingAddress(primaryAddress: address, city: city, postalCode: postalCode, country: country, state: state.nilIfEmpty)
                )
                self.user?.phoneNumber = phoneNumber
                giftingRequestActionHandler(.submitRequest)
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    
    func inputFieldValue(type: InputFieldType) -> String {
        switch type {
        case .country: return country
        case .city: return city
        case .address: return  address
        case .postalCode: return postalCode
        case .phoneNumber: return phoneNumber
        case .state: return state
        default: return ""
        }
    }
    
    func updateInputFieldState(previousField: InputFieldType?) {
        guard let previousField else {
            return
        }
        let previousValue = inputFieldValue(type: previousField)
        inputFieldsErrors[previousField] = previousValue.isEmpty ? DeliveryContactError.fieldIsEmpty : nil
    }
    
    private func updateTypingField(fieldType: InputFieldType, newValue: String) {
        if newValue != inputFieldValue(type: fieldType) {
            inputFieldsErrors[fieldType] = nil
        }
    }
    
    @MainActor private func loadExistingData() async {
        guard let user = await userRepository.getCurrentUser(loadFromCache: true),
              let primaryAddress = user.addresses.first else {
            return
        }
        
        self.country = primaryAddress.country
        self.city = primaryAddress.city
        self.address = primaryAddress.primaryAddress ?? ""
        self.postalCode = primaryAddress.postalCode
        self.phoneNumber = user.phoneNumber ?? ""
        self.state = primaryAddress.state ?? ""
        
    }
}
