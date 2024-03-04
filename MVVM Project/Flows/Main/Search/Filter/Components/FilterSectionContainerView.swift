//
//  FilterSectionContainerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 24.08.2023.
//

import SwiftUI

enum FilterSectionType: String, CaseIterable, Identifiable {
    case brands
    case categories
    case sizes
    
    var id: String {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .brands: return Strings.FilterAndSort.brands
        case .categories: return Strings.FilterAndSort.categories
        case .sizes: return Strings.FilterAndSort.sizes
        }
    }
}

struct FilterSectionContainerView: View {
    
    let filterFacet: FilterFacet
    @Binding var selectedFilterSection: FilterSectionType?
    @Binding var selectedItems: Set<FilterFacet.FacetValue>
    var isLoading = false
    
    //computed
    var isSelected: Bool {
        return filterFacet.filterType == selectedFilterSection
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(filterFacet.filterType.title.uppercased())
                .font(kernedFont: .Main.p1RegularKerned)
                .foregroundColor(.jet)
                .overlay(alignment: .trailing) {
                    loadingIndicatorView
                }
            PassthroughView {
                if isSelected {
                    selectionContentView
                } else {
                   collapsedDetailView
                }
            }
            .animation(.easeOut(duration: 0.45).delay(-0.1), value: isSelected)
            .animation(.default, value: isLoading)
            DividerView()
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            selectionIndicatorView
                .padding(.trailing, 16)
        }
    }
    
    @ViewBuilder private var loadingIndicatorView: some View {
        if isLoading, isSelected {
            ProgressView()
                .tint(.darkGreen)
                .scaleEffect(0.8)
                .offset(x: 24)
        }
    }
    
    private var selectionContentView: some View {
        let scaleTransition = AnyTransition.asymmetric(insertion: .scale(scale: 0.5), removal: .scale(scale: 0.5).combined(with: .opacity))
        return AdaptiveFlowLayoutView(
            data: filterFacet.values,
            interitemSpacing: 8, lineSpacing: 8,
            layoutCellView: itemCellView(_:)
        )
        .padding(.horizontal, 16)
        .transition(scaleTransition)
    }
    
    private func itemCellView(_ item: FilterFacet.FacetValue) -> some View {
        let isSelected = selectedItems.contains(item)
        return Button {
            selectedItems.updateOrRemove(item)
        } label: {
            Text(item.label + (item.count > 0 ? " (\(item.count))" : ""))
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.jet)
                .lineLimit(1)
                .padding(12)
                .background(isSelected ? Color.beige : .clear)
                .clipShape(Capsule(style: .continuous))
                .roundedBorder(Color.ebony.opacity(0.15), cornerRadius: 35)
        }
        .buttonStyle(.plain)
    }
    
    private var collapsedDetailView: some View {
        let selectionStatus: String
        switch selectedItems.count {
        case .zero:
            selectionStatus = filterFacet.values.isEmpty ? "-" : Strings.FilterAndSort.all
        case filterFacet.values.count:
            selectionStatus = Strings.FilterAndSort.all
        default:
            selectionStatus = selectedItems.map(\.label).joined(separator: ", ")
        }
        
        return Text(selectionStatus.uppercased())
            .font(kernedFont: .Secondary.p4BoldKerned)
            .multilineTextAlignment(.center)
            .foregroundColor(.middleGrey)
            .padding(.horizontal, 16)
            .transition(.asymmetric(insertion: .identity, removal: .opacity))
    }
    
    private var selectionIndicatorView: some View {
        Button {
            selectedFilterSection = isSelected ? nil : filterFacet.filterType
        } label: {
            Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                .foregroundColor(.middleGrey)
                .frame(width: 16, height: 16)
        }
        .buttonStyle(.plain)
        .offset(y: 12)
        .disabled(filterFacet.values.isEmpty)
    }
}

#if DEBUG
struct FilterSectionContainerView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
//            ForEach(FilterFacet.mockedFacets, id: \.filterType.rawValue) { facet in
                FilterSectionContainerPreview()//filterFacet: facet)
//            }
        }
    }
    
    struct FilterSectionContainerPreview: View {
        
        static let categories = ["Apparel & Accessories (93)", "Jewlery (37)", "Handbags (27)", "Handbags, Wallets & Cases (27)", "Bracelets (24)", "Clothing (14)", "Belts (13)", "Clothing Accessories (13)", "Shirt & Tops (6)", "Necklaces (5)"
        ]
        
        let filterFacet: FilterFacet = FilterFacet(
            filterType: .brands,
            values: Self.categories.map { FilterFacet.FacetValue(label: $0, value: $0, count: 0) }

        )
        @State private var selectedFilter: FilterSectionType? = .brands
        @State private var selectedItems = Set<FilterFacet.FacetValue>()
        
        var body: some View {
            FilterSectionContainerView(filterFacet: filterFacet, selectedFilterSection: $selectedFilter, selectedItems: $selectedItems)
                .previewDisplayName(filterFacet.filterType.title)
        }
    }
}
#endif
