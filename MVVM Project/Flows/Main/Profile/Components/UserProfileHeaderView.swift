//
//  UserProfileHeaderView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 21.09.2023.
//

import SwiftUI
import Combine

struct UserHeaderInformationView: View {
        
    let user: User
    var configuration = Configuration()
    var accessLevel: ProfileAccessLevel = .readWrite
    var onSelectSection: ((FollowSectionType) -> Void)?
    
    private var creatorTitle: String {
        switch accessLevel {
        case .readOnly: return user.fullName ?? ""
        case .readWrite: return Strings.Profile.welcome(name: user.firstName ?? "")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            greetingMessageAndEmail
            if accessLevel == .readWrite {
                followingAndFollowersView
            }
//                else {
//                FollowingUserWrapperView(userID: user.id, content: {
//                    followingAndFollowersView
//                }, placeholder: {
//                    Text(Strings.Profile.notFollowingUserMessage)
//                        .font(kernedFont: .Secondary.p1RegularKerned)
//                        .foregroundStyle(Color.cultured)
//                        .lineSpacing(1.5)
//                        .padding(12)
//                        .roundedBorder(Color.battleshipGray.opacity(0.55), cornerRadius: 6)
//                })
//            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
    
    private var greetingMessageAndEmail: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(creatorTitle)
                .font(.Main.h1Italic)
                .foregroundColor(configuration.primaryColor)
            Text(user.formattedUsername)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(configuration.tint)
        }
    }
    
    private var followingAndFollowersView: some View {
        HStack(spacing: 4) {
            if user.role == .creator {
                sectionButton(.followers, count: user.followersCount)
                Circle()
                    .fill(user.profilePictureUrl != nil ? Color.white : .beige)
                    .frame(width: 4, height: 4)
                    .padding(.horizontal, 4)
            }
            sectionButton(.following, count: user.followingCount)
        }
    }
    
    private func sectionButton(_ section: FollowSectionType, count: Int) -> some View {
        Button(action: {
            onSelectSection?(section)
        }, label: {
            HStack(spacing: 4) {
                Text("\(count)")
                    .font(kernedFont: .Secondary.p1BoldKerned)
                    .monospacedDigit()
                    .foregroundColor(.orangish)
                Text(section.name)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(configuration.secondaryColor)
            }
        })
        .buttonStyle(.plain)
        .disabled(onSelectSection == nil)
    }
}

extension UserHeaderInformationView {
    
    struct Configuration {
        var primaryColor: Color = .lightGrey
        var secondaryColor: Color = .cultured
        var tint: Color = .middleGrey
    }
}

#if DEBUG
struct UserProfileHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            UserHeaderInformationView(user: .customer, accessLevel: .readOnly)
            DividerView()
            UserHeaderInformationView(user: .customer, accessLevel: .readWrite)
            DividerView()
            UserHeaderInformationView(user: .customer, accessLevel: .readOnly)
                .environment(\.currentUserPublisher, CurrentValueSubject(User.customer))
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Color.paleSilver)
    }
}
#endif
