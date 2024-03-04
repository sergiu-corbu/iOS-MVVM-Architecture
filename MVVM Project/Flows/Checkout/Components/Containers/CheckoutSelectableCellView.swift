//
//  CheckoutSelectableCellView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.12.2023.
//

import SwiftUI

struct CheckoutSelectableCellView<Content: View>: View {
    
    @Binding var isSelected: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        let contentView = HStack(spacing: 16) {
            selectionIndicatorView
            content
                .padding(.vertical, 12)
        }
        .contentShape(.rect)
        .padding(.horizontal, 16)
        .roundedBorder(isSelected ? Color.orangish : .paleSilver, cornerRadius: 4)
        
        return Button {
            isSelected.toggle()
        } label: {
            contentView
        }
        .buttonStyle(.plain)
    }
    
    private var selectionIndicatorView: some View {
        Circle()
            .stroke(isSelected ? Color.darkGreen : .ebony, lineWidth: 1.5)
            .overlay {
                if isSelected {
                    Circle()
                        .fill(Color.darkGreen)
                        .padding(4)
                }
            }
            .frame(width: 18, height: 18)
    }
}

#if DEBUG
#Preview {
    StatefulPreviewWrapper(false) { isSelectedBinding in
        CheckoutSelectableCellView(isSelected: isSelectedBinding) {
            Text("")
        }
        .padding(.horizontal)
    }
}
#endif
