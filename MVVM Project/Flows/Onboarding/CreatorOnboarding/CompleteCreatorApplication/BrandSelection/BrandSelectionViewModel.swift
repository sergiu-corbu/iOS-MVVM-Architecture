//
//  BrandSelectionViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.11.2022.
//

import Foundation
import Combine

class BrandSelectionViewModel: ObservableObject {
    
    @Published var input: String = ""
    @Published var suggestedBrands: [Brand] = []
    @Published var isSearchingForBrand = false
    @Published private(set) var selectedBrands: Set<Brand> = []
    
    let backendErrorSubject = PassthroughSubject<Error, Never>()
    
    private var searchBrandsTask: Task<Void, Never>?
    
    let authenticationService: AuthenticationServiceProtocol
    let brandService: BrandServiceProtocol
    
    init(authenticationService: AuthenticationServiceProtocol, brandService: BrandServiceProtocol) {
        self.authenticationService = authenticationService
        self.brandService = brandService
    }
    
    var showSelectedBrands: Bool {
        return !selectedBrands.isEmpty && input.isEmpty
    }
    var showMissingBrand: Bool {
        return !input.isEmpty && suggestedBrands.isEmpty && searchBrandsTask?.isCancelled == false
    }
    
    private var trimmedInput: String {
        return input.trimmingCharacters(in: .whitespaces)
    }
    
    func addBrand(_ brand: Brand?) {
        if let brand {
            selectedBrands.insert(brand)
        } else {
            selectedBrands.insert(Brand(name: trimmedInput))
        }
        input = ""
        suggestedBrands = []
    }
    
    func removeBrand(_ brand: Brand) {
        selectedBrands.remove(brand)
    }
    
    func removeSelectedBrands() {
        selectedBrands.removeAll()
    }
    
    func searchBrand() {
        searchBrandsTask?.cancel()
        guard !trimmedInput.isEmpty else {
            suggestedBrands = []
            return
        }
        isSearchingForBrand = true
        searchBrandsTask = Task(priority: .userInitiated) { @MainActor in
            do {
                let suggestedBrands = try await brandService.getBrands(query: trimmedInput, pageSize: nil)
                self.suggestedBrands = suggestedBrands.isEmpty ? [] : suggestedBrands
            } catch {
                backendErrorSubject.send(error)
            }
            isSearchingForBrand = false
        }
    }
}
