//
//  GuestOnboardingPage.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.11.2022.
//

import Foundation

struct GuestOnboardingPage: Identifiable {
    
    let index: Int
    let image: ImageResource
    let title: String
    
    var id: Int { index }
    
    static var predefinedPages = [
        GuestOnboardingPage(index: 0, image: .firstOnboarding, title: Strings.GuestOnboarding.firstMessage),
        GuestOnboardingPage(index: 1, image: .secondOnboarding, title: Strings.GuestOnboarding.secondMessage),
        GuestOnboardingPage(index: 2, image: .lastOnboarding, title: Strings.GuestOnboarding.thirdMessage)
    ]
}
