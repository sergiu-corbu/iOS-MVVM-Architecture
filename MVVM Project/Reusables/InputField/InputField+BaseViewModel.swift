//
//  InputField+BaseViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 10.01.2024.
//

import Foundation
import SwiftUI
import Combine

class BaseInputFieldsViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published private(set) var inputFields: [InputFieldType: String] = [:]
    @Published private(set) var inputFieldErrors: [InputFieldType: Error] = [:]
    let requiredInputTypes: Set<InputFieldType>
    
    let requiredInputCompletedPublisher: CurrentValueSubject<Bool, Never>
    
    private var fullAddressString: String {
        [value(for: .address), value(for: .secondaryAddress)].compactMap({$0}).joined(separator: " ")
    }
    var requiredFieldsCompleted: Bool {
        return requiredInputTypes.allSatisfy { requiredFieldType in
            if let value = value(for: requiredFieldType), !value.isEmpty {
                return true
            }
            return false
        }
    }
    
    init(requiredInputTypes: Set<InputFieldType>, inputCompleted: Bool = false) {
        self.requiredInputTypes = requiredInputTypes
        self.requiredInputCompletedPublisher = CurrentValueSubject(inputCompleted)
    }
    
    //MARK: - Field Methods
    func inputFieldBinding(for fieldType: InputFieldType) -> Binding<String> {
        return Binding(get: { [weak self] in
            if case .address = fieldType {
                return self?.fullAddressString ?? ""
            } else {
                return self?.value(for: fieldType) ?? ""
            }
        }, set: { [weak self] newValue in
            self?.inputFields.updateValue(newValue, forKey: fieldType)
            self?.removeError(for: fieldType)
        })
    }
    
    func inputFieldError(for fieldType: InputFieldType) -> Error? {
        return inputFieldErrors[fieldType]
    }
    
    @discardableResult
    func updateField(value: String, for fieldType: InputFieldType) -> String? {
        let value = inputFields.updateValue(value, forKey: fieldType)
        removeError(for: fieldType)
        return value
    }
    
    func value(for fieldType: InputFieldType) -> String? {
        return inputFields[fieldType]
    }
    
    func applyFields(_ inputFields: [InputFieldType:String]) {
        self.inputFields = inputFields
        self.inputFieldErrors = [:]
    }
    
    //MARK: - Helpers
    func reset() {
        inputFields = [:]
        removeErrors()
    }
    
    func setError(fieldType: InputFieldType, error: Error) {
        inputFieldErrors.updateValue(error, forKey: fieldType)
    }
    
    /// Returns `true` if the error was set
    @discardableResult
    func setErrorIfEmpty(fieldType: InputFieldType) -> Bool {
        let value = inputFields[fieldType]
        if value == nil || value?.isEmpty == true {
            setError(fieldType: fieldType, error: EmptyInputFieldError())
            return true
        }
        return false
    }
    
    func removeErrors() {
        inputFieldErrors = [:]
    }
    
    func removeError(for fieldType: InputFieldType) {
        if inputFieldErrors[fieldType] != nil {
            inputFieldErrors[fieldType] = nil
        }
    }
}
