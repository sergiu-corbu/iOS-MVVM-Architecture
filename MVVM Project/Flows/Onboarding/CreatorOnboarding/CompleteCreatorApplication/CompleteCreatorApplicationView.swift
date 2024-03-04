//
//  CompleteCreatorApplicationView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.11.2022.
//

import SwiftUI

struct CompleteCreatorApplicationView: View {
    
    @ObservedObject var viewModel: CompleteCreatorApplicationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            mainContent
        }
        .primaryBackground()
        .errorToast(error: $viewModel.backendError)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationBar(
                inlineTitle: Strings.NavigationTitles.completeCreatorProfile,
                onDismiss: viewModel.handleBackAction,
                trailingView: {
                    Buttons.CancelButton(onCancel: viewModel.onCancel.send)
                }
            ).backButtonHidden(viewModel.profileProgress == .brandOwnership)
            CustomProgressBar(percentage: viewModel.progress)
        }
        .background(Color.cultured)
    }
    
    private var mainContent: some View {
        Group {
            switch viewModel.profileProgress {
            case .brandOwnership:
                brandOwnershipView
            case .brandWebsite:
                brandWebsiteView
            case .brandPartnerships:
                brandPartnershipsView
            case .brandPartners:
                brandSelectionView
            case .receivedProducts:
                receivedBrandProductsView
            }
        }
        .transition(.transparentMoveScale())
        .animation(.linear(duration: 0.7), value: viewModel.profileProgress)
    }
}

private extension CompleteCreatorApplicationView {
    
    var brandOwnershipView: some View {
        ContainerOptionsView(title: Strings.Authentication.brandOwnership) {
            viewModel.handleBrandOwnership($0)
        }
    }
    
    var brandPartnershipsView: some View {
        ContainerOptionsView(
            title: Strings.Authentication.brandPartnerships,
            action: viewModel.handleBrandPartnership(_:)
        )
    }
    
    private var brandWebsiteView: some View {
        if viewModel.brandWebsiteViewModel == nil {
            viewModel.brandWebsiteViewModel = BrandWebsiteViewModel()
        }
        return BrandWebsiteView(
            viewModel: viewModel.brandWebsiteViewModel!,
            onFinishedInteraction: viewModel.showBrandPartnerships
        )
    }
    
    private var brandSelectionView: some View {
        if viewModel.brandSelectionViewModel == nil {
            viewModel.brandSelectionViewModel = BrandSelectionViewModel(
                authenticationService: viewModel.authenticationService,
                brandService: viewModel.brandService
            )
        }
        return BrandSelectionView(viewModel: viewModel.brandSelectionViewModel!, onFinishedInteraction: viewModel.handleBrandsSelection)
    }
    
    var receivedBrandProductsView: some View {
        ContainerOptionsView(
            title: Strings.Authentication.receivedBrandProducts,
            action: viewModel.handleBrandPartnerships(_:)
        )
    }
}

#if DEBUG
struct CompleteCreatorApplicationView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteCreatorApplicationView(viewModel: .init(
            authenticationService: MockAuthService(),
            brandService: MockBrandService())
        )
    }
}
#endif
