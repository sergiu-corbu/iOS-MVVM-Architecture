//
//  KernedFont.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.10.2022.
//

import SwiftUI

struct KernedFont {
    let font: Font
    let kern: CGFloat
}

extension KernedFont {
    
    /// PlayfairDisplay
    struct Main {
        /// PlayfairDisplay-Regular
        /// 36px
        /// Kern 0.2
        static var h1RegularKerned: KernedFont {
            .init(font: .Main.h1Regular, kern: 0.2)
        }
        
        /// PlayfairDisplay-Medium
        /// 24px
        /// Kern 0.05
        static var h1MediumKerned: KernedFont {
            .init(font: .Main.h1Medium, kern: 0.5)
        }
        
        /// PlayfairDisplay-Medium
        /// 22px
        /// Kern 0.5
        static var h2MediumKerned: KernedFont {
            .init(font: .Main.h2Medium, kern: 0.5)
        }
        
        /// PlayfairDisplay-Regular
        /// 15px
        /// Kern 0.5
        static var p1RegularKerned: KernedFont {
            .init(font: .Main.p1Regular, kern: 0.5)
        }
        
        /// PlayfairDisplay-Medium
        /// 14px
        /// Kern 0.5
        static var p1MediumKerned: KernedFont {
            .init(font: .Main.p1Medium, kern: 0.5)
        }
        
        /// PlayfairDisplay-Regular
        /// 14px
        /// Kern 0.5
        static var p2RegularKerned: KernedFont {
            .init(font: .Main.p2Regular, kern: 0.5)
        }
        
        /// PlayfairDisplay-Medium
        /// 13px
        /// Kern 0.5
        static var p2MediumKerned: KernedFont {
            .init(font: .Main.p2Medium, kern: 0.5)
        }
        
    
        /// PlayfairDisplay-Bold
        /// 22px
        /// Kern 0.5
        static var h1BoldKerned: KernedFont {
            .init(font: .Main.h1Bold, kern: 0.5)
        }
        
        /// PlayfairDisplay-Bold
        /// 14px
        /// Kern 0.7
        static var h2BoldKerned: KernedFont {
            .init(font: .Main.h2Bold, kern: 0.7)
        }
        
        /// PlayfairDisplay-Bold
        /// 13px
        /// Kern 5
        static var h3BoldKerned: KernedFont {
            .init(font: .Main.h3Bold, kern: 5)
        }
    }
    
    /// Manrope
    struct Secondary {
        
        /// Manrope-Regular
        /// 13px
        /// Kern 0.3
        static var p1RegularKerned: KernedFont {
            .init(font: .Secondary.p1Regular, kern: 0.3)
        }
        
        /// Manrope-Medium
        /// 14px
        /// Kern 0.05
        static var p1MediumKerned: KernedFont {
            .init(font: .Secondary.p1Medium, kern: 0.5)
        }
        
        /// Manrope-Bold
        /// 13px
        /// Kern 0.3
        static var p1BoldKerned: KernedFont {
            .init(font: .Secondary.p1Bold, kern: 0.3)
        }
        
        /// Manrope-Regular
        /// 12px
        /// Kern 0.2
        static var p2RegularKerned: KernedFont {
            .init(font: .Secondary.p2Regular, kern: 0.2)
        }
        
        /// Manrope-Medium
        /// 12px
        /// Kern 0.5
        static func p2MediumKerned(_ kern: CGFloat = 0.5) -> KernedFont {
            .init(font: .Secondary.p2Medium, kern: kern)
        }
        
        /// Manrope-Bold
        /// 14px
        /// Kern 0.3
        static var p2BoldKerned: KernedFont {
            .init(font: .Secondary.p1Bold, kern: 0.3)
        }
        
        /// Manrope-Regular
        /// 11px
        /// Kern 0.1
        static var p3RegularKerned: KernedFont {
            .init(font: .Secondary.p3Regular, kern: 0.1)
        }
        
        /// Manrope-Regular
        /// 11px
        /// Kern 1
        static var p3RegularExtraKerned: KernedFont {
            .init(font: .Secondary.p3Regular, kern: 1)
        }
        
        /// Manrope-Medium
        /// 12px
        /// Kern 0.3
        static var p3MediumKerned: KernedFont {
            .init(font: .Secondary.p2Medium, kern: 0.3)
        }
        
        /// Manrope-Bold
        /// 12px
        /// Kern 0.2
        static var p3BoldKerned: KernedFont {
            .init(font: .Secondary.p3Bold, kern: 0.2)
        }
        
        /// Manrope-Bold
        /// 12px
        /// Kern 1
        static var p3BoldExtraKerned: KernedFont {
            .init(font: .Secondary.p3Bold, kern: 1)
        }
        
        /// Manrope-Regular
        /// 13px
        /// Kern 0.2
        static var p4RegularKerned: KernedFont {
            .init(font: .Secondary.p1Regular, kern: 0.2)
        }
        
        /// Manrope-Medium
        /// 12px
        /// Kern 0.2
        static var p4MediumKerned: KernedFont {
            .init(font: .Secondary.p2Medium, kern: 0.2)
        }
        
        /// Manrope-Bold
        /// 11px
        /// Kern 0.1
        static var p4BoldKerned: KernedFont {
            .init(font: .Secondary.p4Bold, kern: 0.1)
        }
        
        /// Manrope-Regular
        /// 14px
        /// Kern 1
        static var p5RegularKerned: KernedFont {
            .init(font: .Secondary.p4Regular, kern: 0.1)
        }
        
        /// Manrope-Bold
        /// 14px
        /// Kern 1
        static var p5BoldKerned: KernedFont {
            .init(font: .Secondary.p1Bold, kern: 0.1)
        }
        
        /// Manrope-Medium
        /// 14px
        /// Kern 0.3
        static var p5MediumKerned: KernedFont {
            .init(font: .Secondary.p1Medium, kern: 0.3)
        }
    }
}
