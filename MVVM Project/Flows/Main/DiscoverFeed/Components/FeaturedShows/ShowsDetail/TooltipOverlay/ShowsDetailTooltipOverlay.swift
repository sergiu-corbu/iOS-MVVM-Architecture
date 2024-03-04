//
//  ShowsDetailTooltipOverlay.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 12.04.2023.
//

import SwiftUI

struct ShowsDetailTooltipOverlay: View {
    
    @ObservedObject var viewModel: ShowsDetailTooltipViewModel
    private var rotationRadians: Double {
        return (1 - viewModel.progress) * -(.pi * 0.6)
    }
    
    var body: some View {
        gradientOverlay
            .overlay(alignment: .bottom) {
                contentView.padding(.bottom, 108)
            }
    }
    
    private var contentView: some View {
        VStack(spacing: 20) {
            Image(.handSwipeGlyph)
                .renderingMode(.template)
                .foregroundColor(Color.lightGrey)
                .rotationEffect(.radians(rotationRadians), anchor: .center)
            Text(Strings.ShowDetail.showTooltipMessage)
                .font(kernedFont: .Secondary.p1BoldKerned)
                .foregroundColor(.lightGrey)
        }
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            gradient: Gradient(colors: [.clear, Color(0x3D3F40)]),
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#if DEBUG
struct ShowsDetailTooltipOverlay_Previews: PreviewProvider {
    
    static var previews: some View {
        ShowsDetailTooltipOverlay(viewModel: ShowsDetailTooltipViewModel())
            .background(Color.red)
    }
}
#endif
