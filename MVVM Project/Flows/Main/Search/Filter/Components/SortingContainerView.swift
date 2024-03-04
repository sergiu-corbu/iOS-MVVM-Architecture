//
//  SortingContainerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 24.08.2023.
//

import SwiftUI

enum PriceSortingType: Int, CaseIterable, Identifiable {
    
    case lowToHigh
    case highToLow
    
    var id: Int {
        return rawValue
    }
    
    var sortDirection: String {
        switch self {
        case .lowToHigh: return "asc"
        case .highToLow: return "desc"
        }
    }
    
    var title: String {
        switch self {
        case .lowToHigh: return Strings.FilterAndSort.lowToHigh
        case .highToLow: return Strings.FilterAndSort.highToLow
        }
    }
    
    var imageName: String {
        switch self {
        case .lowToHigh: return "arrow.up"
        case .highToLow: return "arrow.down"
        }
    }
}

struct SortingContainerView: View {
    
    @Binding var selectedSortingType: PriceSortingType?
    
    var body: some View {
        VStack(spacing: 16) {
            Text(Strings.FilterAndSort.sortByPrice)
                .textStyle(.outlinedHeader())
            sortingOptionsStackView
        }
        .padding(.horizontal, 16)
    }
    
    private var sortingOptionsStackView: some View {
        HStack(spacing: 8) {
            ForEach(PriceSortingType.allCases) {
                priceSortingCell($0)
            }
        }
    }
    
    private func priceSortingCell(_ sortingType: PriceSortingType) -> some View {
        let isSelected = selectedSortingType == sortingType
        let cellContent = Capsule(style: .continuous)
            .fill(isSelected ? Color.cappuccino : .clear)
            .animation(.easeOut(duration: 0.3), value: isSelected)
            .roundedBorder(Color.ebony.opacity(0.15), cornerRadius: 35)
            .frame(height: 44)
            .overlay(
                HStack(spacing: 4) {
                    Image(systemName: sortingType.imageName)
                        .resizedToFill(width: 8, height: 8)
                    Text(sortingType.title)
                        .font(kernedFont: .Secondary.p1RegularKerned)
                }
                .foregroundColor(.jet)
            )
        
        return Button {
            selectedSortingType = isSelected ? nil : sortingType
        } label: {
            cellContent
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct SortingContainerView_Previews: PreviewProvider {
    
    static var previews: some View {
        StatefulPreviewWrapper(PriceSortingType.lowToHigh) {
            SortingContainerView(selectedSortingType: $0)
        }
        
    }
}
#endif
