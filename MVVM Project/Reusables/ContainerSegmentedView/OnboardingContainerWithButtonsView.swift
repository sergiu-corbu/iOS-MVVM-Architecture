//
//  OnboardingContainerSegmentedView.swift
//  Bond
//
//  Created by Mihai Mocanu on 16.11.2022.
//

import SwiftUI

struct OnboardingContainerSegmentedView: View {
    @State var isLeftSelected = false
    @State var isRightSelected = false
    
    let title: String
    let onLeftAction: () -> Void
    let onRightAction: () -> Void
    
    var body: some View {
        VStack {
            Text(title)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundColor(.brownJet)
            
            HStack(spacing: 8) {
                FillableButton(title: LocalizedStrings.Buttons.no, isSelected: $isLeftSelected.wrappedValue) {
                    isRightSelected = false
                    isLeftSelected = true
                    
                    onLeftAction()
                }
                FillableButton(title: LocalizedStrings.Buttons.yes, isSelected: $isRightSelected.wrappedValue) {
                    isRightSelected = true
                    isLeftSelected = false
                    
                    onLeftAction()
                }
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
        }
    }
}

#if DEBUG
struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerWithButtonsView(
            title: LocalizedStrings.Authentication.brandPartnershipQuestion,
            onLeftAction: {},
            onRightAction: {}
        )
    }
}
#endif
