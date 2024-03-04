//
//  ApplyAsCreatorView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.01.2023.
//

import SwiftUI
import Combine

struct ApplyAsCreatorView: View {

    let currentUserSubject: CurrentValueSubject<User?, Never>
    let onApply: () -> Void
    let onDismiss: () -> Void
    
    @StateObject private var viewModel: ViewModel
    
    init(currentUserSubject: CurrentValueSubject<User?, Never>, onApply: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.currentUserSubject = currentUserSubject
        self.onApply = onApply
        self.onDismiss = onDismiss
        self._viewModel = StateObject(wrappedValue: ViewModel(currentUserSubject: currentUserSubject))
    }
    
    var body: some View {
        PassthroughView {
            if viewModel.showContent {
                content
                    .transition(.opacity)
            }
        }
        .animation(.smooth, value: viewModel.didShowApplyToGoLive)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.Discover.applyAsCreatorTitle.capitalized)
                .font(kernedFont: .Main.h1BoldKerned)
                .foregroundColor(.darkGreen)
                .multilineTextAlignment(.leading)
            Button {
                onApply()
            } label: {
                Text(Strings.Buttons.apply.uppercased())
                    .font(kernedFont: .Secondary.p2MediumKerned(1))
                    .foregroundColor(.brightGold)
            }.buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing, content: closeButtonView)
        .padding(16)
        .background(Color.beige)
        .border(Color.midGrey, cornerRadius: 8)
        .padding(.horizontal, 16)
    }
    
    private func closeButtonView() -> some View {
        Button(action: {
            viewModel.hideContent()
            onDismiss()
        }, label: {
            Image(.closeIcSmall)
        })
        .buttonStyle(.plain)
    }
}

private extension ApplyAsCreatorView {
    
    class ViewModel: ObservableObject {
        
        @UserDefault(key: "didShowApplyToGoLive", defaultValue: false)
        private(set) var didShowApplyToGoLive: Bool
        
        private var cancellable: AnyCancellable?
        
        var showContent: Bool {
            return !didShowApplyToGoLive
        }
        
        init(currentUserSubject: CurrentValueSubject<User?, Never>) {
            self.cancellable = currentUserSubject
                .receive(on: DispatchQueue.main)
                .sink { [weak self] user in
                    if self?.didShowApplyToGoLive == true {
                        return
                    }
                    if user?.appliedAsCreator == true || user?.role == .creator {
                        self?.hideContent()
                    }
                }
        }
        
        func hideContent() {
            didShowApplyToGoLive = true
            objectWillChange.send()
        }
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.cappuccino
        ApplyAsCreatorView(currentUserSubject: .init(nil), onApply: {}, onDismiss: {})
    }
}
#endif
