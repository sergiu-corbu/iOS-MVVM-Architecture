//
//  Shape+Utils.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.12.2022.
//

import Foundation
import UIKit
import SwiftUI

struct RoundedCornerShape: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension UIRectCorner {
    static let topCorners: Self = [.topRight, .topLeft]
    static let bottomCorners: Self = [.bottomRight, .bottomLeft]
}

extension Shape {
    
    func fill<Fill, Stroke>(
        _ fillStyle: Fill,
        strokeBorder strokeStyle: Stroke,
        lineWidth: Double = 1
    ) -> some View where Fill: ShapeStyle, Stroke: ShapeStyle {
        
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(fill(fillStyle))
    }
}

extension InsettableShape {
    
    func fill<Fill, Stroke>(
        _ fillStyle: Fill,
        strokeBorder strokeStyle: Stroke,
        lineWidth: Double = 1
    ) -> some View where Fill: ShapeStyle, Stroke: ShapeStyle {
        
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

extension EdgeInsets {
    
    static var zero: Self {
        return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}
