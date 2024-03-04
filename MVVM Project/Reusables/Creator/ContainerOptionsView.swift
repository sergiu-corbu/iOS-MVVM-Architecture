//
//  ContainerOptionsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.11.2022.
//

import SwiftUI

struct ContainerOptionsView: View {
    
    enum ButtonType: CaseIterable {
        case no
        case yes
        
        var buttonTitle: String {
            switch self {
            case .no: return Strings.Buttons.no
            case .yes: return Strings.Buttons.yes
            }
        }
    }
    
    @State private var selectedButtonType: ButtonType?
    
    let title: String
    let action: (ButtonType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundColor(.brownJet)
            HStack(spacing: 8) {
                ForEach(ButtonType.allCases, id: \.self) { buttonType in
                    Buttons.FillableButton(
                        title: buttonType.buttonTitle.capitalized,
                        isSelected: selectedButtonType == buttonType
                    ) {
                        Task {
                            selectedButtonType = buttonType
                            await Task.sleep(seconds: 0.2)
                            action(buttonType)
                        }
                    }
                    .disabled(selectedButtonType != nil)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
struct ContainerOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerOptionsView(
            title: Strings.Authentication.brandPartners, action: {_ in}
        )
    }
}
#endif
