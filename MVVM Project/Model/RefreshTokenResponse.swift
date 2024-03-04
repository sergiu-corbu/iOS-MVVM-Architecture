//
//  RefreshTokenResponse.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.06.2023.
//

import Foundation

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
