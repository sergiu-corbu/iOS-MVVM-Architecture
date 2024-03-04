//
//  ProductVariantSectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.02.2023.
//

import SwiftUI

struct ProductVariantSectionView: View {
    
    typealias Section = ProductVariantSection
    @Binding var selectedItemId: UInt?
    
    let section: Section
    let layoutStyle: LayoutSectionStyle
    var horizontalSpacing: CGFloat = 16
    
    //MARK: SecondaryLayoutProperties
    @Namespace private var productVariantAnimationNamespace
    
    private var items: [Section.SectionItem] {
        return section.sectionItems
    }
        
    var body: some View {
        if !items.isEmpty {
            mainContent
                .transition(.opacity)
        }
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader
            Group {
                ScrollViewReader { scrollViewProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        switch layoutStyle {
                        case .rounded:
                            primaryVariantsLayout
                        case .plain:
                            secondaryVariantsLayout
                        }
                    }
                    .onChange(of: selectedItemId) { newID in
                        scrollViewProxy.scrollTo(newID, anchor: .center, delay: 0.25)
                    }
                }
            }
            .animation(.easeInOut, value: selectedItemId)
            .animation(.easeInOut, value: section.sectionItems)
        }
    }
    
    private var sectionHeader: some View {
        Text(section.sectionTitle + ":")
            .font(kernedFont: .Main.p1RegularKerned)
            .foregroundColor(.jet)
            .padding(.leading, horizontalSpacing)
    }
    
    private func selectableItemView(_ item: Section.SectionItem) -> some View {
        let isSelected = selectedItemId == item.valueID
        return Button {
            if !isSelected {
                selectedItemId = item.valueID
            }
        } label: {
            ProductVariantCellView(
                variantName: item.value,
                isSelected: isSelected,
                layoutStyle: layoutStyle,
                animationID: layoutStyle == .rounded ? nil : productVariantAnimationNamespace
            )
        }
        .buttonStyle(.plain)
        .id(item.valueID)
    }
}

//MARK: PrimaryVariantLayout
private extension ProductVariantSectionView {
    
    var primaryVariantsLayout: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.valueID) {
                selectableItemView($0)
            }
        }
        .padding(.horizontal, horizontalSpacing)
    }
}

//MARK: SecondaryVariantLayout
private extension ProductVariantSectionView {
    
    var secondaryVariantsLayout: some View {
        HStack(spacing: 22) {
            ForEach(items.sortedByVariantType(), id: \.valueID) {
                selectableItemView($0)
                    .frame(minWidth: 68, alignment: .leading)
            }
        }
        .padding(.horizontal, horizontalSpacing)
    }
}

//MARK: Product Variant Cell
extension ProductVariantSectionView {
    
    enum LayoutSectionStyle {
        case rounded
        case plain
    }
}

private extension ProductVariantSectionView {
    
    struct ProductVariantCellView: View {
        
        let variantName: String
        let isSelected: Bool
        let layoutStyle: LayoutSectionStyle
        var animationID: Namespace.ID?
        
        static let effectID = "productVariantNamespaceID"
        
        private var isRoundedStyle: Bool {
            return layoutStyle == .rounded
        }
        
        var body: some View {
            Text(variantName)
                .font(kernedFont: .Secondary.p2MediumKerned(2))
                .foregroundColor(isSelected ? .darkGreen : .middleGrey)
                .lineLimit(1)
                .padding(
                    EdgeInsets(top: isRoundedStyle ? 12 : 0, leading: isRoundedStyle ? 16 : 0, bottom: isRoundedStyle ? 12 : 16, trailing: isRoundedStyle ? 16 : 0)
                )
                .background(alignment: isRoundedStyle ? .center : .bottom, content: cellBackgroundView)
                .overlay {
                    if isRoundedStyle {
                        Capsule(style: .circular)
                            .strokeBorder(isSelected ? Color.jet : .silver)
                    }
                }
        }
        
        @ViewBuilder
        private func cellBackgroundView() -> some View {
            if isSelected {
                switch layoutStyle {
                case .rounded:
                    Capsule(style: .continuous)
                        .fill(Color.ebony.opacity(0.15))
                case .plain:
                    if let animationID {
                        Rectangle()
                            .fill(Color.jet)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: Self.effectID, in: animationID)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct ProductVariantCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ProductVariantSectionView.ProductVariantCellView(variantName: "RED", isSelected: false, layoutStyle: .rounded)
            ProductVariantSectionView.ProductVariantCellView(variantName: "RED", isSelected: true, layoutStyle: .rounded)
            ProductVariantSectionView.ProductVariantCellView(variantName: "Small", isSelected: false, layoutStyle: .plain)
            ProductVariantSectionView.ProductVariantCellView(variantName: "Small", isSelected: true, layoutStyle: .plain)
            ProductVariantSectionView.ProductVariantCellView(variantName: "ONE SIZE: (15 x 15 x10 CM)", isSelected: false, layoutStyle: .plain)
            ProductVariantSectionView.ProductVariantCellView(variantName: "ONE SIZE: (15 x 15 x10 CM)", isSelected: true, layoutStyle: .plain)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Cell")

        ProductColorSectionPreview()
            .previewDisplayName("Color Container")
        ProductSizeSectionPreview()
            .previewDisplayName("Size Container")
    }

    private struct ProductColorSectionPreview: View {

        @State var selectedVariant: UInt?
        
        var body: some View {
            ProductVariantSectionView(
                selectedItemId: $selectedVariant,
                section: .init(id: .randomID, sectionTitle: "Color", sectionItems: ProductVariant.colorVariant(4).values.map { ProductVariantSection.SectionItem(variantValue: $0) }),                layoutStyle: .rounded
            )
        }
    }

    private struct ProductSizeSectionPreview: View {

        @State var selectedVariant: UInt?

        var body: some View {
            VStack(spacing: 20) {
                ProductVariantSectionView(
                    selectedItemId: $selectedVariant,
                    section: .init(id: .randomID, sectionTitle: "Size", sectionItems: ProductVariant.euSizeVariant(2).values.map { ProductVariantSection.SectionItem(variantValue: $0) }),
                    layoutStyle: .plain
                )
                ProductVariantSectionView(
                    selectedItemId: $selectedVariant,
                    section: .init(id: .randomID, sectionTitle: "Size", sectionItems: ProductVariant.usSizeVariant.values.map { ProductVariantSection.SectionItem(variantValue: $0) }),
                    layoutStyle: .plain
                )
                ProductVariantSectionView(
                    selectedItemId: $selectedVariant,
                    section: .init(id: .randomID, sectionTitle: "Size", sectionItems: ProductVariant.imperialSizeVariant.values.map { ProductVariantSection.SectionItem(variantValue: $0) }),
                    layoutStyle: .plain
                )
            }
        }
    }
}
#endif
