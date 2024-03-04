//
//  ButtonStyles.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import Foundation
import SwiftUI

struct ButtonStyles {
    
    struct Scaled: ButtonStyle {
        
        let scale: CGFloat
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.95 : 1)
                .scaleEffect(configuration.isPressed ? scale : 1, anchor: .center)
                .animation(.easeInOut(duration: 0.25), value: configuration.isPressed)
        }
    }
    
    struct FilledRounded: ButtonStyle {
        
        let isEnabled: Bool
        let fillColor: Color
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.5 : 1)
                .padding(.all, 16)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isEnabled ? fillColor : .cultured)
                )
                .roundedBorder(isEnabled ? .clear : .midGrey)
                .padding([.horizontal, .bottom], 16)
        }
    }
    
    struct BorderedFilled: ButtonStyle {
        
        let isEnabled: Bool
        let lineWidth: CGFloat
        let borderColor: Color
        var height: CGFloat = 56
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.5 : 1)
                .padding(.all, 16)
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: lineWidth)
                        .fill(isEnabled ? borderColor : .cappuccino)
                        .background(Color.white.opacity(0.001))
                }
        }
    }
    
    struct Bordered: ButtonStyle {
        
        let isEnabled: Bool
        let lineWidth: CGFloat
        let borderColor: Color
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.5 : 1)
                .padding(.all, 16)
                .frame(height: 40)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: lineWidth)
                        .fill(isEnabled ? borderColor : .cappuccino)
                        .background(Color.white.opacity(0.001))
                }
                .padding(.horizontal, 16)
        }
    }


    struct Fillable: ButtonStyle {
        
        let isSelected: Bool
        
        func makeBody(configuration: Configuration) -> some View {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.darkGreen : .white.opacity(0.001))
                    .roundedBorder(isSelected ? .clear : .middleGrey)
                configuration.label
                    .opacity(configuration.isPressed ? 0.5 : 1)
                    .minimumScaleFactor(0.9)
                    .padding(16)
            }
            .frame(height: 56)
            .animation(.easeIn(duration: 0.1), value: isSelected)
                
        }
    }
}

extension ButtonStyle where Self == ButtonStyles.Scaled {
    
    static var scaled: Self {
        return ButtonStyles.Scaled(scale: 0.995)
    }
    
    static var heavyScaled: Self {
        return ButtonStyles.Scaled(scale: 0.975)
    }
}
