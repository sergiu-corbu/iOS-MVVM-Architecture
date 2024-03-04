//
//  Checkout+Actions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.01.2024.
//

import Foundation

enum CheckoutActionType {
    case dismiss
    case openEmail
    case error(Error)
    case success(CheckoutCart)
    case orderSubmitted(CheckoutCart) // this is a workaround to cover a scenario where success was being logged multiple times
}
