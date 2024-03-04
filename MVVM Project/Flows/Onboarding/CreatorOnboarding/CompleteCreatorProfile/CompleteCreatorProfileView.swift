//
//  CompleteCreatorProfileView.swift
//  Bond
//
//  Created by Sergiu Corbu on 17.11.2022.
//

import SwiftUI

struct CompleteCreatorProfileView: View {
    
    @ObservedObject var viewModel: CompleteCreatorProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            mainContent
        }
        .primaryBackground()
        .errorToast(error: $viewModel.backendError)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationBar(
                inlineTitle: LocalizedStrings.NavigationTitles.completeCreatorProfile,
                onBack: viewModel.handleBackAction,
                trailingView: cancelButton
            ).backButtonHidden(viewModel.profileProgress == .brandOwnership)
            CustomProgressBar(percentage: viewModel.progress)
        }
        .background(Color.cultured)
    }
    
    @ViewBuilder
    private var mainContent: some View {
        Group {
            switch viewModel.profileProgress {
            case .brandOwnership:
                brandOwnershipView
            case .brandWebsite:
                brandWebisteView
            case .brandAmbassador:
                brandAmbassadorView
            case .brandSelection:
                brandsSelectionView
            case .brandPartnerships:
                brandPartnershipsView
            }
        }
        .transition(.transparentMoveScale())
        .animation(.linear(duration: 0.7), value: viewModel.profileProgress)
    }
    
    private func cancelButton() -> some View {
        Button {
            viewModel.onCancel.send()
        } label: {
            Text(LocalizedStrings.Buttons.cancel)
                .font(kernedFont: .Secondary.p1BoldKerned)
                .foregroundColor(.orangish)
        }
        .buttonStyle(.plain)
    }
}

private extension CompleteCreatorProfileView {
    
    var brandOwnershipView: some View {
        ContainerOptionsView(title: LocalizedStrings.Authentication.brandOwnership) {
            viewModel.handleBrandOwnership($0)
        }
    }
    
    //TODO: refactor into a separate view
    var brandWebisteView: some View {
        VStack(spacing: 8) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 48) {
                    Text(LocalizedStrings.Authentication.brandWebsite)
                        .font(kernedFont: .Main.h1MediumKerned)
                        .foregroundColor(.brownJet)
                        .padding(.horizontal, 16)
                    VStack(alignment: .leading, spacing: 24) {
                        InputField(
                            inputText: $viewModel.brandWebsite,
                            scope: LocalizedStrings.TextFieldScope.website,
                            placeholder: LocalizedStrings.Placeholders.website,
                            submitLabel: .next,
                            onSubmit: viewModel.validateBrandWebsite
                        )
                        .defaultFieldStyle(
                            error: viewModel.brandWebsiteError,
                            hint: nil,
                            keyboardType: .URL,
                            focusDelay: 0.5
                        )
                        .textInputAutocapitalization(.never)
                        promoteMyBrandToggle
                    }
                }
            }
            if viewModel.brandWebsite.isEmpty {
                Buttons.FillBorderedButton(
                    title: LocalizedStrings.Buttons.noWebsite,
                    action: viewModel.showBrandAmbassador
                )
            } else {
                Buttons.FilledRoundedButton(
                    title: LocalizedStrings.Buttons.continue,
                    isEnabled: !viewModel.brandWebsite.isEmpty,
                    action: viewModel.validateBrandWebsite
                )
            }
        }
    }
    
    var promoteMyBrandToggle: some View {
        HStack(spacing: 0) {
            Text(LocalizedStrings.Authentication.allowToPromoteMyBrand)
                .font(.Secondary.p1Regular)
                .foregroundColor(.ebony)
                .minimumScaleFactor(0.8)
            Spacer()
            Toggle("", isOn: $viewModel.brandCanBePromoted)
                .tint(.brightGold)
                .frame(width: 50)
        }
        .padding(.horizontal, 16)
        .opacity(viewModel.brandWebsite.isEmpty ? 0 : 1)
        .animation(.easeInOut, value: viewModel.brandWebsite.isEmpty)
    }
    
    var brandAmbassadorView: some View {
        ContainerOptionsView(
            title: LocalizedStrings.Authentication.brandAmbassador,
            action: viewModel.handleBrandAmbassador(_:)
        )
    }
    
    var brandPartnershipsView: some View {
        ContainerOptionsView(
            title: LocalizedStrings.Authentication.brandPartnership,
            action: viewModel.handleBrandPartnerships(_:)
        )
    }
    
    //TODO: refactor into a separate view
    var brandsSelectionView: some View {
        VStack(spacing: 8) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text(LocalizedStrings.Authentication.ambassadorBrands)
                        .font(kernedFont: .Main.h1MediumKerned)
                        .foregroundColor(.brownJet)
                        .padding(.horizontal, 16)
                    VStack(alignment: .leading, spacing: 8) {
                        InputField(
                            inputText: $viewModel.searchedBrand,
                            scope: LocalizedStrings.TextFieldScope.brands,
                            placeholder: nil,
                            trailingView: {
                                if viewModel.isSearchingForBrand {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .transition(.opacity.animation(.default))
                                } else if viewModel.showUnfoundBrandHint {
                                    addButton
                                }
                            }, onSubmit: viewModel.handleBrandsSelection
                        )
                        .defaultFieldStyle(
                            hint: viewModel.showUnfoundBrandHint ? LocalizedStrings.TextFieldHints.brandNotFound : nil,
                            focusDelay: 0
                        )
                        if viewModel.showSelectedBrands {
                            BrandsTagContainerView(brands: Array(viewModel.selectedBrands), tagType: .selection) { brand in
                                viewModel.removeBrand(brand)
                            }
                            .transition(.opacity.animation(.easeInOut))
                        } else if !viewModel.suggestedBrands.isEmpty {
                            BrandsTagContainerView(brands: viewModel.suggestedBrands, tagType: .suggestion) { brand in
                                
                                viewModel.addBrand(brand)
                            }
                            .transition(.opacity.animation(.easeInOut))
                        }
                    }
                    .frame(maxHeight: 200, alignment: .top)
                    .frame(maxHeight: .infinity)
                }
                .debounce(publisher: viewModel.$searchedBrand, viewModel.searchBrand)
                
            }
            Buttons.FilledRoundedButton(
                title: LocalizedStrings.Buttons.continue,
                isEnabled: !viewModel.selectedBrands.isEmpty,
                action: viewModel.handleBrandsSelection
            )
        }
    }
    
    private var addButton: some View {
        Button {
            viewModel.addBrand(nil)
        } label: {
            Text(LocalizedStrings.Buttons.add)
                .font(kernedFont: .Secondary.p1MediumKerned)
                .padding(EdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 12))
                .roundedBorder(Color.midGrey, cornerRadius: 5)
        }
        .buttonStyle(.plain)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .identity))
        .animation(.easeInOut(duration: 0.2))
        .clipped()
        .zIndex(2)
    }
}

#if DEBUG
struct CompleteCreatorProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteCreatorProfileView(viewModel: .init(authenticationService: MockAuthService()))
    }
}
#endif
