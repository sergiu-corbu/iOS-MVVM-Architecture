//
//  BrandsSelectionViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.11.2022.
//

import Foundation

class BrandsSelectionViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var progressStates = ProgressState.createStaticStates(currentIndex: 1)
    @Published var selectedBrandIDs = Set<String>() {
        didSet {
            updateProgresState()
        }
    }
    private(set) var brands = [PartnershipBrand]()
    let multipleSelectionEnabled: Bool
    
    //MARK: - Actions
    enum Action {
        case cancel
        case back(_ currentBrandsIDsSelection: Set<String>)
        case brandsSelected([PartnershipBrand])
        case brandForGiftRequestSelected(PartnershipBrand)
    }
    let brandSelectionActionHandler: (Action) -> Void
        
    init(multipleSelectionEnabled: Bool,
         previouslySelectedBrandIDs: Set<String> = Set<String>(),
         userProvider: UserProvider,
         brandSelectionActionHandler: @escaping (Action) -> Void) {
        self.multipleSelectionEnabled = multipleSelectionEnabled
        self.selectedBrandIDs = previouslySelectedBrandIDs
        self.brandSelectionActionHandler = brandSelectionActionHandler
        
        self.updateProgresState()
        Task(priority: .userInitiated) { @MainActor [weak self] in
            if var brands = await userProvider.getCurrentUser(loadFromCache: true)?.partnershipBrands {
                if !multipleSelectionEnabled {
                    brands = brands.filter(\.isUsableInContentCreation)
                }
                self?.brands = brands
                self?.objectWillChange.send()
            }
        }
    }
    
    private func updateProgresState() {
        progressStates[1] = selectedBrandIDs.isEmpty ? .idle : .progress(1)
    }
    
    func handleMainAction() {
        if multipleSelectionEnabled {
            brandSelectionActionHandler(.brandsSelected(brands.filter { selectedBrandIDs.contains($0.id) }))
            
        } else {
            brandSelectionActionHandler(.brandForGiftRequestSelected(brands.first(where: { $0.id == selectedBrandIDs.first })!))
        }
    }
    
    func updateBrandsSelection(_ brand: PartnershipBrand) {
        guard multipleSelectionEnabled else {
            selectedBrandIDs = Set([brand.id])
            return
        }
        selectedBrandIDs = selectedBrandIDs.symmetricDifference([brand.id])
    }
}
