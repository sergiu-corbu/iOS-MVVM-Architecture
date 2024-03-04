//
//  LiveStreamIndicatorView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 21.03.2023.
//

import SwiftUI

struct PulsatingTagViewModifier: ViewModifier {
    
    var minAlpha: CGFloat = 0
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 1 : minAlpha)
            .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

struct LiveStreamIndicatorView: View {

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.forrestGreen)
                .frame(width: 8, height: 8)
                .modifier(PulsatingTagViewModifier())
                .offset(y: -1)
            Text(Strings.ShowDetail.liveTag.uppercased())
                .font(kernedFont: .Secondary.p2MediumKerned())
                .foregroundColor(.ebony)
        }
    }
}

struct FadedLiveStreamIndicatorView: View {

    var gradientColors: [Color] = [.ebony, .orangish, .brightGold]

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.forrestGreen)
                .frame(width: 4, height: 4)
            Text(Strings.ShowDetail.liveTag.uppercased())
                .font(kernedFont: .Secondary.p2MediumKerned())
                .foregroundStyle(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))
        }
        .padding(4)
        .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 2))
        .modifier(PulsatingTagViewModifier(minAlpha: 0.4))
    }
}

#if DEBUG
struct LiveStreamIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            LiveStreamIndicatorView()
            FadedLiveStreamIndicatorView()
        }
        .padding()
        .background(Color.midGrey)
    }
}
#endif
