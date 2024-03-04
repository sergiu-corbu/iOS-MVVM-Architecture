//
//  CreateContentShortcutView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2023.
//

import SwiftUI
import Combine

struct CreateContentShortcutView: View {
    
    let currentUserPublisher: CurrentValueSubject<User?, Never>
    let onCreateContent: () -> Void
    
    @State private var showCreateContent: Bool = false
    
    var body: some View {
        PassthroughView {
            if showCreateContent {
                content
            }
        }
        .onReceive(currentUserPublisher) { user in
            showCreateContent = user?.role == .creator
        }
    }
    
    private var content: some View {
        Button {
            onCreateContent()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.darkGreen)
                    .frame(width: 56, height: 56)
                Image(.plusIconLight)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.paleSilver)
            }
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    VStack {
        CreateContentShortcutView(currentUserPublisher: CurrentValueSubject(nil), onCreateContent: {})
        CreateContentShortcutView(currentUserPublisher: CurrentValueSubject(User.creator), onCreateContent: {})
    }
}
#endif
