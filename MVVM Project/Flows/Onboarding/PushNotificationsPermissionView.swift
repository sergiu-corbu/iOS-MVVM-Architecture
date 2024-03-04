//
//  PushNotificationsPermissionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.11.2023.
//

import SwiftUI

struct PushNotificationsPermissionView<Content: View>: View {
    
    var presentationDetent: PresentationDetent = .large
    let pushNotificationsHandler: PushNotificationsPermissionHandler
    let onDismiss: () -> Void
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            if presentationDetent != .large {
                GrabberView()
            }
            content
                .padding(16)
                .frame(maxHeight: .infinity)
            actionButtonsView
        }
        .padding(.bottom, 16)
        .background(Color.cultured)
        .presentationDetents([presentationDetent])
        .interactiveDismissDisabled()
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 0) {
            Buttons.FilledRoundedButton(title: Strings.Buttons.allow, action: handleRequestNotificationsPermission)
            Button {
                onDismiss()
            } label: {
                Text(Strings.Buttons.noThanks)
                    .font(kernedFont: .Secondary.p2BoldKerned)
                    .foregroundStyle(Color.ebony)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func handleRequestNotificationsPermission() {
        Task(priority: .userInitiated) { @MainActor in
            if case .notDetermined = await pushNotificationsHandler.getCurrentAuthorizationStatus() {
                _ = try? await pushNotificationsHandler.requestPushNotificationsPermission()
            }
            onDismiss()
        }
    }
}

struct PushNotificationsReminderView: View {
    
    let pushNotificationsHandler: PushNotificationsPermissionHandler
    let onDismiss: () -> Void
    
    var body: some View {
        PushNotificationsPermissionView(
            presentationDetent: .fraction(0.6),
            pushNotificationsHandler: pushNotificationsHandler,
            onDismiss: onDismiss, content: {
                VStack(spacing: 8) {
                    Image(.notificationsIcon)
                        .padding(.bottom, 8)
                    Text(Strings.Permissions.pushNotificationsPermissionTitle)
                        .font(kernedFont: .Main.h1MediumKerned)
                        .foregroundColor(.orangish)
                    Text(Strings.Permissions.pushNotificationsPermissionMessage)
                        .font(kernedFont: .Secondary.p1RegularKerned)
                        .foregroundColor(.ebony)
                }
                .multilineTextAlignment(.center)
        })
    }
}

class PushNotificationsReminderViewController: UIHostingController<PushNotificationsReminderView> {
    
    init(pushNotificationsHandler: PushNotificationsPermissionHandler, onDismiss: @escaping () -> Void) {
        super.init(rootView: PushNotificationsReminderView(pushNotificationsHandler: pushNotificationsHandler, onDismiss: onDismiss))
        isModalInPresentation = true
    }
    
    override func loadView() {
        super.loadView()
        guard let sheetPresentationController else {
            return
        }
        sheetPresentationController.prefersGrabberVisible = false
        sheetPresentationController.detents = [.custom(resolver: { context in
            return context.maximumDetentValue * 0.6
        })]
    }
    
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#if DEBUG
#Preview {
    Color.random.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            PushNotificationsPermissionView(
                pushNotificationsHandler: MockPushNotificationsHandler(),
                onDismiss: {}, content: {
                    Color.random
                }
            )
        }
}

#Preview {
    Color.random.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            PushNotificationsReminderView(
                pushNotificationsHandler: MockPushNotificationsHandler(),
                onDismiss: {}
            )
        }
}
#endif
