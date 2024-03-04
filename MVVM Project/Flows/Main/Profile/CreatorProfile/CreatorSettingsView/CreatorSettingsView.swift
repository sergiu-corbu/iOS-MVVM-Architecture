//
//  CreatorSettingsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.11.2022.
//

import SwiftUI

struct CreatorSettingsView: View {
    
    let user: User
    let profileActions: ProfileActionHandler
    let onBack: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationBar(inlineTitle: Strings.NavigationTitles.settings, onDismiss: onBack)
            ScrollView {
                UserSettingsView(
                    user: user,
                    onContactUs: profileActions.onContactUs,
                    onShowPersonalDetails: profileActions.onShowPersonalDetails,
                    onManageAccount: profileActions.onManageAccount
                )
                .padding(.top, 24)
            }
        }
        .primaryBackground()
    }
}

#if DEBUG
struct CreatorSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        CreatorSettingsView(user: User.creator, profileActions: .emptyActions, onBack: {})
    }
}
#endif
