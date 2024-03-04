//
//  ProductView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 02.12.2022.
//

import SwiftUI
import Combine

struct ProductView: View {
   
    let product: Product
    var viewportSize: CGSize?
    var defaultImageHeight: CGFloat = 300
    var coordinateSpace: CoordinateSpace? = .named(PinterestLayoutConfiguration.scrollContentNamespace)
    
    //Internal
    private let spacing: CGFloat = 16
    private var maxImageHeight: CGFloat? {
        return product.imageSize == .zero ? defaultImageHeight : nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let viewportSize, let coordinateSpace {
                productImageView
                    .visibleContentInScrollBounds(
                        viewportSize: viewportSize, coordinateSpace: coordinateSpace,
                        placeholder: {
                            Color.cultured
                                .opacity(0.001)
                                .resizedToFitProductImageView(aspectRatio: product.imageAspectRatio, maxHeight: maxImageHeight)
                        }
                    )
            } else {
                productImageView
            }
            ProductSaleDetailView(productDisplayable: product)
                .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, maxHeight: 80, alignment: .topLeading)
        }
    }
    
    private var productImageView: some View {
        AsyncImageView(imageURL: product.primaryMediaImageURL, placeholderImage: .fashionIcon)
            .resizedToFitProductImageView(aspectRatio: product.imageAspectRatio, maxHeight: maxImageHeight)
            .padding(1)
            .roundedBorder(Color.ebony.opacity(0.15), cornerRadius: 5)
    }
}

extension View {
    
    func resizedToFitProductImageView(
        aspectRatio: CGFloat?,
        maxHeight: CGFloat? = 200,
        cornerRadius: CGFloat = 5
    ) -> some View {
        self
            .aspectRatio(aspectRatio, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: maxHeight)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

enum ProductSelectionStyle {
    case checkmark
    case removeLabel
    
    var borderColor: Color {
        switch self {
        case .checkmark: return .clear
        case .removeLabel: return .brightGold
        }
    }
}

typealias ProductSelection = (productID: String, isSelected: Bool)

struct SelectableProductView: View {
    
    let product: Product
    let selectionStyle: ProductSelectionStyle
    var isAutoSelectable: Bool = true
    let onSelect: (Bool) -> Void
    var selectionPublisher: AnyPublisher<ProductSelection, Never>?
    
    @State private var isSelected: Bool
    
    init(product: Product, isSelected: Bool, selectionStyle: ProductSelectionStyle = .checkmark, isAutoSelectable: Bool = false,
         selectionPublisher: AnyPublisher<ProductSelection, Never>? = nil, onSelect: @escaping (Bool) -> Void) {
        self.product = product
        self.selectionStyle = selectionStyle
        self.isAutoSelectable = isAutoSelectable
        self.onSelect = onSelect
        self.selectionPublisher = selectionPublisher
        self._isSelected = State(wrappedValue: isSelected)
    }
    
    var body: some View {
        Button {
            if isAutoSelectable {
                isSelected.toggle()
            }
            onSelect(isSelected)
        } label: {
            ProductView(product: product)
                .roundedBorder(selectionStyle.borderColor.opacity(isSelected ? 1 : 0))
                .overlay(alignment: .topTrailing) {
                    selectionView
                }
                .animation(.default, value: isSelected)
            }
        .buttonStyle(.scaled)
        .onReceive(selectionPublisher.unwrapped, perform: { selection in
            guard selection.productID == product.id else {
                return
            }
            self.isSelected = selection.isSelected
        })
    }
    
    
    @ViewBuilder private var selectionView: some View {
        switch selectionStyle {
        case .checkmark:
            SquareStyledCheckmarkView(isSelected: isSelected)
                .padding([.top, .trailing], 16)
        case .removeLabel:
            if isSelected {
                Buttons.RemoveLabel()
                    .padding([.top, .trailing], 8)
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        HStack {
            SelectableProductView(product: Product.prod1, isSelected: false) { _ in }
            ProductView(product: Product.prod2)
        }
        HStack {
            SelectableProductView(product: Product.prod1, isSelected: false) { _ in }
            SelectableProductView(product: Product.prod1, isSelected: false, selectionStyle: .removeLabel) { _ in }
        }
    }
    .padding()
}
#endif
