//
//  ProfileImageView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.05.2023.
//

import SwiftUI

extension ProfileComponents {
    
    struct ProfileImageView: View {
        
        let imageURL: URL?
        var localImage: UIImage? = nil
        var isEditable = false
        let placeholderString: String
        let availableSize: CGSize
        var onUploadImage: (() -> Void)?
        
        private var hasProfileImage: Bool {
            return imageURL != nil || localImage != nil
        }
        
        var body: some View {
            AsyncImageView(imageURL: imageURL, localImage: localImage, placeholder: {
                profileImagePlaceholder
            })
            .scaledToFill()
            .fadedGradient(hasProfileImage ? Color.jet : .clear)
            .stickyHeaderEffect(minHeight: availableSize.height / 2 + safeAreaInsets.top)
        }
        
        private var profileImagePlaceholder: some View {
            ZStack {
                if isEditable {
                    Color.beige
                    Button {
                        onUploadImage?()
                    } label: {
                        ImagePlaceholderView()
                            .frame(width: availableSize.width - 32)
                            .dashedBorder()
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 32)
                } else {
                    let circleRadius: CGFloat = 78
                    Color.darkGreen
                    Circle()
                        .fill(Color.ebony.opacity(0.15))
                        .frame(width: circleRadius * 2, height: circleRadius * 2)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(.logo)
                                    .renderingMode(.template)
                                    .resizedToFit(size: nil)
                                    .foregroundColor(.white)
                                Text(placeholderString.uppercased())
                                    .font(kernedFont: .Secondary.p2MediumKerned(2.5))
                                    .foregroundColor(.midGrey)
                            }
                                .padding(.horizontal, 16)
                        )
                        .offset(y: -circleRadius)
                }
            }
        }
    }
}
