//
//  EditCreatorBioViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 25.11.2022.
//

import Foundation

class EditCreatorBioViewModel: ObservableObject {
    
    @Published var creatorBio: String
    @Published var isLoading: Bool = false
    @Published var backendError: Error?
    
    let userRepository: UserRepository
    
    let maxCharachters: Int
    private let initialCreatorBio: String
    
    var saveButtonEnabled: Bool {
        return !creatorBio.trimmingCharacters(in: .whitespaces).isEmpty && creatorBio != initialCreatorBio
    }

    init(creatorBio: String?, userRepository: UserRepository, maxCharachters: Int = 350) {
        self.creatorBio = creatorBio ?? ""
        self.initialCreatorBio = creatorBio ?? ""
        self.userRepository = userRepository
        self.maxCharachters = maxCharachters
    }
    
    var remainingCharachtersString: String {
        let remainingCharachters = maxCharachters - creatorBio.count
        var result: String = "\(remainingCharachters) Character".pluralizedIfNeeded(remainingCharachters)
        result.append(" Left")
        return result
    }
    
    func saveCreatorBio(completion: (() -> Void)? = nil) {
        Task(priority: .userInitiated) { @MainActor in
            do {
                isLoading = true
                try await userRepository.updateUser(bio: creatorBio, socialNetworks: nil)
                completion?()
            } catch {
                backendError = error
            }
            isLoading = false
        }
    }
}
