//
//  User+Environment.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 21.09.2023.
//

import SwiftUI
import Combine

struct CurrentUserEnvironmentKey: EnvironmentKey {
    static var defaultValue: User? = nil
}

extension EnvironmentValues {
    
    var currentUser: User? {
        get { self[CurrentUserEnvironmentKey.self] }
        set { self[CurrentUserEnvironmentKey.self] = newValue }
    }
}

struct CurrentUserPublisherEnvironmentKey: EnvironmentKey {
    static var defaultValue: CurrentValueSubject<User?, Never> = .init(nil)
}
extension EnvironmentValues {
    
    var currentUserPublisher: CurrentValueSubject<User?, Never> {
        get { self[CurrentUserPublisherEnvironmentKey.self] }
        set { self[CurrentUserPublisherEnvironmentKey.self] = newValue }
    }
}


///Note: Make sure the parent view is injecting the publisher into the environment at the topmost level
struct FollowingUserWrapperView<Content: View, Placeholder: View>: View {
    
    let userID: String
    @ViewBuilder let content: Content
    @ViewBuilder let placeholder: Placeholder
    
    //Internal
    @Environment(\.currentUserPublisher) private var currentUserPublisher: CurrentValueSubject<User?, Never>
    @State private var currentUser: User?
    
    private var isFollowingUser: Bool {
        return currentUser?.followingUserIds.contains(userID) == true
    }
    
    var body: some View {
        PassthroughView {
            if isFollowingUser {
                content
            } else {
                placeholder
            }
        }
        .animation(.linear, value: isFollowingUser)
        .onReceive(currentUserPublisher) {
            self.currentUser = $0
        }
    }
}

extension FollowingUserWrapperView where Placeholder == EmptyView {
    
    init(userID: String, @ViewBuilder content: () -> Content) {
        self.userID = userID
        self.content = content()
        self.placeholder = EmptyView()
    }
}
