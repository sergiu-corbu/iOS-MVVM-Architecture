//
//  DispatchQueue+Utils.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.11.2022.
//

import Foundation

extension DispatchQueue {
    
    func asyncAfter(seconds: TimeInterval, action: @escaping () -> Void) {
        asyncAfter(deadline: .now() + seconds, execute: action)
    }
}
