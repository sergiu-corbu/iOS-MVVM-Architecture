//
//  AddressInputView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 16.12.2023.
//

import SwiftUI

struct AddressInputView: View {
    
    @ObservedObject var viewModel: AddressInputViewModel
    
    //Internal
    @State private var showAddressSearch = false
    @FocusState private var selectedInputField: InputFieldType?
    
    private var saveAddressCheckboxBinding: Binding<Bool> {
        Binding(get: {
            return viewModel.saveAddressCheckbox ?? false
        }, set: { newValue in
            viewModel.saveAddressCheckbox = newValue
        })
    }
    
    var body: some View {
        CheckoutSectionView(
            title: viewModel.addressScope.name,
            trailingActionContext: .init(onSearchLocation: {
                showAddressSearch = true
            }), content: contentView
        )
        .sheet(isPresented: $showAddressSearch) {
            AddressSuggestionView(viewModel: viewModel.addressSuggestionsViewModel)
        }
        .onChange(of: selectedInputField) { newValue in
            if newValue == nil {
                viewModel.updateFieldsCompletionState()
            }
        }
    }
    
    private func contentView() -> some View {
        VStack(spacing: 12) {
            countrySelectionField
            if viewModel.addressScope == .billing {
               billingCustomerFields
            }
            InputField(
                inputText: viewModel.inputFieldBinding(for: .address), scope: nil,
                placeholder: Strings.Placeholders.address,
                submitLabel: .next, onSubmit: {
                    selectedInputField = .postalCode
                })
            .defaultFieldStyle(error: viewModel.inputFieldErrors[.address], contentType: .streetAddressLine1)
            .focused($selectedInputField, equals: .address)
            
            InputField(
                inputText: viewModel.inputFieldBinding(for: .postalCode), scope: nil,
                placeholder: Strings.Placeholders.postalCode,
                submitLabel: .next, onSubmit: {
                    selectedInputField = .city
                }
            )
            .defaultFieldStyle(error: viewModel.inputFieldErrors[.postalCode], contentType: .postalCode)
            .focused($selectedInputField, equals: .postalCode)

            InputField(
                inputText: viewModel.inputFieldBinding(for: .city), scope: nil,
                placeholder: Strings.Placeholders.city,
                submitLabel: .next, onSubmit: {
                    selectedInputField = .state
                }
            )
            .defaultFieldStyle(error: viewModel.inputFieldErrors[.city], contentType: .addressCity)
            .focused($selectedInputField, equals: .city)
            
            InputField(
                inputText: viewModel.inputFieldBinding(for: .state), scope: nil,
                placeholder: Strings.Placeholders.state,
                submitLabel: viewModel.addressScope == .shipping ? .done : .next, onSubmit: {
                    selectedInputField = viewModel.addressScope == .shipping ? nil : .phoneNumber
                }
            )
            .defaultFieldStyle(error: viewModel.inputFieldErrors[.state], contentType: .addressState)
            .focused($selectedInputField, equals: .state)
            
            switch viewModel.addressScope {
            case .shipping:
                if viewModel.showAddressCheckbox {
                    CheckboxSelectableView(isSelected: saveAddressCheckboxBinding, message: Strings.Payment.saveShippingAddress)
                        .padding(.vertical, 4)
                }
            case .billing:
                InputField(
                    inputText: viewModel.inputFieldBinding(for: .phoneNumber), scope: nil,
                    placeholder: Strings.Placeholders.phoneNumber.appending(" (Optional)"),
                    submitLabel: .done, onSubmit: {
                        selectedInputField = nil
                    }
                )
                .defaultFieldStyle(contentType: .telephoneNumber)
                .focused($selectedInputField, equals: .phoneNumber)
            }
        }
    }
    
    //Billing Customer Fields
    @ViewBuilder private var billingCustomerFields: some View {
        HStack(alignment: .top, spacing: -16) {
            InputField(
                inputText: viewModel.inputFieldBinding(for: .firstName), scope: nil,
                placeholder: Strings.Placeholders.firstName,
                submitLabel: .next, onSubmit: {
                    selectedInputField = .lastName
                })
            .defaultFieldStyle(error: viewModel.inputFieldErrors[.firstName], contentType: .givenName)
            .focused($selectedInputField, equals: .firstName)
            InputField(
                inputText: viewModel.inputFieldBinding(for: .lastName), scope: nil,
                placeholder: Strings.Placeholders.lastName,
                submitLabel: .next, onSubmit: {
                    selectedInputField = .address
                })
            .defaultFieldStyle(error: viewModel.inputFieldErrors[.lastName], contentType: .familyName)
            .focused($selectedInputField, equals: .lastName)
        }
    }
    
    //Country selection
    private var countrySelectionField: some View {
        Menu {
            let countryPickerBinding = Binding(get: {
                viewModel.value(for: .country) ?? ""
            }, set: { newValue in
                viewModel.updateField(value: newValue, for: .country)
                viewModel.updateFieldsCompletionState()
            })
            Picker(selection: countryPickerBinding, label: EmptyView()) {
                ForEach(viewModel.countriesList) { country in
                    Text(country.name).tag(country.name)
                }
            }
        } label: {
            let value = viewModel.inputFields[.country] ?? ""
            HStack(spacing: 0) {
                Text(value.isEmpty ? Strings.Placeholders.selectCountry : value)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundStyle(Color.middleGrey)
                Spacer()
                Image(systemName: "chevron.down")
                    .renderingMode(.template)
                    .foregroundColor(.paleSilver)
                    .padding(.trailing, 8)
            }
            .padding(.horizontal, 12)
            .frame(height: 56)
            .background(Color.beige, in: RoundedRectangle(cornerRadius: 5))
            .padding(.horizontal, 16)
        }
    }
}

#if DEBUG
#Preview {
    AddressInputView(viewModel: .shippingVM)
        .previewDisplayName(AddressType.shipping.name)
}
#Preview {
    AddressInputView(viewModel: .billingVM)
        .previewDisplayName(AddressType.billing.name)
}
#endif
