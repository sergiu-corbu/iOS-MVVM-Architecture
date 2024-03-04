//
//  AddressSuggestionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.12.2023.
//

import SwiftUI
import MapKit

struct AddressSuggestionView: View {
    
    @ObservedObject var viewModel: AddressSuggestionViewModel
    
    //Internal
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismissHandler
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            navigationBar
            searchBarView
            ScrollView { 
                searchResultsView
            }
            .overlayLoadingIndicator(viewModel.isLoading, shouldDisableInteraction: true)
        }
        .background(Color.cultured)
        .errorToast(error: $viewModel.error)
        .task {
            await Task.sleep(seconds: 0.5)
            isFocused = true
        }
        .onReceive(viewModel.onAddressSelected) { _ in
            dismissHandler()
        }
    }
    
    private var navigationBar: some View {
        VStack(spacing: 12) {
            NavigationBar(
                inlineTitle: Strings.NavigationTitles.addShippingAddress, onDismiss: {}, trailingView: {
                    Button(action: {
                        dismissHandler()
                    }, label: {
                        Image(.closeIcSmall)
                    }).buttonStyle(.plain)
                }
            ).backButtonHidden(true)
            DividerView()
        }
    }
    
    private var searchBarView: some View {
        InputField(
            inputText: $viewModel.searchQuery, scope: nil,
            placeholder: Strings.Placeholders.searchPlace,
            tint: .brownJet, submitLabel: .search,
            onSubmit: {
                isFocused = false
            }, leadingView: {
                SearchIconView()
            }, trailingView: {
                if !viewModel.searchQuery.isEmpty {
                    Buttons.ClearButton(onClear: viewModel.clearQueryAndSuggestions)
                }
            }
        )
        .defaultFieldStyle()
        .padding(.bottom, 4)
        .focused($isFocused)
    }
    
    private var searchResultsView: some View {
        LazyVStack(alignment: .leading, spacing: 12, content: {
            ForEach(viewModel.locationResults, id: \.self) { locationResult in
                Button(action: {
                    viewModel.handleLocationSuggestionSelected(locationResult)
                }, label: {
                    SearchResultCellView(locationResult: locationResult)
                }).buttonStyle(.plain)
            }
        })
    }
    
    struct SearchResultCellView: View {
        
        let locationResult: MKLocalSearchCompletion
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(locationResult.title)
                        .font(kernedFont: .Main.p1MediumKerned)
                        .foregroundStyle(Color.jet)
                    Text(locationResult.subtitle)
                        .font(kernedFont: .Secondary.p3MediumKerned)
                        .foregroundStyle(Color.middleGrey)
                }
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 16)
                DividerView()
            }
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    AddressSuggestionView(viewModel: .init(onFinishedSearch: { _ in }))
}
