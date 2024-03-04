//
//  DiscoverFeedSectionHeaderView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.11.2023.
//

import SwiftUI

enum DiscoverFeedSectionType: String, Identifiable {
    case productsAndBrands
    case showsAndCreators
    
    var id: String {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .productsAndBrands: return Strings.Discover.productsAndBrands.uppercased()
        case .showsAndCreators: return Strings.Discover.showsAndCreators.uppercased()
        }
    }
}

struct DiscoverFeedSectionHeaderView: View {
    
    @Binding var currentDiscoverSection: DiscoverFeedSectionType
    var onSectionSelected: (() -> Void)?
    @Namespace private var animationNamespace
    
    var body: some View {
        EquallyFilledHStackLayout {
            discoverSectionCell(.productsAndBrands)
            discoverSectionCell(.showsAndCreators)
        }
        .animation(.smooth, value: currentDiscoverSection)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
    
    private func discoverSectionCell(_ sectionType: DiscoverFeedSectionType) -> some View {
        let isCurrent = sectionType == currentDiscoverSection
        return Button {
            if isCurrent {
                return
            }
            currentDiscoverSection = sectionType
            onSectionSelected?()
        } label: {
            Text(sectionType.title)
                .font(kernedFont: .Secondary.p3BoldExtraKerned)
                .foregroundStyle(Color.jet)
                .minimumScaleFactor(0.9)
                .lineLimit(1)
                .frame(height: 26, alignment: .top)
                .background(alignment: .bottom) {
                    if isCurrent {
                        Rectangle()
                            .fill(Color.jet)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: 0, in: animationNamespace, properties: .frame)
                    }
                }
                .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.cappuccino
        StatefulPreviewWrapper(DiscoverFeedSectionType.productsAndBrands) { sectionTypeBinding in
            DiscoverFeedSectionHeaderView(currentDiscoverSection: sectionTypeBinding)
        }
    }
}
#endif
