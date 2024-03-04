//
//  Alert+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 31.03.2023.
//

import SwiftUI

extension View {
    
    func mediaPermissionsDeniedAlert(isPresented: Binding<Bool>) -> some View {
        return self.alert(Strings.Alerts.mediaPermissionsNotGranted, isPresented: isPresented) {
            Button(Strings.Buttons.cancel) {
                isPresented.wrappedValue = false
            }
            Button(Strings.Buttons.openSettings) {
                UIApplication.shared.tryOpenURL(URL(string: UIApplication.openSettingsURLString))
            }
        }
    }
    
    func notificationsPermissionsDeniedAlert(isPresented: Binding<Bool>) -> some View {
        return self.alert(Strings.Alerts.notificationsNotEnabled, isPresented: isPresented) {
            Button(Strings.Buttons.cancel) {
                isPresented.wrappedValue = false
            }
            Button(Strings.Buttons.openSettings) {
                UIApplication.shared.tryOpenURL(URL(string: UIApplication.openSettingsURLString))
            }
        }
    }
}
