//
//  Country.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.01.2024.
//

import Foundation

struct Country: Identifiable, Equatable {
    
    let isoCode: String
    let name: String
    
    var id: String { isoCode }
}
