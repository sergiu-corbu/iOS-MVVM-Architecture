//
//  EditCreatorProfileViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 23.11.2022.
//

import Foundation
import Combine
import UIKit

class EditCreatorProfileViewModel: ObservableObject {
    
    @Published var user: User
    @Published var localProfileImage: UIImage?
    @Published var isUploadingImage = false
    
    @Published var error: Error?

    @Published var isEditBioPresented = false
    
    let onBack = PassthroughSubject<Void, Never>()
    let onAddSocial = PassthroughSubject<Void, Never>()
    let onAddProfilePicture = PassthroughSubject<Void, Never>()
    let onCropImage = PassthroughSubject<UIImage, Never>()
    
    var profileImageDidChangeSubject: PassthroughSubject<UIImage?, Never>?
    
    let userRepository: UserRepository
    let uploadService: AWSUploadServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(user: User, localProfileImage: UIImage?, userRepository: UserRepository, uploadService: AWSUploadServiceProtocol) {
        self.user = user
        self.localProfileImage = localProfileImage
        self.userRepository = userRepository
        self.uploadService = uploadService
        setupUserUpdates()
    }
    
    func handleSelectedImage(_ image: UIImage?) {
        localProfileImage = image
        uploadProfilePicture()
    }
    
    private func uploadProfilePicture() {
        guard let compressedData = localProfileImage?.thumbImageWithMaxPixelSize(UploadImageMaxSize)?
            .jpegData(compressionQuality: JPEGCompressionQuality) else {
            return
        }
        Task(priority: .userInitiated) { @MainActor in
            do {
                profileImageDidChangeSubject?.send(localProfileImage)
                isUploadingImage = true
                let multipart = Multipart(uploadResource: .data(compressedData), fileName: "picture", uploadScope: .profilePicture, owner: nil)
                try await uploadService.uploadData(multipart: multipart, uploadProgress: nil)
                await userRepository.getCurrentUser(loadFromCache: false)
            } catch {
                self.error = error
                self.localProfileImage = nil
                profileImageDidChangeSubject?.send(nil)
            }
            isUploadingImage = false
        }
    }
    
    func setupUserUpdates() {
        userRepository.currentUserSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedUser in
            if let updatedUser {
                self?.user = updatedUser
            }
        }.store(in: &cancellables)
    }
}
