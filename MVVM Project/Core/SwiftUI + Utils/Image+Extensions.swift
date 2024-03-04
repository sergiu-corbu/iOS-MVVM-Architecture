//
//  Image+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 23.01.2023.
//

import SwiftUI

extension Image {
    
    //MARK: Fill aspect
    func resizedToFill(width: CGFloat?, height: CGFloat?) -> some View {
        return self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
    }
    
    func resizedToFill(size: CGSize?) -> some View {
        return self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size?.width, height: size?.height)
    }
    
    //MARK: Fit aspect
    func resizedToFit(width: CGFloat?, height: CGFloat?) -> some View {
        return self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
    }
    
    func resizedToFit(size: CGSize?) -> some View {
        return self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size?.width, height: size?.height)
    }
}
