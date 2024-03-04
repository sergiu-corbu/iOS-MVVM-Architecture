//
//  CheckoutSectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.12.2023.
//

import SwiftUI

struct CheckoutSectionView<Content: View>: View {
    
    let title: String
    var trailingActionContext: TrailingActionContext?
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title.uppercased())
                    .font(kernedFont: .Secondary.p3BoldExtraKerned)
                    .foregroundStyle(Color.jet)
                Spacer()
                if let trailingActionContext {
                    trailingActionContext.actionButtonView
                }
            }
            .padding(.horizontal, 16)
            content()
        }
    }
    
    enum TrailingActionType {
        case edit
        case clear
        case searchLocation
        
        var title: String {
            switch self {
            case .edit: return Strings.Buttons.edit
            case .clear: return Strings.Buttons.clearAll
            case .searchLocation: return Strings.Buttons.searchLocation
            }
        }
        
        var tint: Color {
            switch self {
            case .edit, .searchLocation: return .orangish
            case .clear: return .firebrick
            }
        }
    }
    
    struct TrailingActionContext {
        let actionType: TrailingActionType
        let action: () -> Void
        
        var actionButtonView: some View {
            Button(action: action, label: {
                Text(actionType.title.uppercased())
                    .font(kernedFont: .Secondary.p3BoldExtraKerned)
                    .foregroundStyle(actionType.tint)
            })
            .buttonStyle(.plain)
        }
    }
}

extension CheckoutSectionView.TrailingActionContext {
    
    init(onEdit: @escaping () -> Void) {
        self.action = onEdit
        self.actionType = .edit
    }
    
    init(onClear: @escaping () -> Void) {
        self.action = onClear
        self.actionType = .clear
    }
    
    init(onSearchLocation: @escaping () -> Void) {
        self.action = onSearchLocation
        self.actionType = .searchLocation
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 40) {
        CheckoutSectionView(title: "Credit Card") {
            Rectangle()
                .frame(height: 50)
        }
        
        CheckoutSectionView(title: "Credit Card", trailingActionContext: .init(onClear: {})) {
            Rectangle()
                .frame(height: 50)
        }
        
        CheckoutSectionView(title: "Credit Card", trailingActionContext: .init(onEdit: { })) {
            Rectangle()
                .frame(height: 50)
        }
    }
}
#endif
