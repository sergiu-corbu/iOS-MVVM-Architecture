//
//  SearchBarView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.07.2023.
//

import SwiftUI
import Combine

struct SearchBarView: View {
    
    @ObservedObject var viewModel: SearchBarViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            InputField(
                inputText: $viewModel.text, scope: nil,
                placeholder: Strings.Placeholders.discoverAnything,
                tint: .brownJet, submitLabel: .search,
                onSubmit: {
                    isFocused = false
                }, leadingView: {
                    SearchIconView()
                }, trailingView: {
                    if !viewModel.text.isEmpty {
                        Buttons.ClearButton(onClear: viewModel.clearButtonAction)
                    }
                }
            )
            .defaultFieldStyle()
            .focused($isFocused)
            if isFocused {
                cancelButton
            }
        }
        .onChange(of: isFocused) { newValue in
            viewModel.isInputFieldActivePublisher.send(newValue)
        }
    }
    
    var cancelButton: some View {
        Button {
            viewModel.cancelAction()
        } label: {
            Text(Strings.Buttons.cancel)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.brownJet)
                .padding(.trailing, 14)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
    }
}

struct SearchIconView: View {
    
    var body: some View {
        Image(.searchIcon)
            .renderingMode(.template)
            .foregroundColor(.middleGrey)
            .frame(width: 24, height: 24)
    }
}

#if DEBUG
struct SearchBarView_Previews: PreviewProvider {
    
    static var disposeBag = [AnyCancellable]()

    static var previews: some View {
        ViewModelPreviewWrapper(SearchBarViewModel()) { viewModel -> SearchBarView in
            viewModel.onClear.sink {
                viewModel.cancelButtonVisible = true
            }.store(in: &disposeBag)
            
            viewModel.onCancel.sink {
                viewModel.cancelButtonVisible = false
            }.store(in: &disposeBag)
            return SearchBarView(viewModel: viewModel)
        }
    }
}
#endif
