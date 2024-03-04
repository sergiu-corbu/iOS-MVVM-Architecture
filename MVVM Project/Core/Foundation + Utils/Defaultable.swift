//
//  Defaultable.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.07.2023.
//

import Foundation
import Combine

protocol Defaultable {
    static var defaultValue: Self { get }
}

extension Optional where Wrapped: Defaultable {
    var unwrapped: Wrapped {
        return self ?? Wrapped.defaultValue
    }
}

extension AnyPublisher: Defaultable {
    static var defaultValue: Self {
        return Empty<Output, Failure>().eraseToAnyPublisher()
    }
}

