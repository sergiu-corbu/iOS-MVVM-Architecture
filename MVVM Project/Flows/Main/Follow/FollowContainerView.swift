//
//  FollowContainerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.05.2023.
//

import SwiftUI

struct FollowContainerView<Content: View>: View {
    
    @ObservedObject var followViewModel: FollowViewModel
    @ViewBuilder let content: Content
    
    private var permissionType: PushNotificationPermissionType {
        switch followViewModel.followType {
        case .user: return .followCreator
        case .brand: return .followBrand
        }
    }
    
    var body: some View {
        let isFollowEnabled = followViewModel.followingID != followViewModel.userRepository.currentUser?.id
        return content
            .disabled(!isFollowEnabled)
            .opacity(isFollowEnabled ? 1 : 0)
            .fullScreenCover(isPresented: $followViewModel.showPushNotificationsPermission, content: pushNotificationsPermissionView)
    }
    
    private func pushNotificationsPermissionView() -> some View {
        LegacyPushNotificationPermissionView(permissionType: permissionType, pushNotificationsHandler: followViewModel.pushNotificationsPermissionHandler, notificationsInteractionFinished: { _ in
            followViewModel.showPushNotificationsPermission = false
        })
    }
}

#if DEBUG
struct FollowContainerView_Previews: PreviewProvider {
    
    static var previews: some View {
       EmptyView()
    }
}
#endif
