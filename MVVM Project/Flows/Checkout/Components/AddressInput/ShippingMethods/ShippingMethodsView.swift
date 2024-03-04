//
//  ShippingMethodsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.12.2023.
//

import SwiftUI

struct ShippingMethodsView: View {
    
    @ObservedObject var viewModel: ShippingMethodsViewModel
    
    var body: some View {
        CheckoutSectionView(title: Strings.Payment.shippingMethod) {
            if viewModel.shippingMethods.isEmpty {
               shippingMethodPlaceholderView
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.shippingMethods, id: \.shippingMethodId) { shippingMethod in
                        CheckoutSelectableCellView(
                            isSelected: Binding(get: {
                                viewModel.selectedShippingMethod == shippingMethod
                            }, set: { _ in
                                viewModel.selectShippingMethod(shippingMethod)
                            })
                        ) {
                            ShippingMethodCellView(shippingMethod: shippingMethod)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .animation(.smooth, value: viewModel.shippingMethods)
    }
    
    private var shippingMethodPlaceholderView: some View {
        Text(Strings.Payment.shippingMethodPlaceholder)
            .font(kernedFont: .Secondary.p2RegularKerned)
            .foregroundStyle(Color.ebony)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .roundedBorder(Color.paleSilver, cornerRadius: 4)
            .padding(.horizontal, 16)
    }
}

struct ShippingMethodCellView: View {
    
    let shippingMethod: ShippingMethod
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(shippingMethod.label)
                    .font(kernedFont: .Secondary.p2RegularKerned)
                    .foregroundStyle(Color.jet)
                Text(shippingMethod.carrier)
                    .font(kernedFont: .Secondary.p2RegularKerned)
                    .foregroundStyle(Color.middleGrey)
            }
            Spacer()
            Text(shippingMethod.price.currencyFormatted(isValueInCents: true) ?? "")
                .font(kernedFont: .Secondary.p1BoldKerned)
                .foregroundStyle(Color.jet)
        }
    }
}

struct ShippingInformationView: View {
    
    @Binding var isShippingDetailPresented: Bool
    var onOpenEmail: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 0) {
            CheckoutLabeledSectionContainer(image: .deliveryIcon, title: Strings.Orders.shipping, content: {EmptyView()})
            Spacer()
            Button {
                isShippingDetailPresented = true
            } label: {
                Text(Strings.Buttons.howShippingWorks.uppercased())
                    .font(kernedFont: .Secondary.p3BoldExtraKerned)
                    .foregroundColor(.brightGold)
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $isShippingDetailPresented) {
            ShippingDetailView(onOpenEmail: {
                isShippingDetailPresented = false
                DispatchQueue.main.asyncAfter(seconds: 0.1) {
                    onOpenEmail?()
                }
            })
            .presentationDetents([.fraction(0.8)])
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 24) {
        ViewModelPreviewWrapper(ShippingMethodsViewModel.previewViewModel) { vm in
            ShippingMethodsView(viewModel: vm)
        }
        ShippingMethodsView(viewModel: .init(shippingMethods: []))
    }
}
#endif
