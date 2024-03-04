//
//  Font + Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import SwiftUI
import UIKit

fileprivate enum MainFontName: String {
    case playfairDisplay_regular = "PlayfairDisplay-Regular"
    case playfairDisplay_medium = "PlayfairDisplay-Medium"
    case playfairDisplay_italic = "PlayfairDisplay-Italic"
    case playfairDisplay_bold = "PlayfairDisplay-Bold"
}

fileprivate enum SecondaryFontName: String {
    case manrope_regular = "Manrope-Regular"
    case manrope_medium = "Manrope-Medium"
    case manrope_bold = "Manrope-Bold"
}

extension UIFont {
    
    struct Main {
        
        static func regular(_ size: CGFloat) -> UIFont! {
            return UIFont(name: MainFontName.playfairDisplay_regular.rawValue, size: size)
        }
        
        static func italic(_ size: CGFloat) -> UIFont! {
            return UIFont(name: MainFontName.playfairDisplay_italic.rawValue, size: size)
        }
        
        static func medium(_ size: CGFloat) -> UIFont! {
            return UIFont(name: MainFontName.playfairDisplay_medium.rawValue, size: size)
        }
        
        static func bold(_ size: CGFloat) -> UIFont! {
            return UIFont(name: MainFontName.playfairDisplay_bold.rawValue, size: size)
        }
    }
    
    struct Secondary {
        
        static func regular(_ size: CGFloat) -> UIFont! {
            return UIFont(name: SecondaryFontName.manrope_regular.rawValue, size: size)
        }
        
        static func bold(_ size: CGFloat) -> UIFont! {
            return UIFont(name: SecondaryFontName.manrope_bold.rawValue, size: size)
        }
        
        static func medium(_ size: CGFloat) -> UIFont! {
            return UIFont(name: SecondaryFontName.manrope_medium.rawValue, size: size)
        }
    }
}

extension Font {
    
    /// PlayfairDisplay
    struct Main {
        static func regular(_ size: CGFloat) -> Font {
            Font.custom(MainFontName.playfairDisplay_regular.rawValue, size: size)
        }
        
        static func medium(_ size: CGFloat) -> Font {
            Font.custom(MainFontName.playfairDisplay_medium.rawValue, size: size)
        }
        
        static func italic(_ size: CGFloat = 34) -> Font {
            Font.custom(MainFontName.playfairDisplay_italic.rawValue, size: size)
        }
        
        static func bold(_ size: CGFloat) -> Font {
            Font.custom(MainFontName.playfairDisplay_bold.rawValue, size: size)
        }
        
        //MARK: - Regular
        
        /// PlayfairDisplay-Regular
        /// 36px
        static var h1Regular: Font {
            regular(36)
        }
        
        /// PlayfairDisplay-Regular
        /// 15px
        static var p1Regular: Font {
            regular(15)
        }
        
        /// PlayfairDisplay-Regular
        /// 14px
        static var p2Regular: Font {
            regular(14)
        }
        
        //MARK: - Medium
        
        /// PlayfairDisplay-Medium
        /// 24px
        static var h1Medium: Font {
            medium(24)
        }
        
        /// PlayfairDisplay-Medium
        /// 22px
        static var h2Medium: Font {
            medium(22)
        }
        
        /// PlayfairDisplay-Medium
        /// 14px
        static var p1Medium: Font {
            medium(14)
        }
        
        /// PlayfairDisplay-Medium
        /// 13px
        static var p2Medium: Font {
            medium(13)
        }
        
        //MARK: - Italic
        
        /// PlayfairDisplay-Italic
        /// 34px
        static var h1Italic: Font {
            italic()
        }
        
        /// PlayfairDisplay-Italic
        /// 24px
        static var h2Italic: Font {
            italic(24)
        }
        
        //MARK: - Bold
        
        /// PlayfairDisplay-Bold
        /// 22px
        static var h1Bold: Font {
            bold(22)
        }
        
        /// PlayfairDisplay-Bold
        /// 14px
        static var h2Bold: Font {
            bold(14)
        }
        
        /// PlayfairDisplay-Bold
        /// 13px
        static var h3Bold: Font {
            bold(13)
        }
    }
    
    /// Manrope
    struct Secondary {
        
        static func regular(_ size: CGFloat = 14) -> Font {
            Font.custom(SecondaryFontName.manrope_regular.rawValue, size: size)
        }
        
        static func medium(_ size: CGFloat = 14) -> Font {
            Font.custom(SecondaryFontName.manrope_medium.rawValue, size: size)
        }
        
        static func bold(_ size: CGFloat = 14) -> Font {
            Font.custom(SecondaryFontName.manrope_bold.rawValue, size: size)
        }
        
        //MARK: - Regular
        
        /// Manrope-Regular
        /// 13px
        static var p1Regular: Font {
            regular(13)
        }
        
        /// Manrope-Regular
        /// 12px
        static var p2Regular: Font {
            regular(12)
        }
        
        /// Manrope-Regular
        /// 11px
        static var p3Regular: Font {
            regular(11)
        }
        
        /// Manrope-Regular
        /// 14px
        static var p4Regular: Font { 
            regular(14)
        }
        
        //MARK: - Medium
        
        /// Manrope-Medium
        /// 14px
        static var p1Medium: Font {
            medium(14)
        }
        
        /// Manrope-Medium
        /// 12px
        static var p2Medium: Font {
            medium(12)
        }
        
        //MARK: - Bold
        
        /// Manrope-Bold
        /// 14px
        static var p1Bold: Font {
            bold(14)
        }
        
        /// Manrope-Bold
        /// 13px
        static var p2Bold: Font {
            bold(13)
        }
        
        /// Manrope-Bold
        /// 12px
        static var p3Bold: Font {
            bold(12)
        }
        
        /// Manrope-Bold
        /// 11px
        static var p4Bold: Font {
            bold(11)
        }
    }
}
