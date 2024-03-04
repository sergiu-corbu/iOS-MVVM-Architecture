//
//  VisualEffectView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.11.2022.
//

import SwiftUI
import UIKit

extension View {
    
    func visualEffectBlur(
        _ blurStyle: UIBlurEffect.Style = .systemMaterial,
        vibrancyStyle: UIVibrancyEffectStyle? = nil
    ) -> some View {
        background(
            VisualEffectView(blurStyle: blurStyle, vibrancyStyle: vibrancyStyle)
        )
    }
}
    
struct VisualEffectView: UIViewRepresentable {
    
    var blurStyle: UIBlurEffect.Style
    var vibrancyStyle: UIVibrancyEffectStyle?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        context.coordinator.blurView
    }
    
    func updateUIView(_ view: UIVisualEffectView, context: Context) {
        context.coordinator.update(blurStyle: blurStyle, vibrancyStyle: vibrancyStyle)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        
        let blurView = UIVisualEffectView()
        let vibrancyView = UIVisualEffectView()
        
        init() {
            setupEffects()
        }
        
        private func setupEffects() {
            blurView.contentView.addSubview(vibrancyView)
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        func update(blurStyle: UIBlurEffect.Style, vibrancyStyle: UIVibrancyEffectStyle?) {
            let blurEffect = UIBlurEffect(style: blurStyle)
            blurView.effect = blurEffect
            
            if let vibrancyStyle = vibrancyStyle {
                vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect, style: vibrancyStyle)
            } else {
                vibrancyView.effect = nil
            }
            blurView.setNeedsDisplay()
        }
    }
}
