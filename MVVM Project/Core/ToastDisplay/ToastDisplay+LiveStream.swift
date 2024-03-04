//
//  ToastDisplay+LiveStream.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 21.04.2023.
//

import SwiftUI

extension View {
    
    func liveStreamSetupRoomNotAvailableToast(isPresented: Binding<Bool>) -> some View {
        return self.informativeToast(
            isPresented: isPresented,
            title: Strings.ShowDetail.comeBackLaterAlert,
            message: Strings.ShowDetail.setupRoomNotAvailableMessage
        )
    }
    
    func liveStreamSetupRoomBinding(liveStreamErrorBinding: Binding<LiveStreamSelectionError?>, type: LiveStreamSelectionError) -> Binding<Bool> {
        return Binding(get: {
            return liveStreamErrorBinding.wrappedValue == type
        }, set: { _ in
            liveStreamErrorBinding.wrappedValue = nil
        })
    }
    
    func liveStreamSetupRoomSelectionAlert(_ liveStreamErrorBinding: Binding<LiveStreamSelectionError?>) -> some View {
        return self
            .liveStreamSetupRoomNotAvailableToast(
                isPresented: liveStreamSetupRoomBinding(
                    liveStreamErrorBinding: liveStreamErrorBinding, type: .setupRoomNotAvailable
                )
            )
            .mediaPermissionsDeniedAlert(
                isPresented: liveStreamSetupRoomBinding(liveStreamErrorBinding: liveStreamErrorBinding, type: .mediaPermissionsNotGranted)
            )
    }
}

