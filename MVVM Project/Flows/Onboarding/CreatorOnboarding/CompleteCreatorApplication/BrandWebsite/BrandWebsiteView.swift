//
//  BrandWebsiteView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.11.2022.
//

import SwiftUI

struct BrandWebsiteView: View {
    
    @ObservedObject var viewModel: BrandWebsiteViewModel
    let onFinishedInteraction: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ScrollView(showsIndicators: false) {
                brandWebisteInputView
            }
            actionButton
        }
    }
    
    private var brandWebisteInputView: some View {
        VStack(alignment: .leading, spacing: 48) {
            Text(Strings.Authentication.brandWebsite)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundColor(.brownJet)
                .padding(.horizontal, 16)
            VStack(alignment: .leading, spacing: 24) {
                InputField(
                    inputText: $viewModel.brandWebsite,
                    scope: Strings.TextFieldScope.website,
                    placeholder: Strings.Placeholders.website,
                    submitLabel: .next,
                    onSubmit: validateWebsite
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
    
    @ViewBuilder
    private var actionButton: some View {
        if viewModel.brandWebsite.isEmpty {
            Buttons.FillBorderedButton(
                title: Strings.Buttons.noWebsite,
                action: onFinishedInteraction
            )
            .padding([.horizontal, .bottom], 16)
        } else {
            Buttons.FilledRoundedButton(
                title: Strings.Buttons.continue,
                isEnabled: !viewModel.brandWebsite.isEmpty,
                action: validateWebsite
            )
        }
    }

    private var promoteMyBrandToggle: some View {
        HStack(spacing: 0) {
            Text(Strings.Authentication.allowToPromoteMyBrand)
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
    
    private func validateWebsite() {
        viewModel.validateBrandWebsite()
        if viewModel.brandWebsiteError == nil {
            onFinishedInteraction()
        }
    }
}

#if DEBUG
struct BrandWebsiteView_Previews: PreviewProvider {
    
    static var previews: some View {
        BrandWebsiteView(viewModel: BrandWebsiteViewModel(), onFinishedInteraction: {})
    }
}
#endif
