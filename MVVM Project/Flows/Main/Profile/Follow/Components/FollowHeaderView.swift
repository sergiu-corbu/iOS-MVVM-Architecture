//
//  FollowHeaderView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.08.2023.
//

import SwiftUI

struct FollowHeaderView: View {
    
    @Binding var selectedFollowType: FollowType
    let followSectionType: FollowSectionType
    let followingUsersCount: Int
    let followingBrandsCount: Int
    let onBack: () -> Void
    
    @Namespace private var sectionEffectNamespace
    private let sectionEffectID = "sectionEffectID"
    
    var body: some View {
        VStack(spacing: 8) {
            NavigationBar(inlineTitle: followSectionType.name.capitalized, onDismiss: onBack)
            VStack(spacing: 6) {
                HStack(spacing: 56) {
                    followSectionView(type: .user)
                    followSectionView(type: .brand)
                }
                .padding(.horizontal, 30)
                .animation(.easeInOut, value: selectedFollowType)
                DividerView()
            }
        }
    }
    
    private func followSectionView(type followType: FollowType) -> some View {
        let isSelected = followType == selectedFollowType
        let followCount = followType == .brand ? followingBrandsCount : followingUsersCount
        
        return Button(action: {
            if isSelected {
                return
            }
            selectedFollowType = followType
        }, label: {
            Text(followType.sectionTitle + " (\(followCount))")
                .font(kernedFont: .Secondary.p5RegularKerned)
                .foregroundColor(isSelected ? .jet : .middleGrey)
                .monospacedDigit()
                .background(alignment: .bottom) {
                    if isSelected {
                        Rectangle()
                            .fill(Color.jet)
                            .frame(height: 2)
                            .offset(y: 6)
                            .matchedGeometryEffect(id: sectionEffectID, in: sectionEffectNamespace, properties: .position)
                    }
                }
        })
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct FollowHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        FollowHeaderPreview()
    }
    
    private struct FollowHeaderPreview: View {
        
        @State var followType: FollowType = .user
        
        var body: some View {
            FollowHeaderView(selectedFollowType: $followType, followSectionType: .following, followingUsersCount: 10, followingBrandsCount: 5, onBack: {})
        }
    }
}
#endif
