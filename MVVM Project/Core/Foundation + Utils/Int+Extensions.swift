//
//  Int+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 20.12.2022.
//

import Foundation

extension Int64 {
    
    var estimatedBytesToMB: Self {
        return self / 1_048_576
    }
}

extension FixedWidthInteger {
    
    static var randomID: UInt {
        return UInt.random(in: 0...1000)
    }
}

extension Int: StringIdentifiable {
    public var id: String {
        return self.description
    }
}
