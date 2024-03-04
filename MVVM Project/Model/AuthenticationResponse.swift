//
//  AuthenticationResponse.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation

struct AuthenticationResponse: Decodable {
    
    let user: User
    let accessToken: String
    let refreshToken: String
}
