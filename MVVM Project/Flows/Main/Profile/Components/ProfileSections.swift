//
//  ProfileSections.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.05.2023.
//

import SwiftUI

struct ProfileComponents {
    
}

enum ProfileType: String, CaseIterable {
    case user
    case brand
}

struct ProfileShowsGridAction {
    let onSelectShow: (Show) -> Void
    var onCreateShow: (() -> Void)?
    let onErrorReceived: ((Error) -> Void)?
}

//MARK: - Profile Section
extension ProfileComponents {
    
    struct ProfileSections<SectionContent: View>: View {
        
        @Binding var selectedSection: ProfileSectionType
        var sectionTypes: [ProfileSectionType] = ProfileSectionType.allCases
        let profileType: ProfileType
        let isMinimizedState: Bool
        let namespace: Namespace.ID
        @ViewBuilder let sectionContent: SectionContent
        var onContentOffsetChanged: ((ProxyFrame) -> Void)?
        
        var body: some View {
            Section(content: {
                sectionContent
            }, header: {
                sectionsHeaderView
            })
        }
        
        private var sectionsHeaderView: some View {
            VStack(spacing: 0) {
                EquallyDistributedHStackLayout {
                    ForEach(sectionTypes, id: \.rawValue) {
                        tabButton($0)
                    }
                }
                .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
                DividerView()
            }
            .padding(.bottom, 8)
            .background(Color.cultured)
            .offset(y: isMinimizedState ? 28 : 0)
            .animation(.linear(duration: 0.2), value: isMinimizedState)
            .contentOffsetChanged({ proxyFrame in
                onContentOffsetChanged?(proxyFrame)
            })
        }
        
        private func tabButton(_ buttonType: ProfileSectionType) -> some View {
            let isSelected = selectedSection == buttonType
            return Button {
                guard !isSelected else { return }
                withAnimation(.easeOut) {
                    selectedSection = buttonType
                }
            } label: {
                Text(buttonType.title(for: profileType).uppercased())
                    .font(kernedFont: .Secondary.p5RegularKerned)
                    .background(alignment: .bottom) {
                        if isSelected {
                            tabSelectionIndicator.offset(y: 4)
                        }
                    }
                    .foregroundColor(isSelected ? .jet : .middleGrey)
            }
            .buttonStyle(.plain)
        }
        
        private var tabSelectionIndicator: some View {
            Rectangle()
                .frame(height: 2)
                .matchedGeometryEffect(id: ProfileSectionType.tabIndicatorID, in: namespace, properties: .frame)
        }
    }
}

#if DEBUG
struct ProfileSections_Previews: PreviewProvider {
    
    static var previews: some View {
        ForEach(ProfileType.allCases, id: \.self) { type in
            ProfileSectionsPreview(profileType: type)
                .previewDisplayName(type.rawValue.capitalized)
        }
    }
    
    struct ProfileSectionsPreview: View {
        
        let profileType: ProfileType
        @State private var selection = ProfileSectionType.products
        @State private var isMinimized = false
        @Namespace private var namespace
        
        var body: some View {
            ScrollView{
                ProfileComponents.ProfileSections(
                    selectedSection: $selection,
                    profileType: profileType, isMinimizedState: isMinimized,
                    namespace: namespace, sectionContent: {
                    Group {
                        switch selection {
                        case .about: Color.red
                        case .shows: Color.green
                        case .products: Color.blue
                        }
                    }
                    .frame(height: 100)
                })
            }
        }
    }
}
#endif
