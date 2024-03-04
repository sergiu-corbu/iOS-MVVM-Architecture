//
//  CheckboxSelectableView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.12.2023.
//

import SwiftUI

struct CheckboxSelectableView: View {
    
    @Binding var isSelected: Bool
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                isSelected.toggle()
            }, label: {
                SquareStyledCheckmarkView(isSelected: isSelected)
            })
            Text(message)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundStyle(Color.jet)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview {
    StatefulPreviewWrapper(false) { isSelectedBinding in
        CheckboxSelectableView(isSelected: isSelectedBinding, message: "Save for future use.")
    }
}
#endif
