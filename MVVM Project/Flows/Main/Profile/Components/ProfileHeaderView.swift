//
//  ProfileHeaderView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.05.2023.
//

import SwiftUI

extension ProfileComponents {
    
    struct ProfileHeaderView<Content: View>: View {
        
        @ViewBuilder let headerContent: (CGSize) -> Content
        
        var body: some View {
            GeometryReader { geometryProxy in
                let size = geometryProxy.size
                ScrollView(.vertical, showsIndicators: true) {
                    headerContent(size)
                        .parentContentSize(size)
                }
                .background(Color.cultured)
            }
        }
    }
}

#if DEBUG
struct ProfileHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        ProfileComponents.ProfileHeaderView(headerContent: { size in
            Color.cappuccino
                .frame(width: size.width, height: size.height)
        })
    }
}
#endif
