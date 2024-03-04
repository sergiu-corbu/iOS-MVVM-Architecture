//
//  SelectVariantsBannerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.09.2023.
//

import SwiftUI

struct SelectVariantsBannerView: View {
    
    var backgroundColor: Color = .cultured.opacity(0.9)
    
    var body: some View {
        HStack(spacing: 8) {
            Image(.informativeIcon)
            Text(Strings.ProductsDetail.selectAllVariants)
                .font(kernedFont: .Secondary.p1BoldKerned)
                .foregroundColor(.jet)
        }
        .padding(16)
        .background(backgroundColor)
        .border(backgroundColor, cornerRadius: 5)
        .shadow(color: .black.opacity(0.1), radius: 3, y: 4)
        .transition(.transparentMoveScale().combined(with: .move(edge: .bottom)))
    }
}

#if DEBUG
struct SelectVariantsBannerView_Previews: PreviewProvider {
    
    static var previews: some View {
        StatefulPreviewWrapper(false) { isPresented in
            Color.random
                .onTapGesture {
                    isPresented.wrappedValue.toggle()
                }
                .overlay(alignment: .bottom) {
                    if isPresented.wrappedValue {
                        SelectVariantsBannerView()
                    }
                }
                .animation(.linear(duration: 0.5), value: isPresented.wrappedValue)
        }
    }
}
#endif
