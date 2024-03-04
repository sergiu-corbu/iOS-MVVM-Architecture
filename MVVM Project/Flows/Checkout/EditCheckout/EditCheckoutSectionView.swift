//
//  EditCheckoutSectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 30.12.2023.
//

import SwiftUI

struct EditCheckoutSectionView: View {
    
    @ObservedObject var viewModel: EditCheckoutSectionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationBar(inlineTitle: Strings.Payment.checkout, onDismiss: viewModel.onDismiss)
            CheckoutSectionHeaderView(checkoutSection: viewModel.checkoutSectionType, isEditable: true)
            ScrollView {
                editableContentView
                    .padding(.vertical, 24)
            }
            .scrollDismissesKeyboard(.immediately)
            saveChangesButton
        }
        .background(Color.cultured)
    }

    /// Components
    private var saveChangesButton: some View {
        Buttons.FilledRoundedButton(
            title: Strings.Buttons.saveChanges,
            isEnabled: !viewModel.isLoading, isLoading: viewModel.isLoading,
            action: viewModel.saveChangesAction
        )
    }
    
    @ViewBuilder private var editableContentView: some View {
        switch viewModel.checkoutSectionType {
        case .paymentDetails:
            CreditCartInputView(viewModel: viewModel.editableCreditCartViewModel)
        case .shippingAddress:
            EmptyView()
//            VStack(alignment: .leading, spacing: 32, content: {
//                CustomerInputFieldsView(viewModel: viewModel.editableCustomerInputViewModel)
//                AddressInputView(viewModel: viewModel.editableAddressInputViewModel)
//                if let shippingMethodsViewModel = viewModel.shippingMethodsViewModel {
//                    ShippingMethodsView(viewModel: shippingMethodsViewModel)
//                }
//            })
        case .billingAddress:
            AddressInputView(viewModel: viewModel.editableAddressInputViewModel)
        }
    }
}

#if DEBUG
#Preview {
    EditCheckoutSectionView(viewModel: EditCheckoutSectionViewModel.previewVM(sectionType: .paymentDetails))
}
#Preview {
    EditCheckoutSectionView(viewModel: EditCheckoutSectionViewModel.previewVM(sectionType: .shippingAddress))
}
#Preview {
    EditCheckoutSectionView(viewModel: EditCheckoutSectionViewModel.previewVM(sectionType: .billingAddress))
}
#endif
