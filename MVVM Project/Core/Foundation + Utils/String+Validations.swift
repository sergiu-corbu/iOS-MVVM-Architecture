//
//  String+Validations.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import Foundation

extension String {
    
    func isValidEmail() throws {
        let regexPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let email = NSPredicate(format:"SELF MATCHES %@", regexPattern)
        if !email.evaluate(with: self) {
            throw AuthenticationError.invalidEmail
        }
    }
    
    func isValidUsername() throws {
        if self.count < 2 || self.count > 30 {
            throw AuthenticationError.invalidUsername
        }
    }
    
    func isValidWebsite() throws {
        let regexPattern = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let websitePredicate = NSPredicate(format: "SELF MATCHES %@", regexPattern)
        if !websitePredicate.evaluate(with: self) {
            throw AuthenticationError.invalidWebsite
        }
    }
    
    func isValidSocial() throws {
        if self.first != "@" {
            throw AuthenticationError.invalidSocialNetwork
        }
    }
}
