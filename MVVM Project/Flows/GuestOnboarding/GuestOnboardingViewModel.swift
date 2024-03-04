//
//  GuestOnboardingViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.11.2022.
//

import Foundation

class GuestOnboardingViewModel: ObservableObject {
    
    
    @Published var currentIndex = 0
    @Published var interactionsEnabled = false
    @Published var states = Array(
        repeating: ProgressState.idle,
        count: GuestOnboardingPage.predefinedPages.count
    )
    
    let guestOnboardingPages: [GuestOnboardingPage] = GuestOnboardingPage.predefinedPages
    
    let authenticationService: AuthenticationServiceProtocol
    let pushNotificationsHandler: PushNotificationsPermissionHandler
    let onFinishedInteraction: () -> Void
    
    init(authenticationService: AuthenticationServiceProtocol, pushNotificationsHandler: PushNotificationsPermissionHandler, onFinishedInteraction: @escaping () -> Void) {
        self.authenticationService = authenticationService
        self.pushNotificationsHandler = pushNotificationsHandler
        self.onFinishedInteraction = onFinishedInteraction
    }
    
    var currentPage: GuestOnboardingPage {
        guestOnboardingPages[currentIndex]
    }
    
    func cyclePages(animationDuration: TimeInterval = 3) {
        guard !interactionsEnabled else {
            return
        }
        states[currentIndex] = .progress(1)
        
        guard currentIndex > 0 else {
            DispatchQueue.main.asyncAfter(seconds: animationDuration) { [weak self] in
                self?.currentIndex += 1
                self?.cyclePages()
            }
            return
        }
        
        DispatchQueue.main.asyncAfter(seconds: animationDuration) { [weak self] in
            guard let self else {
                return
            }
            guard self.currentIndex < self.guestOnboardingPages.count - 1 else {
                self.interactionsEnabled = true
                return
            }
            self.currentIndex += 1
            self.cyclePages()
        }
    }
    
    func onBack() {
        guard currentIndex > 0 else {
            return
        }
        currentIndex -= 1
    }
    
    func onNext() {
        guard currentIndex < guestOnboardingPages.count - 1 else {
            return
        }
        currentIndex += 1
    }
}

#if DEBUG
extension GuestOnboardingViewModel {
    static let preview = GuestOnboardingViewModel(authenticationService: MockAuthService(), pushNotificationsHandler: MockPushNotificationsHandler(), onFinishedInteraction: {})
}
#endif
