//
//  CustomProgressView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.11.2022.
//

import SwiftUI

struct CustomProgressBar: View {
    
    let title: String
    let percentage: Int
    var textColor: Color = .brownJet
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 14) {
                HStack {
                    Text(Strings.Authentication.progress)
                        .font(kernedFont: .Secondary.p2RegularKerned)
                    Spacer()
                    AnimatedPercentView(percentage: percentage)
                }
                .foregroundColor(textColor)
                barsView(availableWidth: proxy.size.width)
            }
        }
        .frame(height: 36)
        .padding(.horizontal, 16)
    }
    
    private func barsView(availableWidth: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.midGrey)
                .frame(height: 1)
            Rectangle()
                .fill(Color.orangish)
                .frame(width: availableWidth * CGFloat(percentage) / 100)
                .frame(height: 2)
                .offset(y: -1)
                .animation(.easeOut, value: percentage)
        }
    }
}

///Note: set `percentage` in a `withAnimation` block in order to animate the view.
struct AnimatedPercentView: View, Animatable {
    
    typealias AnimatableData = CGFloat
    
    var percentage: Int
    
    var animatableData: AnimatableData {
        get {
            return CGFloat(percentage)
        } set {
            percentage = Int(newValue)
        }
    }
    
    var body: some View {
        Text("\(percentage)%")
            .font(kernedFont: .Secondary.p1BoldKerned)
    }
}

extension CustomProgressBar {
    
    init(percentage: Int, textColor: Color = .brownJet) {
        self.title = Strings.Authentication.progress
        self.percentage = percentage
        self.textColor = textColor
    }
}

struct CustomProgressBarView_Previews: PreviewProvider {
    
    static var previews: some View {
        CustomProgressBarPreviews()
    }
    
    struct CustomProgressBarPreviews: View {
        
        @State var percentage: Int = 0
        
        var body: some View {
            VStack {
                Button("Random") {
                   // withAnimation {
                        percentage = percentage + 10
                    //}
                }
                CustomProgressBar(
                    title: Strings.Authentication.progress,
                    percentage: percentage
                )
            }
        }
    }
}
