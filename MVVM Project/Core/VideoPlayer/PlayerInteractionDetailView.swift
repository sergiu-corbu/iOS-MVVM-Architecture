//
//  PlayerInteractionDetailView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.05.2023.
//

import SwiftUI
import Combine

struct PlayerInteractionDetailView: View {
    
    let maximumValue: TimeInterval
    let currentValuePublisher: PassthroughSubject<TimeInterval, Never>
    @State private var currentValue: TimeInterval = .zero
    
    var body: some View {
        HStack(spacing: 4) {
            Text(currentValue.shortTimeString)
                .font(kernedFont: .Secondary.p2BoldKerned)
                .foregroundColor(.cultured)
            Text("/")
                .font(kernedFont: .Secondary.p2BoldKerned)
                .foregroundColor(.cultured)
            Text(maximumValue.shortTimeString)
                .font(kernedFont: .Secondary.p2BoldKerned)
                .foregroundColor(.middleGrey)
        }
        .monospacedDigit()
        .onReceive(currentValuePublisher) { newValue in
            self.currentValue = newValue
        }
    }
}

#if DEBUG
struct PlayerInteractionDetailView_Previews: PreviewProvider {

    static var previews: some View {
        PlayerInteractionDetailView(maximumValue: 14000, currentValuePublisher: .init())
            .padding()
            .background(Color.orange)
            .previewLayout(.sizeThatFits)
    }
}
#endif
