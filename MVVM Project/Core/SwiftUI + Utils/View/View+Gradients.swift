//
//  View+Gradients.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.01.2023.
//

import SwiftUI

extension View {
    
    func fadedGradient(_ color: Color = .jet) -> some View {
        let opacities: [CGFloat] = [0,0.03, 0.06, 0.12, 0.19, 0.28, 0.37, 0.47, 0.56, 0.65, 0.72, 0.78]
        return self.overlay {
            LinearGradient(
                colors: opacities.map({color.opacity($0)}),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    func fadedTransparentGradient(_ color: Color = .cultured) -> some View {
        background {
            let opacities: [CGFloat] = [1, 1, 1, 0.9]
            return LinearGradient(
                colors: opacities.map {color.opacity($0)},
                startPoint: .top, endPoint: .bottom
            )
        }
    }
}

struct IncreasingGradient {
    
    private let colorOpacities: [Double]
    
    init(startValue: Double = .zero, endValue: Double = 1.0, step: Double = 0.1) {
        var _opacities = [startValue]
        var current = startValue + step
        while current < endValue {
            _opacities.append(current)
            current += step
        }
        self.colorOpacities = _opacities
    }
    
    func makeGradient(_ baseColor: Color) -> Gradient {
        return Gradient(colors: colorOpacities.map { baseColor.opacity(CGFloat($0))} )
    }
}
