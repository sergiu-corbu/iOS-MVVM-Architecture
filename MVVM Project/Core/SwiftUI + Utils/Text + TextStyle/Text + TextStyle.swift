//
//  Text + TextStyle.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.05.2021.
//

import Foundation
import SwiftUI

extension Text {
    
    func font(kernedFont: KernedFont) -> Text {
        self
            .font(kernedFont.font)
            .kerning(kernedFont.kern)
    }
    
    func textStyle<S>(_ style: S) -> some View where S : TextStyle {
        return style.makeBody(text: self)
    }
}

protocol TextStyle {
    
    associatedtype Body : View
    func makeBody(text: Text) -> Self.Body
}

extension TextStyle where Self == ToastMessageTextStyle {
    
    static var toastMessage: Self {
        ToastMessageTextStyle()
    }
}

extension TextStyle where Self == ShowTitleTextStyle {
    
    static var showTitle: Self {
        ShowTitleTextStyle()
    }
}

extension TextStyle where Self == OutlinedHeaderTextStyle {
    
    static func outlinedHeader(tint: Color = .middleGrey) -> Self {
        OutlinedHeaderTextStyle(tint: tint)
    }
}


struct ToastMessageTextStyle: TextStyle {
    
    func makeBody(text: Text) -> some View {
        text
            .font(.Secondary.p1Regular)
            .foregroundColor(.middleGrey)
            .lineLimit(2)
            .minimumScaleFactor(0.9)
    }
}

struct ShowTitleTextStyle: TextStyle {
    
    func makeBody(text: Text) -> some View {
        text
            .font(kernedFont: .Main.h2MediumKerned)
            .foregroundColor(.cultured)
            .lineLimit(3)
            .minimumScaleFactor(0.9)
            .multilineTextAlignment(.leading)
    }
}

struct OutlinedHeaderTextStyle: TextStyle {
    
    let tint: Color
    
    func makeBody(text: Text) -> some View {
        text
            .font(kernedFont: .Secondary.p1BoldKerned)
            .foregroundColor(tint)
            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
            .background(Capsule().stroke(tint))
    }
}
