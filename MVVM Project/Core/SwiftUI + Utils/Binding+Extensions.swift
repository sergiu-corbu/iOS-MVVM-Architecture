//
//  Binding+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.11.2022.
//

import SwiftUI

extension Binding {
    
    func withDefault<T>(_ defaultValue: T) -> Self where Value == Optional<T> {
        return Binding(get: {
            return self.wrappedValue ?? defaultValue
        }, set: { newValue in
            self.wrappedValue = newValue
        })
    }
}

extension Binding where Value == String {
    
    func lowercased() -> Self {
        return Binding(
            get: {
                return wrappedValue
            }, set: { newValue in
                wrappedValue = newValue.lowercased()
            }
        )
    }
}
