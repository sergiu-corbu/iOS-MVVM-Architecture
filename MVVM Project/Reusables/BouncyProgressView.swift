//
//  BouncyProgressView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 23.02.2023.
//

import SwiftUI

struct BouncyProgressView: View {
    
    var tint: Color = .brightGold
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometryProxy in
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color.midGrey)
                    .frame(height: 1)
                bouncyLine(in: geometryProxy.size.width)
            }
            .clipped(antialiased: true)
            .onAppear {
                isAnimating = true
            }
        }
        .frame(height: 2)
    }
    
    private func bouncyLine(in availableWidth: CGFloat) -> some View {
        let barWidth = availableWidth / 3
        return Rectangle()
            .fill(
                LinearGradient(
                    colors: [.ebony, .brightGold, .brightGold, .ebony],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .frame(width: barWidth)
            .offset(x: isAnimating ? availableWidth + barWidth : -barWidth)
            .animation(.bouncy, value: isAnimating)
    }
}

#if DEBUG
struct BouncyProgressView_Previews: PreviewProvider {
    static var previews: some View {
        BouncyProgressView()
            .padding(.horizontal)
    }
}
#endif
