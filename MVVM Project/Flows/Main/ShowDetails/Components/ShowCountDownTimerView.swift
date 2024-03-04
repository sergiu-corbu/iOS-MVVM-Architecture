//
//  ShowCountDownTimerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.03.2023.
//

import SwiftUI

extension View {
    
    func timerStyleModifier(tint: Color = .ebony) -> some View {
        return self
            .foregroundColor(.ebony)
            .monospacedDigit()
            .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
            .background(Color.beige, in: RoundedRectangle(cornerRadius: 5))
            .transition(.opacity.animation(.easeInOut))
    }
}

struct ShowCountDownTimerView: View {
    
    let publishDate: Date
    var onCountDownTimerReached: (() -> Void)?
    
    init(publishDate: Date, onCountDownTimerReached: (() -> Void)? = nil) {
        self.publishDate = publishDate
        self.onCountDownTimerReached = onCountDownTimerReached
        self._remainingTime = State(initialValue: publishDate.timeIntervalSinceNow)
    }
    
    @State private var remainingTime: TimeInterval
    @State private var timer: Timer?
    
    var body: some View {
        if remainingTime > 1 {
            Text(remainingTime.timeString + " LEFT")
                .font(kernedFont: .Secondary.p2MediumKerned())
                .timerStyleModifier()
                .onAppear(perform: startTimer)
        }
    }
    
    private func startTimer() {
        remainingTime = publishDate.timeIntervalSinceNow
        timer = .scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            remainingTime = publishDate.timeIntervalSinceNow
            if remainingTime < 1 {
                timer?.invalidate()
                onCountDownTimerReached?()
            }
        }
    }
}

struct LiveStreamElapsedTimeView: View {
    
    @State private var elapsedTime: TimeInterval
    @State private var timer: Timer?
    
    init(startDate: Date = .now) {
        self._elapsedTime = State(wrappedValue: startDate.timeIntervalSinceNow + 1)
    }
    
    var body: some View {
        Text(elapsedTime.elapsedTimeString)
            .font(kernedFont: .Secondary.p2MediumKerned())
            .timerStyleModifier()
            .onAppear(perform: startTimer)
            .onDisappear(perform: timer?.invalidate)
    }
    
    private func startTimer() {
        timer = .scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }
}

#if DEBUG
struct ShowCountDownTimerView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            ZStack {
                VStack {
                    LiveStreamElapsedTimeView()
                    ShowCountDownTimerView(publishDate: .now.addingTimeInterval(4))
                }
            }
            ZStack {
                ShowCountDownTimerView(publishDate: .now.addingTimeInterval(30_000))
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
