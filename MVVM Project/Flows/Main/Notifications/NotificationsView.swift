//
//  NotificationsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import SwiftUI

struct NotificationsView: View {
    
    var body: some View {
        VStack {
            NavigationBar(title: Strings.NavigationTitles.notifications)
            ComingSoonView()
        }
        .primaryBackground()
    }
}

#if DEBUG
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
#endif
