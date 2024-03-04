//
//  ShopperProfileViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.11.2022.
//

import Foundation
import Combine

class ShopperProfileViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var user: User?
    private var cancellables = Set<AnyCancellable>()
    
    var isGuestSession: Bool {
        return user == nil
    }
    
    //MARK: - Actions
    let actionHandler: ProfileActionHandler?
    private(set) var sessionDidChange: Bool = false
    
    //MARK: - Services
    let userRepository: UserRepository
    let userSession: UserSession
    let checkoutCartManager: CheckoutCartManager
    
    init(userRepository: UserRepository, userSession: UserSession, checkoutCartManager: CheckoutCartManager,
         actionHandler: ProfileActionHandler?) {
        
        self.userRepository = userRepository
        self.user = userRepository.currentUser
        self.userSession = userSession
        self.checkoutCartManager = checkoutCartManager
        self.actionHandler = actionHandler
        setupCurrentUserSubjectNotifications()
    }
    
    private func setupCurrentUserSubjectNotifications() {
        userRepository.currentUserSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedUser in
                self?.user = updatedUser
            }
            .store(in: &cancellables)

        userSession.currentUserRoleSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.user = self?.userRepository.currentUser
                self?.sessionDidChange.toggle()
            }
            .store(in: &cancellables)
    }
}
