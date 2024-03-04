//
//  ProgressState.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.11.2022.
//

import Foundation

enum ProgressState: Equatable {
 
    case idle
    case progress(CGFloat)
}

extension ProgressState {
    
    static func createStaticStates(currentIndex: Int, maxIndex: Int = 4) -> [Self] {
        var result = [Self]()
        for index in 0..<maxIndex {
            result.append(index >= currentIndex ? .idle : .progress(1))
        }
        return result
    }
}
