//
//  SocialNetworkContainerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 14.11.2022.
//

import SwiftUI

struct SocialNetworkContainerView: View {
    
    let selectedSocialNetworks: Set<SocialNetworkHandle>
    let onAddSocialNetworkHandle: (SocialNetworkHandle) -> Void
    
    @State private var selectedNetworkType: SocialNetworkType?
    @State private var isOtherPlatformPresented = false
    @Namespace private var socialNetworkNamespace
    private let gridColumns = Array(repeating: GridItem(.flexible()), count: 2)
    
    private func getSocialNetwork(
        from socialNetworkType: SocialNetworkType
    ) -> SocialNetworkHandle? {
        return selectedSocialNetworks.first(where: { $0.type == socialNetworkType })
    }
    
    private func prefillInput(for socialNetworkType: SocialNetworkType) -> String? {
        guard let socialNetwork = getSocialNetwork(from: socialNetworkType) else {
            return nil
        }
        switch socialNetworkType {
        case .website, .other: return socialNetwork.websiteUrl?.absoluteString
        case .instagram, .youtube, .tiktok: return socialNetwork.handle
        }
    }
    
    var body: some View {
        if let selectedNetworkType {
            ExpandedSocialNetworkView(
                input: prefillInput(for: selectedNetworkType),
                socialNetworkType: selectedNetworkType,
                namespace: socialNetworkNamespace,
                onCancel: {
                    withAnimation(.easeInOut) {
                        self.selectedNetworkType = nil
                    }
                }, onAddApplication: { input in
                    let socialNetwork: SocialNetworkHandle
                    if selectedNetworkType.isWebsiteType {
                        socialNetwork = SocialNetworkHandle(type: selectedNetworkType, websiteUrl: URL(string: input))
                    } else {
                        socialNetwork = SocialNetworkHandle(type: selectedNetworkType, handle: input)
                    }
                    onAddSocialNetworkHandle(socialNetwork)
                    withAnimation(.easeInOut) {
                        self.selectedNetworkType = nil
                    }
                })
        } else {
            socialNetworksContainerView
        }
    }
    
    private var socialNetworksContainerView: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(SocialNetworkType.allCases.dropLast(), id: \.rawValue) { networkType in
                    let socialNetwork = getSocialNetwork(from: networkType)
                    SocialNetworkView(
                        socialNetworkType: networkType,
                        handle: networkType.isWebsiteType ? socialNetwork?.websiteUrl?.absoluteString : socialNetwork?.handle,
                        namespace: socialNetworkNamespace
                    ) {
                        withAnimation(.easeInOut) {
                            self.selectedNetworkType = networkType
                        }
                    }
                }
            }
            OtherSocialPlatformView(
                isPresented: $isOtherPlatformPresented, socialNetworkHandle: getSocialNetwork(from: .other)
            )
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $isOtherPlatformPresented) {
            let socialNetwork: SocialNetworkHandle? = getSocialNetwork(from: .other)
            AddOtherSocialPlatformView(
                actionType: .add,
                platformName: socialNetwork?.platformName,
                link: socialNetwork?.websiteUrl?.absoluteString
            ) { networkHandle in
                onAddSocialNetworkHandle(networkHandle)
            }
        }
    }
}

extension SocialNetworkContainerView {
    
    struct ExpandedSocialNetworkView: View {
        
        let socialNetworkType: SocialNetworkType
        let namespace: Namespace.ID
        let onCancel: () -> Void
        let onAddApplication: (String) -> Void
        
        @State private var input: String
        
        init(input: String?,
             socialNetworkType: SocialNetworkType,
             namespace: Namespace.ID,
             onCancel: @escaping () -> Void,
             onAddApplication: @escaping (String) -> Void
        ) {
            self.socialNetworkType = socialNetworkType
            self.namespace = namespace
            self.onCancel = onCancel
            self.onAddApplication = onAddApplication
            
            let defaultInputValue: String
            if [SocialNetworkType.instagram, .tiktok].contains(socialNetworkType) {
                defaultInputValue = "@"
            } else {
                defaultInputValue = ""
            }
            self._input = State(wrappedValue: input ?? defaultInputValue)
        }
        
