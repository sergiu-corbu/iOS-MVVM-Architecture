//
//  AboutSectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.02.2023.
//

import SwiftUI

extension ProfileComponents {
    
    struct AboutSectionContainer: View {
        
        let bio: String?
        let brands: [PartnershipBrand]?
        let socialLinks: [SocialNetworkHandle]?
        var isEditable: Bool = false
        var actionHandler: ((Action) -> Void)? = nil
        
        enum Action {
            case updateBio
            case updateSocialLinks
            case selectBrand(Brand)
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 32) {
                BioSectionView(bio: bio, isEditable: isEditable, onUpdateBio: {
                    actionHandler?(.updateBio)
                })
                BrandsPartnershipSectionView(brands: brands, onSelectBrand: { brand in
                    actionHandler?(.selectBrand(brand))
                })
                SocialLinksSectionView(socialLinks: socialLinks, isEditable: isEditable, onUpdateSocialLinks: {
                    actionHandler?(.updateSocialLinks)
                })
            }
            .padding(.vertical, 16)
        }
    }
    
    //MARK: - Bio section
    struct BioSectionView: View {
        
        let bio: String?
        let isEditable: Bool
        var onUpdateBio: (() -> Void)?
        
        var body: some View {
            SectionView(title: Strings.Profile.bioTitle, isEditable: isEditable && bio != nil, content: {
                contentView
            }, onEditContent: onUpdateBio)
        }
        
        private func sectionTextView(_ text: String) -> some View {
            Text(text)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
                .padding(.horizontal, 16)
        }
        
        @ViewBuilder private var contentView: some View {
            if let bio {
                sectionTextView(bio)
            } else {
                if isEditable {
                    Buttons.BorderedButton(title: Strings.Buttons.addBio.uppercased()) {
                        Image(.plusIcon)
                    } action: {
                        onUpdateBio?()
                    }
                } else {
                    sectionTextView("The creator hasn't added any bio yet.")
                }
            }
        }
    }
    
    //MARK: - Brands partnership section
    struct BrandsPartnershipSectionView: View {
        
        let brands: [PartnershipBrand]?
        let onSelectBrand: (Brand) -> Void
        
        var body: some View {
            SectionView(title: Strings.Profile.collaborationTitle) {
                contentView
            }
        }
        
        @ViewBuilder private var contentView: some View {
            if let brands {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(brands, id: \.id) {
                            brandCellView($0)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            } else {
                Text(Strings.Profile.collaborationDescription)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(.ebony)
                    .padding(.horizontal, 16)
            }
        }
        
        private func brandCellView(_ partnershipBrand: PartnershipBrand) -> some View {
            Button {
                onSelectBrand(Brand(partnershipBrand: partnershipBrand))
            } label: {
                BrandHeaderView(brandName: partnershipBrand.name, pictureURL: partnershipBrand.brandPictureURL)
                    .padding(.horizontal, 8)
                    .frame(height: 56)
                    .background(Color.beige, in: RoundedRectangle(cornerRadius: 50))
            }
            .buttonStyle(.plain)
        }
    }
    
    //MARK: - Social links section
    struct SocialLinksSectionView: View {
        
        let socialLinks: [SocialNetworkHandle]?
        var isEditable: Bool = false
        var onUpdateSocialLinks: (() -> Void)?
        
        var body: some View {
            SectionView(title: Strings.Profile.onTheWebTitle,
                        isEditable: isEditable && socialLinks?.isEmpty == false,
                        content: {
               contentView
            }, onEditContent: onUpdateSocialLinks)
        }
        
        @ViewBuilder private var contentView: some View {
            if let socialLinks {
                SocialLinksView(socialLinks: socialLinks)
            } else if isEditable {
                Buttons.BorderedButton(title: Strings.Buttons.addSocial.uppercased()) {
                    Image(.plusIcon)
                } action: {
                    onUpdateSocialLinks?()
                }
            }
        }
    }
    
    //MARK: - Social links
    struct SocialLinksView: View {
        
        let socialLinks: [SocialNetworkHandle]
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(socialLinks.indexEnumeratedArray, id: \.0) { index , socialLink in
                        socialLinkLabel(socialLink, showSeparator: index != socialLinks.count - 1)
                    }
                }
                .padding(.horizontal, 16)
            }
            .transition(.opacity.animation(.easeInOut))
        }
        
        @ViewBuilder
        private func socialLinkLabel(_ socialLink: SocialNetworkHandle, showSeparator: Bool) -> some View {
            Button {
                UIApplication.shared.tryOpenURL(socialLink.websiteUrl)
            } label: {
                HStack(spacing: 4) {
                    socialLink.type.image
                        .renderingMode(.template)
                        .resizedToFit(width: 20, height: 20)
                        .foregroundColor(.paleSilver)
                    switch socialLink.type {
                    case .youtube, .instagram, .tiktok:
                        Text(socialLink.handle ?? "")
                            .font(kernedFont: .Secondary.p1RegularKerned)
                            .foregroundColor(.jet)
                    case .website, .other:
                        Text(socialLink.websiteUrl?.absoluteString ?? "")
                            .font(kernedFont: .Secondary.p1RegularKerned)
                            .foregroundColor(.jet)
                    }
                    if showSeparator {
                        Circle()
                            .fill(Color.jet)
                            .frame(width: 3, height: 3)
                            .padding(.leading, 4)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    struct LocationSectionView: View {
        
        let location: String?
        
        var body: some View {
            if let location {
                SectionView(title: Strings.Profile.location, content: {
                    HStack(spacing: 6) {
                        Image(.location)
                        Text(location)
                            .font(.Secondary.p1Regular)
                            .foregroundColor(.ebony)
                    }
                    .padding(.horizontal, 16)
                })
            }
        }
    }
}

extension ProfileComponents {
    
    fileprivate struct SectionView<Content: View>: View {
        
        let title: String
        var kernedFont: KernedFont = .Main.p1MediumKerned
        var isEditable: Bool = false
        var isDividerVisible = true
        @ViewBuilder var content: Content
        var onEditContent: (() -> Void)?
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title.uppercased())
                        .font(kernedFont: kernedFont)
                        .foregroundColor(.jet)
                        .padding(.horizontal, 16)
                    content
                    if isDividerVisible {
                        Rectangle()
                            .fill(Color.midGrey)
                            .frame(height: 1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if isEditable {
                    editContentButton
                }
            }
        }
        
        private var editContentButton: some View {
            Button {
                onEditContent?()
            } label: {
                Text(Strings.Buttons.edit.uppercased())
                    .font(kernedFont: .Secondary.p3BoldKerned)
                    .foregroundColor(.brightGold)
            }
            .padding(.trailing, 16)
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
struct AboutSectionView_Previews: PreviewProvider {
    
    static let bioMessage = "Ms. Djerf, a 25-year-old social media influencer who founded the fashion brand Djerf Avenue with her boyfriend, Rasmus Johansson, in 2019, has forged a fast-growing business empire on tantalizing glimpses of her soft-focus Scandi dream life — not to mention one of TikTok’s most emulated haircuts. "
    static let brands = [PartnershipBrand.armani, .robertoCavalli, .baldinini]
    
    static var previews: some View {
        VStack(spacing: 30) {
            ProfileComponents.AboutSectionContainer(bio: Self.bioMessage, brands: Self.brands, socialLinks: SocialNetworkHandle.all, isEditable: true)
            Divider()
            ProfileComponents.AboutSectionContainer(bio: nil, brands: nil, socialLinks: nil, isEditable: true)
        }
        .previewDisplayName("Personal about section")
        VStack(spacing: 30) {
            ProfileComponents.AboutSectionContainer(bio: Self.bioMessage, brands: Self.brands, socialLinks: SocialNetworkHandle.all, isEditable: false)
            Divider()
            ProfileComponents.AboutSectionContainer(bio: nil, brands: nil, socialLinks: nil, isEditable: false)
        }
        .previewDisplayName("Public about section")
    }
}
#endif
