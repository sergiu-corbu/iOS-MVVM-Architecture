//
//  Double+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.12.2022.
//

import Foundation

extension Double {
    
    func currencyFormatted(
        maxFractionDigits: Int = 2,
        decimalSeparator: String = ",",
        isValueInCents: Bool = false
    ) -> String? {
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.decimalSeparator = decimalSeparator
        
        var value: Double = self
        if isValueInCents {
            value = self / 100
        }
        return formatter.string(from: NSNumber(value: value))
    }
    
    var percentFormatted: Int {
        return Int(self * 100)
    }
}

extension TimeInterval {
    
    var timeString: String {
        let time = Int(self)
        let hours = time / 3600
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    var shortTimeString: String {
        let time = Int(self)
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format: "%01i:%02i", minutes, seconds)
    }
    
    var elapsedTimeString: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        formatter.allowsFractionalUnits = true
        
        return formatter.string(from: self) ?? ""
    }
}
