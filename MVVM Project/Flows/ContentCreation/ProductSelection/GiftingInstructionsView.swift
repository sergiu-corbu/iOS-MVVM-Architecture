//
//  GiftingInstructionsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.07.2023.
//

import SwiftUI

struct GiftingInstructionsView: View {
    
    let instructions: String
    
    //Internal
    @State private var isExpanded = false
    private let attributedInstructions: AttributedString
    
    //Computed
    private var isTextExpandable: Bool {
        return instructions.count > 100
    }
    private var attributedTextContainerLineLimit: Int? {
        guard isTextExpandable else {
            return nil
        }
        return isExpanded ? nil : 2
    }
    
    init(instructions: String) {
        self.instructions = instructions
        let attributedString = (try? AttributedString(markdown: instructions)) ?? AttributedString(instructions)
        self.attributedInstructions = attributedString
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.ContentCreation.giftingInstructions)
                .font(kernedFont: .Secondary.p4MediumKerned)
                .foregroundColor(.jet)
            Text(attributedInstructions)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .lineLimit(attributedTextContainerLineLimit)
                .foregroundColor(.brightGold)
                .tint(.brightGold)
                .transaction { textView in
                    textView.animation = nil
                }
            seeMoreButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.beige, in: RoundedRectangle(cornerRadius: 8))
        .roundedBorder(Color.paleSilver)
        .animation(.linear, value: isExpanded)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder private var seeMoreButton: some View {
        if isTextExpandable {
            Button {
                isExpanded = !isExpanded
            } label: {
                Text(isExpanded ? Strings.Buttons.seeLess : Strings.Buttons.seeMore)
                    .font(kernedFont: .Secondary.p1BoldKerned)
                    .foregroundColor(.brightGold)
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
struct GiftingInstructionsView_Previews: PreviewProvider {
    
    static let message = "Pick products https://google.com from #thiscollection in addition to lipsticks and skirts."
    static let message1 = "11111111111111111111111111111111111111111111111111"
    
    static var previews: some View {
        VStack {
            GiftingInstructionsView(instructions: message1 + message1)
            GiftingInstructionsView(instructions: message + message + message)
        }
    }
}
#endif
