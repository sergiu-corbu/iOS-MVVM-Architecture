//
//  Color + Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    
    static let darkGreen = UIColor(named: "DarkGreen")!
    static let middleGrey = UIColor(named: "MiddleGrey")!
    static let jet = UIColor(named: "Jet")!
    static let brownJet = UIColor(named: "BrownJet")!
    static let cultured = UIColor(named: "Cultured")!
    static let beige = UIColor(named: "Beige")!
    static let cappuccino = UIColor(named: "Cappuccino")!
    static let ebony = UIColor(named: "Ebony")!
    static let lightGrey = UIColor(named: "LightGrey")!
    static let midGrey = UIColor(named: "MidGrey")!
    static let paleSilver = UIColor(named: "PaleSilver")!
    static let brightGold = UIColor(named: "BrightGold")!
    static let orangish = UIColor(named: "Orangish")!
    static let feldgrau = UIColor(named: "Feldgrau")!
    static let silver = UIColor(named: "Silver")!
    static let battleshipGray = UIColor(named: "BattleshipGray")!
}

extension Color {

    static let darkGreen = Color("DarkGreen")
    static let forrestGreen = Color("ForrestGreen")
    static let middleGrey = Color("MiddleGrey")
    static let brownJet = Color("BrownJet")
    static let cultured = Color("Cultured")
    static let beige = Color("Beige")
    static let cappuccino = Color("Cappuccino")
    static let ebony = Color("Ebony")
    static let lightGrey = Color("LightGrey")
    static let midGrey = Color("MidGrey")
    static let paleSilver = Color("PaleSilver")
    static let brightGold = Color("BrightGold")
    static let orangish = Color("Orangish")
    static let feldgrau = Color("Feldgrau")
    static let firebrick = Color("Firebrick")
    static let jet = Color("Jet")
    static let silver = Color("Silver")
    static let battleshipGray = Color("BattleshipGray")
    static let timberwolf = Color("Timberwolf")
    
    static var random: Self {
        Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
    
    static var colorNames = ["Dark Green", "Middle Grey", "Brown Jet", "Creme Cultured", "Beige", "Cappuccino", "Creme", "Ebony", "Light Grey", "Mid Grey", "Pale Silver", "Bright Gold", "Orangish", "Silver"]
    static var allColors = [darkGreen, middleGrey, brownJet, cultured, beige, cappuccino, ebony, lightGrey, midGrey, paleSilver, brightGold, orangish, feldgrau, silver]
}

extension Color {
    init(_ hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
