//
//  BrandSelectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.11.2022.
//

import SwiftUI

struct BrandSelectionView: View {
    
    @ObservedObject var viewModel: BrandSelectionViewModel
    let onFinishedInteraction: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading) {
                Text(Strings.Authentication.brandPartners)
                    .font(kernedFont: .Main.h1MediumKerned)
                    .foregroundColor(.brownJet)
                    .padding(.horizontal, 16)
                mainContent
            }
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.continue,
                isEnabled: !viewModel.selectedBrands.isEmpty,
                action: onFinishedInteraction
            )
        }
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            InputField(
                inputText: $viewModel.input,
                scope: Strings.TextFieldScope.brands,
                placeholder: nil,
                trailingView: {
                    ZStack {
                        if viewModel.isSearchingForBrand {
                            ProgressView()
                                .scaleEffect(0.8)
                                .transition(.opacity.animation(.default))
                        } else if viewModel.showMissingBrand {
                            addButton
                        }
                    }
                    .animation(.easeOut, value: viewModel.showMissingBrand)
                    .clipped()
                }, onSubmit: onFinishedInteraction
            )
            .defaultFieldStyle(
                hint: viewModel.showMissingBrand ? Strings.TextFieldHints.brandNotFound : nil,
                focusDelay: 0
            )
            brandsContainerView
        }
        .debounce(publisher: viewModel.$input, viewModel.searchBrand)
    }
    
    private var brandsContainerView: some View {
        ScrollView {
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
    }
    
    private var addButton: some View {
        Button {
            viewModel.addBrand(nil)
        } label: {
            Text(Strings.Buttons.add)
                .font(kernedFont: .Secondary.p1MediumKerned)
                .padding(EdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 12))
                .roundedBorder(Color.midGrey, cornerRadius: 5)
        }
        .buttonStyle(.plain)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .identity))
    }
}

#if DEBUG
struct BrandSelectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        BrandSelectionPreviews()
    }
    
    private struct BrandSelectionPreviews: View {
        
        @StateObject var viewModel = BrandSelectionViewModel(
            authenticationService: MockAuthService(),
            brandService: MockBrandService()
        )
        
        var body: some View {
            BrandSelectionView(viewModel: viewModel, onFinishedInteraction: {})
                .onAppear {
                    Brand.allBrands.forEach { viewModel.addBrand($0)}
                }
        }
    }
}
#endif
