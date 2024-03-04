//
//  GiftingRequestView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.07.2023.
//

import SwiftUI

struct GiftingRequestView: View {
    
    @ObservedObject var viewModel: GiftingRequestViewModel
    @State private var progressStates = ProgressState.createStaticStates(currentIndex: 3)
    @FocusState private var selectedInputField: InputFieldType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            navigationView
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    sectionView(title: Strings.ContentCreation.deliveryAddress, content: deliverySectionView)
                    sectionView(title: Strings.ContentCreation.phoneNumber, content: phoneNumberSectionView)
                    FeaturedProductsCollectionView(viewModel.products, title: Strings.ContentCreation.requestedProducts)
                }
                .padding(.top, 24)
                .onChange(of: selectedInputField) { [selectedInputField] _ in
                    viewModel.updateInputFieldState(previousField: selectedInputField)
                }
                publishButton
            }
        }
        .primaryBackground()
        .errorToast(error: $viewModel.error)
    }
    
    private var deliverySectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            InputField(
                inputText: $viewModel.country,
                scope: Strings.TextFieldScope.country,
                placeholder: Strings.Placeholders.country,
                submitLabel: .next, trailingView: { inputFieldTrailingView(type: .country) },
                onSubmit:  {
                    selectedInputField = .city
                }
            )
            .defaultFieldStyle(error: viewModel.inputFieldsErrors[.country])
            .focused($selectedInputField, equals: .country)
            InputField(
                inputText: $viewModel.city,
                scope: Strings.TextFieldScope.city,
                placeholder: Strings.Placeholders.city,
                submitLabel: .next, trailingView: { inputFieldTrailingView(type: .city) },
                onSubmit:  {
                    selectedInputField = .address
                }
            )
            .defaultFieldStyle(error: viewModel.inputFieldsErrors[.city])
            .focused($selectedInputField, equals: .city)
            InputField(
                inputText: $viewModel.address,
                scope: Strings.TextFieldScope.address,
                placeholder: Strings.Placeholders.address,
                submitLabel: .next, trailingView: { inputFieldTrailingView(type: .address) },
                onSubmit:  {
                    selectedInputField = .state
                }
            )
            .defaultFieldStyle(error: viewModel.inputFieldsErrors[.address])
            .focused($selectedInputField, equals: .address)
            InputField(
                inputText: $viewModel.state,
                scope: Strings.TextFieldScope.state,
                placeholder: Strings.Placeholders.state,
                submitLabel: .next, trailingView: { inputFieldTrailingView(type: .state) },
                onSubmit:  {
                    selectedInputField = .postalCode
                }
            )
            .defaultFieldStyle(error: nil)
            .focused($selectedInputField, equals: .state)
            InputField(
                inputText: $viewModel.postalCode,
                scope: Strings.TextFieldScope.postalCode,
                placeholder: Strings.Placeholders.postalCode,
                submitLabel: .next, trailingView: { inputFieldTrailingView(type: .postalCode) },
                onSubmit:  {
                    selectedInputField = .phoneNumber
                }
            )
            .defaultFieldStyle(error: viewModel.inputFieldsErrors[.postalCode])
            .focused($selectedInputField, equals: .postalCode)
            personalDataPrivacyView
        }
    }
    
    private var phoneNumberSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            InputField(
                inputText: $viewModel.phoneNumber,
                scope: Strings.TextFieldScope.phoneNumber,
                placeholder: Strings.Placeholders.phoneNumber,
                trailingView: {
                    inputFieldTrailingView(type: .phoneNumber)
                }, onSubmit:  {}
            )
            .defaultFieldStyle(error: viewModel.inputFieldsErrors[.phoneNumber], keyboardType: .phonePad, contentType: .telephoneNumber)
            .focused($selectedInputField, equals: .phoneNumber)
            personalDataPrivacyView
        }
    }
    
    private var personalDataPrivacyView: some View {
        Text(Strings.TermsAndConditions.personalDataPrivacyMessage)
            .font(kernedFont: .Secondary.p2RegularKerned)
            .foregroundColor(.ebony)
            .padding(.horizontal, 16)
    }
    
    private func sectionView(title: String, content: some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(kernedFont: .Main.p1MediumKerned)
                .foregroundColor(.jet)
                .padding(.horizontal, 16)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder private func inputFieldTrailingView(type: InputFieldType) -> some View {
        if !viewModel.inputFieldValue(type: type).isEmpty {
            Image(.successIcon)
        }
    }
}

//MARK: NavigationView
private extension GiftingRequestView {
    
    var navigationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationBar(
                inlineTitle: Strings.NavigationTitles.giftingRequest,
                onDismiss: { viewModel.giftingRequestActionHandler(.back) },
                trailingView: {
                    Buttons.QuickActionButton(action: { viewModel.giftingRequestActionHandler(.cancel) })
                }
            )
            StepProgressView(currentIndex: 3, progressStates: progressStates)
                .onChange(of: viewModel.allFieldsCompleted) { newValue in
                    progressStates[3] = newValue ? .progress(1) : .idle
                }
        }
    }
    
    var publishButton: some View {
        Buttons.FilledRoundedButton(
            title: Strings.Buttons.submitRequest,
            isEnabled: viewModel.allFieldsCompleted,
            isLoading: viewModel.isLoading,
            action: viewModel.submitGiftingRequest
        )
    }
}

#if DEBUG
struct GiftingRequestView_Previews: PreviewProvider {
    static var previews: some View {
        GiftingRequestPreview()
    }
    
    private struct GiftingRequestPreview: View {
        
        @StateObject var viewModel = GiftingRequestViewModel(
            products: [.sampleProduct], productsSkuIDs: [], userRepository: MockUserRepository(),
            contentCreationService: MockContentCreationService(),
            giftingRequestActionHandler: {_ in}
        )
        
        var body: some View {
            GiftingRequestView(viewModel: viewModel)
        }
    }
}
#endif
