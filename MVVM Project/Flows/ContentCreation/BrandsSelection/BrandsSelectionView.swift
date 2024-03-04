//
//  BrandsSelectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.11.2022.
//

import SwiftUI

struct BrandsSelectionView: View {
    
    @ObservedObject var viewModel: BrandsSelectionViewModel
    let headerTitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            NavigationBar(
                inlineTitle: Strings.NavigationTitles.yourCollaborations,
                onDismiss: { viewModel.brandSelectionActionHandler(.back(viewModel.selectedBrandIDs)) },
                trailingView: {
                    Buttons.QuickActionButton(action: { viewModel.brandSelectionActionHandler(.cancel) })
                }
            )
            StepProgressView(currentIndex: 1, progressStates: viewModel.progressStates)
            mainContent
        }
        .primaryBackground()
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(headerTitle)
                .font(kernedFont: .Main.h1MediumKerned)
                .foregroundColor(.jet)
                .padding(.horizontal, 16)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(Strings.ContentCreation.collaborations.uppercased())
                        .font(kernedFont: .Main.p1MediumKerned)
                        .foregroundColor(.jet)
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    BrandCollaborationsView(brands: viewModel.brands, selectedBrandIDs: viewModel.selectedBrandIDs, selectionHandler: {
                        viewModel.updateBrandsSelection($0)
                    })
                }
                .padding(.top, 40)
            }
            
            if !viewModel.selectedBrandIDs.isEmpty {
                Buttons.FilledRoundedButton(title: Strings.Buttons.continue, action: viewModel.handleMainAction)
                .transition(.moveBottomAndFade)
            }
        }
        .animation(.easeInOut, value: viewModel.selectedBrandIDs)
    }
}

#if DEBUG
struct BrandsSelectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        BrandsSelectionPreview()
        BrandsSelectionPreview(multipleSelectionEnabled: false)
            .previewDisplayName("Gift Requesting")
    }
    
    private struct BrandsSelectionPreview: View {
                
        init(multipleSelectionEnabled: Bool = true) {
            self.multipleSelection = multipleSelectionEnabled
            self._viewModel = StateObject(wrappedValue: BrandsSelectionViewModel(multipleSelectionEnabled: multipleSelectionEnabled, userProvider: MockUserProvider(), brandSelectionActionHandler: { _ in}))
        }
        
        @StateObject var viewModel: BrandsSelectionViewModel
        let multipleSelection: Bool
        
        var body: some View {
            BrandsSelectionView(viewModel: viewModel, headerTitle: multipleSelection ? Strings.ContentCreation.brandSelection : Strings.ContentCreation.brandForGiftRequestMessage)
        }
    }
}
#endif
