//
//  ShowsDetailTooltipViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 12.04.2023.
//

import Foundation
import SwiftUI
import UIKit

class ShowsDetailTooltipViewModel: ObservableObject {
    
    // Constants
    let animationDuration: CGFloat = 0.9
    let releaseDuration: CGFloat = 0.3
    let pauseDuration: CGFloat = 0.5
    let repeatDelay: CGFloat = 1
    
    // States
    @Published private(set) var progress: Double = 0
    @Published private(set) var isAnimating: Bool = false
    
    // Internal
    private weak var scrollView: UIScrollView?

    func startAnimating() {
        performCycle()
    }
    
    func stopAnimating() {
        self.scrollView = nil
    }
    
    func performCycle() {
        onStartCycle()
        withAnimation(.easeIn(duration: animationDuration)) {
            self.progress = 1
        }
        DispatchQueue.main.asyncAfter(seconds: animationDuration + pauseDuration) { [weak self] in
            guard let self = self else { return }
            self.onReleaseCycle()
            withAnimation(.easeOut(duration: self.releaseDuration)) {
                self.progress = 0
                DispatchQueue.main.asyncAfter(seconds: self.releaseDuration + self.repeatDelay) { [weak self] in
                    self?.performCycle()
                }
            }
        }
    }
    
    func setupBindings(to scrollView: UIScrollView?) {
        self.scrollView = scrollView
    }
    
    private func onStartCycle() {
        guard let scrollView = self.scrollView else { return }
        UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseIn) {
            scrollView.contentOffset = CGPoint(x: 0, y: 200)
        }
    }
    
    private func onReleaseCycle() {
        guard let scrollView = self.scrollView else { return }
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
}
