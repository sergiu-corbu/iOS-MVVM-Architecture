//
//  SelectableHeaderSectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.09.2023.
//

import SwiftUI

protocol HeaderSectionCountable: Hashable {
    
    var id: String { get }
    var sectionTitle: String { get }
    var count: Int { get }
}

extension HeaderSectionCountable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SelectableHeaderSectionView<SectionType: Hashable, Section: HeaderSectionCountable>: View {
    
    @Binding var selectedSection: SectionType
    let sections: [Section]
    let sectionTitle: String
    let onBack: () -> Void
    
    @Namespace private var sectionEffectNamespace
    private let sectionEffectID = "sectionEffectID"
    
    var body: some View {
        VStack(spacing: 8) {
            NavigationBar(inlineTitle: sectionTitle.capitalized, onDismiss: onBack)
            VStack(spacing: 6) {
                HStack(spacing: 56) {
                    ForEach(sections, id: \.sectionTitle) {
                        sectionCellView($0)
                    }
                }
                .padding(.horizontal, 30)
                .animation(.easeInOut, value: selectedSection)
                DividerView()
            }
        }
    }
    
    private func sectionCellView(_ section: Section) -> some View {
        let isSelected = section.hashValue == selectedSection.hashValue
        return Button(action: {
            if isSelected {
                return
            }
            if let castedID = section.id as? SectionType {
                selectedSection = castedID
            }
        }, label: {
            Text(section.sectionTitle + " (\(section.count))")
                .font(kernedFont: .Secondary.p5RegularKerned)
                .foregroundColor(isSelected ? .jet : .middleGrey)
                .monospacedDigit()
                .animation(.linear, value: section.count)
                .background(alignment: .bottom) {
                    if isSelected {
                        Rectangle()
                            .fill(Color.jet)
                            .frame(height: 2)
                            .offset(y: 6)
                            .matchedGeometryEffect(id: sectionEffectID, in: sectionEffectNamespace, properties: .position)
                    }
                }
        })
        .buttonStyle(.plain)
    }
}
