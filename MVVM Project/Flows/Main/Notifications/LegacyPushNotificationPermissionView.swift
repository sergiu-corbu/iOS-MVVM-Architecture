//
//  LegacyPushNotificationPermissionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.03.2023.
//

import SwiftUI

struct LegacyPushNotificationPermissionView: View {
    
    let permissionType: PushNotificationPermissionType
    let pushNotificationsHandler: PushNotificationsPermissionHandler
    let notificationsInteractionFinished: (Bool) -> Void
    
    @State private var showNotificationsPermissionAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 36) {
                Image(.bellIcon)
                Text(permissionType.title)
                    .font(kernedFont: .Main.h1MediumKerned)
                    .foregroundColor(.jet)
                Text(permissionType.description)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(.ebony)
                    .lineLimit(4)
            }
            .padding(.horizontal, 16)
            .multilineTextAlignment(.center)
            .frame(maxHeight: .infinity)
            Buttons.FilledRoundedButton(title: Strings.Buttons.continue, action: handleRequestNotificationPermission)
        }
        .notificationsPermissionsDeniedAlert(isPresented: showNotificationsPermissionBinding)
    }
    
    private func handleRequestNotificationPermission() {
        Task(priority: .userInitiated) { @MainActor in
            let status = await pushNotificationsHandler.getCurrentAuthorizationStatus()
            switch status {
            case .notDetermined:
                let isAuthorized = try? await pushNotificationsHandler.requestPushNotificationsPermission()
                notificationsInteractionFinished(isAuthorized == true)
            case .denied:
                showNotificationsPermissionAlert = true
            default:
                notificationsInteractionFinished(false)
            }
        }
    }
    
    private var showNotificationsPermissionBinding: Binding<Bool> {
        return Binding(get: {
            return showNotificationsPermissionAlert
        }, set: { newValue in
            if !newValue {
                showNotificationsPermissionAlert = false
                notificationsInteractionFinished(false)
            }
        })
    }
}

enum PushNotificationPermissionType {
    
    case newShowsPosted
    case scheduledShowsReminder
    case followCreator
    case followBrand
    
    var title: String {
        switch self {
        case .newShowsPosted: return Strings.ShowDetail.setNotificationsReminder
        case .scheduledShowsReminder: return Strings.ShowDetail.scheduledShowReminder
        case .followCreator: return Strings.ShowDetail.followCreatorTitle
        case .followBrand: return Strings.ShowDetail.followBrandTitle
        }
    }
    
    var description: String {
        switch self {
        case .newShowsPosted: return Strings.ShowDetail.pushNotificationsMessage
        case .scheduledShowsReminder: return Strings.ShowDetail.scheduledShowReminderMessage
        case .followCreator: return Strings.ShowDetail.followCreatorMessage
        case .followBrand: return Strings.ShowDetail.followBrandMessage
        }
    }
}

#if DEBUG
#Preview {
    struct PushNotificationPermissionPreview: View {
        
        @State var show = false
        @State var showToast = false
        
        var body: some View {
            Color.random
                .onTapGesture {
                    show.toggle()
                }
                .successToast(isPresented: .constant(false), message: "Did enable notifications")
                .fullScreenCover(isPresented: .constant(true)) {
                    LegacyPushNotificationPermissionView(permissionType: .newShowsPosted, pushNotificationsHandler: MockPushNotificationsHandler(), notificationsInteractionFinished: { didEnable in
                        if didEnable {
                            showToast = true
                        }
                    })
                }
        }
    }

    return PushNotificationPermissionPreview()
}
#endif
