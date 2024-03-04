//
//  ScheduledLiveSuccessView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 20.03.2023.
//

import SwiftUI

enum SocialMediaType: String, CaseIterable {
    case instagram
    case tiktok
    case youtube
    
    var imageResource: ImageResource {
        switch self {
        case .instagram: return ImageResource.instagramIcon
        case .tiktok: return ImageResource.tiktokIcon
        case .youtube: return ImageResource.youtubeIcon
        }
    }
    
    var openURLPath: URL? {
        switch self {
        case .instagram: return Constants.SocialMedia.instagram
        case .tiktok: return Constants.SocialMedia.tiktok
        case .youtube: return Constants.SocialMedia.youtube
        }
    }
}

struct ScheduledLiveSuccessView: View {
    
    let show: Show
    let deeplinkProvider: DeeplinkProvider
    let onFinishedInteraction: () -> Void
    
    @State private var showCopiedLinkMessage = false
    @State private var isAnimating = false
    @State private var shareLink: URL?
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(maxHeight: 80)
            Text(Strings.ContentCreation.scheduledLiveStreamMessage)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundColor(.jet)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            shareLinkSectionView
                .frame(maxHeight: .infinity)
                .disabled(shareLink == nil)
            Buttons.FilledRoundedButton(title: Strings.Buttons.done, action: onFinishedInteraction)
        }
        .primaryBackground()
        .animation(.easeInOut, value: shareLink)
        .successToast(isPresented: $showCopiedLinkMessage, message: Strings.ContentCreation.linkCopiedMessage)
        .task(priority: .userInitiated) {
            await generateShareLink()
        }
    }
    
    private func generateShareLink() async {
        isAnimating = true
        if let shareLink = await deeplinkProvider.generateShareURL(shareableObject: show.shareableObject) {
            self.shareLink = shareLink
            isAnimating = false
        }
    }
    
    private var shareLinkSectionView: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text(Strings.ContentCreation.shareLiveStreamLinkMessage)
                .font(kernedFont: .Secondary.p1BoldKerned)
                .foregroundColor(.jet)
                .minimumScaleFactor(0.9)
                .lineLimit(1)
            HStack(spacing: 0) {
                Text(shareLink?.absoluteString ?? Strings.Placeholders.generatingShareLink)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(.ebony)
                    .lineLimit(1)
                    .opacity(isAnimating ? 0.3 : 1)
                    .animation(.easeInOut(duration: 0.6).repeatForever(), value: isAnimating)
                    .transaction { link in
                        link.disablesAnimations = !isAnimating
                    }
                Spacer()
                Button {
                    UIPasteboard.general.string = shareLink?.absoluteString
                    showCopiedLinkMessage = true
                } label: {
                    HStack(spacing: 4) {
                        Text(Strings.Buttons.copyLink)
                            .font(kernedFont: .Secondary.p1BoldKerned)
                        Image(.linkIcon)
                    }
                    .foregroundColor(.jet)
                }
                .buttonStyle(.plain)
            }
            .padding(.all, 16)
            .background(Color.cappuccino, in: RoundedRectangle(cornerRadius: 5))
            socialMediaSectionView
        }
        .padding(24)
        .roundedBorder(Color.midGrey, cornerRadius: 8)
        .padding(.horizontal, 16)
    }
    
    private var socialMediaSectionView: some View {
        HStack(spacing: 24) {
            ForEach(SocialMediaType.allCases, id: \.self) {
                socialMediaIcon($0)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func socialMediaIcon(_ socialMediaType: SocialMediaType) -> some View {
        Button {
            UIPasteboard.general.string = shareLink?.absoluteString
            showCopiedLinkMessage = true
            let didOpenURL = UIApplication.shared.tryOpenURL(socialMediaType.openURLPath)
            if !didOpenURL {
                UIApplication.shared.tryOpenURL(URL(string: "https://\(socialMediaType.rawValue).com/"))
                
            }
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.ebony.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(socialMediaType.imageResource)
                        .renderingMode(.template)
                        .resizedToFit(size: CGSize(width: 18, height: 18))
                        .foregroundColor(.jet)
                }
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct ScheduledLiveSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduledLiveSuccessView(show: .scheduled, deeplinkProvider: MockDeeplinkProvider(), onFinishedInteraction: {})
    }
}
#endif

