//
//  EditSocialNetworksView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.11.2022.
//

import SwiftUI

struct EditSocialNetworksView: View {
    
    @ObservedObject var viewModel: EditSocialNetworksViewModel
    
    private func socialRowInputBinding(_ type: SocialNetworkType) -> Binding<SocialNetworkHandle> {
        return Binding(get: {
            viewModel.socialNetworks[type] ?? SocialNetworkHandle(type: type, handle: nil)
        }, set: { newValue in
            viewModel.socialNetworks.updateValue(newValue, forKey: type)
        })
    }
    
    private func inputErrorBinding(_ type: SocialNetworkType) -> Binding<Error?> {
        return Binding(get: {
            viewModel.socialNetworksErrors[type]
        }, set: { _ in
            viewModel.socialNetworksErrors.removeValue(forKey: type)
        })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            navigationBarView
            Text(Strings.Others.socialHandlesMessage)
                .font(kernedFont: .Secondary.p1MediumKerned)
                .foregroundColor(.ebony)
                .padding(.horizontal, 16)
                .lineSpacing(4)
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(SocialNetworkType.allCases, id: \.rawValue) { socialNetworkType in
                        SocialNetworkRowView(
                            socialNetwork: socialRowInputBinding(socialNetworkType),
                            error: inputErrorBinding(socialNetworkType)
                        )
                        .overlay {
                            if socialNetworkType == .other {
                                invisibleNavigation
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, 12)
        .background(Color.cultured)
        .errorToast(error: $viewModel.backendError)
    }
    
    private var navigationBarView: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button {
                        viewModel.onClose.send()
                    } label: {
                        Text(Strings.Buttons.cancel)
                            .font(kernedFont: .Secondary.p1MediumKerned)
                            .foregroundColor(.ebony)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    if viewModel.isShowButtonVisible {
                        Buttons.SaveButton(isEnabled: true, isLoading: viewModel.isLoading) {
                            viewModel.updateSocialNetworks()
                        }
                        .transition(.opacity.animation(.linear(duration: 0.25)))
                    }
                }
                Text(Strings.NavigationTitles.editSocialLinks)
                    .font(kernedFont: .Main.p1RegularKerned)
                    .foregroundColor(.darkGreen)
                    .frame(maxWidth: .infinity)
            }
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            DividerView()
        }
    }
    
    private var invisibleNavigation: some View {
        Color.white.opacity(0.001)
            .onTapGesture {
                viewModel.onShowOtherPlatform.send()
            }
    }
}

struct SocialNetworkRowView: View {
    
    @Binding var socialNetwork: SocialNetworkHandle
    @Binding var error: Error?
    
    @FocusState private var isFocused: Bool
    
    private var inputBinding: Binding<String> {
        return Binding(get: {
            switch socialNetwork.type {
            case .instagram, .tiktok, .youtube:
                return socialNetwork.handle?.trimmingCharacters(in: .whitespaces) ?? ""
            case .website:
                return socialNetwork.websiteUrl?.absoluteString ?? ""
            case .other: return socialNetwork.platformName ?? ""
            }
        }, set: { newValue in
            if error != nil {
                error = nil
            }
            let trimmedNewValue = newValue.trimmingCharacters(in: .whitespaces)
            switch socialNetwork.type {
            case .instagram, .tiktok, .youtube:
                socialNetwork.handle = trimmedNewValue
            case .website:
                return socialNetwork.websiteUrl = URL(string: trimmedNewValue)
            case .other: break
            }
        })
    }
    
    var body: some View {
        InputField(
            inputText: inputBinding,
            scope: nil,
            placeholder: socialNetwork.type.inputPlaceholder,
            leadingView:  {
                socialNetworkIcon
            }, onSubmit: { }
        )
        .defaultFieldStyle(error: error, hint: nil, keyboardType: socialNetwork.type.isWebsiteType ? .URL : .default)
        .focused($isFocused)
        .disabled(socialNetwork.type == .other)
        .onChange(of: isFocused) { newValue in
            handleFocusChanged(newValue)
        }
    }
    
    private func handleFocusChanged(_ isFocused: Bool) {
        guard let handle = socialNetwork.handle, handle.count < 2,
              [SocialNetworkType.instagram, .tiktok].contains(socialNetwork.type) else {
            return
        }
        socialNetwork.handle = isFocused ? "@" : ""
    }
    
    private var socialNetworkIcon: some View {
        ZStack {
            Circle()
                .fill(Color.white)
            socialNetwork.type.image
                .resizedToFit(width: 24, height: 24)
        }
        .frame(width: 40, height: 40)
    }
}

#if DEBUG
struct EditSocialNetworksView_Previews: PreviewProvider {
    static var previews: some View {
        EditSocialNetworksPreviews()
    }
    
    private struct EditSocialNetworksPreviews: View {
        
        @StateObject var viewModel = EditSocialNetworksViewModel(userRepository: MockUserRepository())
        
        var body: some View {
            EditSocialNetworksView(viewModel: viewModel)
        }
    }
}
#endif
