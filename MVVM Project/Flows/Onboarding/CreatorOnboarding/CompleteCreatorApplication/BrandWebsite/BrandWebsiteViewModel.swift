//
//  BrandWebsiteViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.11.2022.
//

import Foundation

class BrandWebsiteViewModel: ObservableObject {
    
    
    @Published var brandCanBePromoted = false
    @Published var brandWebsite: String = "" {
        willSet {
            if brandWebsiteError != nil {
                brandWebsiteError = nil
            }
        }
    }
    @Published var brandWebsiteError: Error?
    
    func validateBrandWebsite() {
        do {
            try brandWebsite.isValidWebsite()
        } catch {
            brandWebsiteError = error
        }
    }
    
    func discardUserInput() {
        brandCanBePromoted = false
        brandWebsite = ""
        brandWebsiteError = nil
    }
}
