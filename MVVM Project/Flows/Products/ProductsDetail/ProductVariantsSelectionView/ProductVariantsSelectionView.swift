//
//  ProductVariantsSelectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.03.2023.
//

import SwiftUI

struct ProductVariantsSelectionView: View {
    
    @ObservedObject var viewModel: ProductVariantsSelectionViewModel
    
    static let sectionID = "variantsSectionID"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(viewModel.availableVariants.indexEnumeratedArray, id: \.offset) { (index, variant) in
                variantSectionView(variant, at: index)
            }
        }
        .padding(.vertical, 8)
        .transition(.opacity.animation(.easeInOut))
        .id(Self.sectionID)
    }
    
    private func variantSectionView(_ variant: ProductVariant, at variantIndex: Int) -> some View {
        let section = viewModel.availableVariantSections[variantIndex]
        let variantSelectionBinding: Binding<UInt?> = {
            return Binding(get: {
                return viewModel.getSelectedVariantValueID(at: variantIndex)
            }, set: { newValue in
                guard let newValue else {
                    return
                }
                viewModel.updateSelectedValues(newValue, at: variantIndex)
            })
        }()

        return VStack(spacing: variant.isPrimary ? 16 : 0) {
            ProductVariantSectionView(
                selectedItemId: variantSelectionBinding,
                section: section,
                layoutStyle: variant.isPrimary ? .rounded : .plain
            )
            if !section.sectionItems.isEmpty {
                DividerView()
            }
        }
        .transition(.opacity)
    }
}

#if DEBUG
#Preview {
    ViewModelPreviewWrapper(ProductDetailsViewModel.mockedProductsDetailVM()) { vm in
        ProductVariantsSelectionView(viewModel: vm.variantsSelectionViewModel
        )
    }
}
#endif