        var body: some View {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(socialNetworkType == .website ? Color.cappuccino : .white)
                        .frame(width: 56, height: 56)
                    socialNetworkType.image
                }
                .matchedGeometryEffect(id: socialNetworkType.rawValue, in: namespace)
                VStack(spacing: 8) {
                    inputField
                    actionButtons
                }
                .clipped()
            }
            .padding(.top, 16 )
            .frame(maxWidth: .infinity)
            .background(Color.beige.cornerRadius(8))
            .padding(.horizontal, 16)
        }
        
        private var inputField: some View {
            InputField(
                inputText: $input,
                scope: socialNetworkType.label,
                placeholder: nil,
                submitLabel: .done
            ) {
                onAddApplication(input)
            }
            .defaultFieldStyle(
                hint: nil,
                keyboardType: socialNetworkType.isWebsiteType ? .URL : .default,
                focusDelay: 0
            )
            .textInputAutocapitalization(.never)
        }
        
        private var actionButtons: some View {
            HStack(spacing: -16) {
                Buttons.FillBorderedButton(title: Strings.Buttons.cancel, action: onCancel)
                    .padding([.horizontal, .bottom], 16)
                if addButtonVisible {
                    Buttons.FilledRoundedButton(title: Strings.Buttons.add) {
                        onAddApplication(input)
                    }
                    .transition(
                        .asymmetric(insertion: .opacity.animation(.linear(duration: 0.25)), removal: .identity)
                    )
                }
            }
        }
        
        private var addButtonVisible: Bool {
            guard !input.isEmpty else {
                return false
            }
            switch socialNetworkType {
            case .instagram, .tiktok: return input.count > 1
            default: return true
            }
        }
    }
}

extension SocialNetworkContainerView {
    struct SocialNetworkView: View {
        
        let socialNetworkType: SocialNetworkType
        let handle: String?
        let namespace: Namespace.ID
        let onSelect: () -> Void
        
        private let isSelected: Bool
        
        init(socialNetworkType: SocialNetworkType, handle: String?, namespace: Namespace.ID, onSelect: @escaping () -> Void) {
            self.socialNetworkType = socialNetworkType
            self.handle = handle
            self.namespace = namespace
            self.onSelect = onSelect
            self.isSelected = handle != nil
        }
        
        var body: some View {
            Button {
                onSelect()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.cultured)
                        .frame(height: 112)
                    VStack(spacing: 4) {
                        imageView
                            .matchedGeometryEffect(id: socialNetworkType.rawValue, in: namespace)
                        if let handle {
                            Text(handle)
                                .font(kernedFont: .Secondary.p2RegularKerned)
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                                .padding(.horizontal, 12)
                        }
                    }
                }
                .overlay(alignment: .topTrailing, content: checkmarkTag)
                .roundedBorder(isSelected ? Color.darkGreen : .midGrey)
                .animation(.linear(duration: 0.2), value: isSelected)
            }
            .buttonStyle(.plain)
        }
        
        private var imageView: some View {
            ZStack {
                Circle()
                    .fill(socialNetworkType == .website ? Color.cappuccino : .white)
                    .frame(width: 56, height: 56)
                socialNetworkType.image
            }
        }
        
        @ViewBuilder
        private func checkmarkTag() -> some View {
            if isSelected {
                CheckmarkView()
                    .padding([.top, .trailing], 10)
            }
        }
    }
}

#if DEBUG
struct SocialHandlesView_Previews: PreviewProvider {
    static var previews: some View {
        SocialHandlesPreview()
    }
    
    private struct SocialHandlesPreview: View {
        @State var selectedHandles = Set<SocialNetworkHandle>()
        
        var body: some View {
            VStack(spacing: 40) {
                SocialNetworkContainerView(selectedSocialNetworks: selectedHandles, onAddSocialNetworkHandle: { handle in
                    selectedHandles.insert(handle)
                })
            }
            .onAppear {
                selectedHandles.insert(SocialNetworkHandle(type: .other, websiteUrl: URL(string: "https://twitter.com/elonmusk"), platformName: "Twitter"))
            }
        }
    }
}
#endif
