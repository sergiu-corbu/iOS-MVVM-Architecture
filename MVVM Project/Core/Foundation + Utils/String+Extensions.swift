//
//  String+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 10.01.2023.
//

import Foundation

extension StringProtocol {
    
    func startIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    
    var firstLetterUppercased: String {
        return prefix(1).uppercased() + lowercased().dropFirst()
    }
}


extension String {
    
    var fullNameSplitted: String {
        let subComponents = split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        return subComponents.joined(separator: "\n")
    }
    
    func removeNewLines(delimiter: String = "") -> String {
        return replacingOccurrences(of: "\n", with: delimiter, options: .regularExpression)
    }
    
    func pluralizedIfNeeded(_ value: Int) -> String {
        guard value > 1 else {
            return self
        }
        return self.appending("s")
    }
    
    var nilIfEmpty: String? {
        return self.isEmpty ? nil : self
    }
    
    func numberFromString() -> Int? {
        return components(separatedBy: .decimalDigits.inverted)
            .compactMap { Int($0) }.first
    }
    
    func chunk(by length: Int) -> [String] {
        stride(from: 0, to: count, by: length).map {
            let start = index(startIndex, offsetBy: $0)
            let end = index(start, offsetBy: length, limitedBy: endIndex) ?? endIndex
            return String(self[start..<end])
        }
    }
}
