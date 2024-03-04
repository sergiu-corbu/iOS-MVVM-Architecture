//
//  UserSettingsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.11.2022.
//

import SwiftUI

struct UserSettingsView: View {
    
    let user: User?
    
    let onContactUs: () -> Void
    let onShowPersonalDetails: () -> Void
    let onManageAccount: () -> Void
    var onApplyToSell: (() -> Void)?
    
    private var isGuestSession: Bool {
        return user == nil
    }
    
    var userAppliedAsCreator: Bool {
        guard let user else {
            return false
        }
        return user.appliedAsCreator == true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 44) {
            if !isGuestSession {
                generalSection
            }
            supportSection
            applyToSellAndSettingsSection
        }
        .padding(EdgeInsets(top: 28, leading: 0, bottom: 8, trailing: 0))
        .background(Color.cultured)
    }
    
    private var supportSection: some View {
        MenuSectionView(image: .mail, title: Strings.MenuSection.support) {
            MenuSectionRowView(
                title: Strings.MenuSection.contactUs,
                action: onContactUs
            )
        }
    }
    
    private var generalSection: some View {
        MenuSectionView(image: .gridIcon, title: Strings.MenuSection.general) {
            MenuSectionRowView(
                title: Strings.MenuSection.personalDetails,
                action: onShowPersonalDetails
            )
        }
        .transition(.fade())
    }
    
    private var applyToSellAndSettingsSection: some View {
        MenuSectionView(image: .shield, title: Strings.MenuSection.appSettings) {
            MenuSectionRowView(title: Strings.MenuSection.privacyPolicy, url: Constants.PRIVACY_POLICY)
            MenuSectionRowView(title: Strings.MenuSection.termsAndConditions, url: Constants.TERMS_AND_CONDITIONS)
            if !isGuestSession {
                MenuSectionRowView(
                    title: Strings.MenuSection.manageAccount,
                    action: onManageAccount
                )
                .transition(.fade())
            }
            if user?.role != .creator {
                MenuSectionRowView(
                    title: Strings.Buttons.applyToGoLive,
                    kernedFont: .Secondary.p2BoldKerned,
                    foregroundColor: .orangish,
                    image: nil,
                    isEnabled: !userAppliedAsCreator
                ) {
                    onApplyToSell?()
                }
            }
        }
    }
}

#if DEBUG
struct UserSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        UserSettingsView(user: User.customer, onContactUs: {}, onShowPersonalDetails: {}, onManageAccount: {}, onApplyToSell: {})
            .previewDisplayName("ShopperSettings")
        UserSettingsView(user: nil, onContactUs: {}, onShowPersonalDetails: {}, onManageAccount: {}, onApplyToSell: {})
            .previewDisplayName("GuestSettings")
    }
}
#endif
