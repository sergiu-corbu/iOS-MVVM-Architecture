//
//  Animation+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 10.02.2023.
//

import SwiftUI

extension Animation {
    
    static let hero = Animation.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.6)
    static let bouncy = Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: false)
}
