//
//  CompleteCreatorApplicationViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.11.2022.
//

import Foundation
import SwiftUI
import Combine

enum CreatorProfileProgress: Int, Equatable {
    
    case brandOwnership = 5
    case brandWebsite
    case brandPartnerships
    case brandPartners
    case receivedProducts
}

class CompleteCreatorApplicationViewModel: ObservableObject {
        
    @Published private(set) var profileProgress: CreatorProfileProgress = .brandOwnership {
        willSet {
            withAnimation {
                progress = newValue.rawValue * 10
            }
        }
    }
    @Published private(set) var progress: Int = 50
    
    //MARK: ErrorHandling
    @Published var backendError: Error?
    
    //MARK: BrandWebsite
    var brandWebsiteViewModel: BrandWebsiteViewModel?
    private var creatorOwnsBrand = false
    private var brandWebsite: String {
        brandWebsiteViewModel?.brandWebsite ?? ""
    }
    
    //MARK: BrandSelection
    var brandSelectionViewModel: BrandSelectionViewModel? {
        didSet {
            guard oldValue == nil else {
                return
            }
            brandSelectionViewModel?.backendErrorSubject
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    self?.backendError = error
                }.store(in: &cancellables)
        }
    }
    private var selectedBrands: Set<Brand> {
        return brandSelectionViewModel?.selectedBrands ?? []
    }

    //MARK: Partnerships
    private var hasPartnerships = false
    
    //MARK: Services
    let authenticationService: AuthenticationServiceProtocol
    let brandService: BrandServiceProtocol
    let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    let onFinishedInteraction = PassthroughSubject<Void, Never>()
    let onCancel = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(authenticationService: AuthenticationServiceProtocol, brandService: BrandServiceProtocol) {
        self.authenticationService = authenticationService
        self.brandService = brandService
    }
    
    typealias AnswerType = ContainerOptionsView.ButtonType
    
    func handleBackAction() {
        switch profileProgress {
        case .brandOwnership:
            break
        case .brandWebsite:
            brandWebsiteViewModel?.discardUserInput()
            profileProgress = .brandOwnership
        case .brandPartnerships:
            profileProgress = brandWebsite.isEmpty ? .brandOwnership : .brandWebsite
        case .brandPartners:
            brandSelectionViewModel?.removeSelectedBrands()
            profileProgress = .brandPartnerships
        case .receivedProducts:
            profileProgress = selectedBrands.isEmpty ? .brandPartnerships : .brandPartners
        }
    }
    
    //MARK: BrandWebsite
    func handleBrandOwnership(_ answer: AnswerType) {
        creatorOwnsBrand = answer == .yes
        trackRegistrationEvent(stepValue: RegistrationStepValue.creator_brand_owner)
        if answer == .yes {
            profileProgress = .brandWebsite
            trackRegistrationEvent(stepValue: RegistrationStepValue.creator_brand_website_capture)
        } else {
            trackRegistrationEvent(stepValue: RegistrationStepValue.creator_current_partnerships_confirmation)
            profileProgress = .brandPartnerships
        }
    }

    func showBrandPartnerships() {
        profileProgress = .brandPartnerships
        trackRegistrationEvent(stepValue: RegistrationStepValue.creator_current_partnerships_confirmation)
    }
    
    //MARK: BrandPartnership
    func handleBrandPartnership(_ answer: AnswerType) {
        if answer == .yes {
            profileProgress =  .brandPartners
            trackRegistrationEvent(stepValue: RegistrationStepValue.creator_current_partnerships_capture)
        } else {
            profileProgress = .receivedProducts
        }
    }
    
    //MARK: BrandSelection
    func handleBrandsSelection() {
        profileProgress = .receivedProducts
    }
    
    //MARK: BrandPartnerships
    func handleBrandPartnerships(_ answer: AnswerType) {
        withAnimation {
            progress = 100
        }
        hasPartnerships = answer == .yes
        trackRegistrationEvent(stepValue: RegistrationStepValue.creator_current_partnerships_capture)
        updateCreatorApplication()
    }
    
    func updateCreatorApplication() {
        Task(priority: .userInitiated) { @MainActor in
            do {
                let creatorApplication = CreatorApplication(
                    brandWebsite: brandWebsite.isEmpty ? nil : brandWebsite,
                    brands: Array(selectedBrands),
                    allowsBrandPromotion: brandWebsiteViewModel?.brandCanBePromoted == true,
                    creartorOwnsBrand: creatorOwnsBrand,
                    creatorHasPartnerships: hasPartnerships
                )
                try await authenticationService.updateCreatorApplication(creatorApplication)
                onFinishedInteraction.send()
            } catch {
                backendError = error
            }
        }
    }
}

//MARK: - Analytics
private extension CompleteCreatorApplicationViewModel {
    
    func trackRegistrationEvent(stepValue: String) {
        analyticsService.trackActionEvent(.creator_registration_steps, properties: [.registration_step: stepValue])
    }
}
