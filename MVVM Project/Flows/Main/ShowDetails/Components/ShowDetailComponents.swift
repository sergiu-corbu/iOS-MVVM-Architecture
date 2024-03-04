//
//  ShowDetailComponents.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.03.2023.
//

import SwiftUI

struct PlayVideoStreamIndicator: View {
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.cultured.opacity(0.2))
            .overlay(Image(.playIconLarge))
            .frame(width: 50, height: 50)
            .frame(maxHeight: .infinity)
            .transition(.opacity.animation(.easeOut(duration: 0.1)))
    }
}

struct LiveStreamEndedView: View {
    
    let onBackAction: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text(Strings.ShowDetail.liveStreamEnded)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.cultured)
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.backToDiscover,
                fillColor: .beige, tint: .darkGreen,
                action: onBackAction
            )
        }
        .transition(.opacity)
    }
}

struct ShowThumbnailView: View {
    
    let showThumbnailURL: URL?
    
    var body: some View {
        GeometryReader { geometryProxy in
            AsyncImageView(imageURL: showThumbnailURL)
                .scaledToFill()
                .frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                .transition(.opacity.animation(.easeOut))
        }
    }
}

struct ScheduledShowTimerView: View {
    
    let show: Show
    
    var body: some View {
        if show.status == .scheduled, let publishDate = show.publishingDate {
            VStack(spacing: 0) {
                Text(Strings.ShowDetail.scheduledShowTitle.uppercased())
                    .font(kernedFont: .Secondary.p2MediumKerned())
                    .foregroundColor(.ebony.opacity(0.5))
                Text(publishDate.dateString(formatType: .fullDateAndTime))
                    .font(kernedFont: .Secondary.p2MediumKerned())
                    .foregroundColor(.ebony)
            }
            .transition(.opacity)
        }
    }
}

struct CreatorShowDetailHeaderView: View {
    
    let creator: Creator
    let onSelectCreator: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MinimizedCreatorProfileView(creator: creator, onSelect: onSelectCreator)
            FollowCreatorView()
        }
        .padding([.leading, .top], 16)
        .frame(maxWidth: .infinity, maxHeight: 85, alignment: .topLeading)
        .background(LinearGradient(colors: [.jet.opacity(0.25), .clear], startPoint: .top, endPoint: .bottom))
    }
}

struct VideoPlayerLoadingIndicator: View {
    
    var body: some View {
        ProgressView()
            .tint(.darkGreen)
            .scaleEffect(1.2)
            .frame(width: 40, height: 36)
            .background(Color.beige.opacity(0.2), in: RoundedRectangle(cornerRadius: 3))
    }
}

struct DimmedLiveStreamView<Content_: View>: ViewModifier {
    
    let isPresented: Bool
    @ViewBuilder let supplementaryView: Content_
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    Color.jet.opacity(0.32)
                }
            }
            .blur(radius: isPresented ? 1 : 0, opaque: false)
            .overlay {
                if isPresented {
                    supplementaryView
                        .transition(.opacity)
                }
            }
            .animation(.easeOut, value: isPresented)
    }
}

struct InterruptionView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            VideoPlayerLoadingIndicator()
            Text(message.uppercased())
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.white)
        }
    }
}

struct LiveStreamConnectingView: View {
    
    var thumbnailURL: URL?
    
    var body: some View {
        ZStack {
            if let thumbnailURL {
                AsyncImageView(imageURL: thumbnailURL)
            } else {
                Color.cappuccino
            }
            
            VStack(spacing: 16) {
                ProgressView()
                    .tint(.darkGreen)
                Text(Strings.ShowDetail.connectingToLiveStreamMessage.uppercased())
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(thumbnailURL != nil ? .white : .ebony)
                    .padding(.bottom, 16)
            }
            .padding(16)
            .background(thumbnailURL != nil ? Color.jet.opacity(0.2) : .clear, in: RoundedRectangle(cornerRadius: 4))
        }
        .cornerRadius(12)
    }
}

#if DEBUG
struct ShowDetailComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            PlayVideoStreamIndicator()
                .frame(height: 50)
            VideoPlayerLoadingIndicator()
            LiveStreamEndedView(onBackAction: {})
            ScheduledShowTimerView(show: .scheduled)
            CreatorShowDetailHeaderView(creator: .creator, onSelectCreator: {})
        }
        .padding()
        .background(Color.black.opacity(0.3))

        VStack {
            LiveStreamConnectingView()
            LiveStreamConnectingView(thumbnailURL: URL(string: "google.com/web"))
        }
        .padding(.horizontal)
        .previewDisplayName("Live stream connecting")
    }
}
#endif
