//
// OtherSocialPlatformView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.11.2022.
//

import SwiftUI

struct OtherSocialPlatformView: View {
    
    @Binding var isPresented: Bool
    let socialNetworkHandle: SocialNetworkHandle?
    
    private var didAddContent: Bool {
        return socialNetworkHandle?.handle != nil
    }
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cultured)
                    .frame(height: 56)
                content
            }
            .roundedBorder(didAddContent ? Color.darkGreen : .midGrey)
            .animation(.linear(duration: 0.2), value: didAddContent)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var content: some View {
        if let websiteURLString = socialNetworkHandle?.websiteUrl?.absoluteString,
           let platformName = socialNetworkHandle?.platformName {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                    Image(.linkIcon)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(platformName)
                        .font(kernedFont: .Secondary.p3BoldKerned)
                    Text(websiteURLString)
                        .font(kernedFont: .Secondary.p2RegularKerned)
                }
                .foregroundColor(.darkGreen)
                Spacer()
                CheckmarkView()
            }
            .padding(.horizontal, 16)
        } else {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                    Image(.plusIcon)
                }
                Text(Strings.Buttons.other)
                    .font(kernedFont: .Secondary.p1MediumKerned)
                    .foregroundColor(.ebony)
            }
        }
    }
}

struct AddOtherSocialPlatformView: View {
    
    enum ActionType {
        case add
        case edit
    }
    
    let actionType: ActionType
    let onDone: (SocialNetworkHandle) -> Void
    
    @State private var platformName: String
    @State private var link: String
    @State private var platformError: Error?
    @State private var linkError: Error?
    
    @FocusState private var selectedField: InputFieldType?
    
    @Environment(\.dismiss) private var dismiss
    
    init(actionType: ActionType, platformName: String?, link: String?, onDone: @escaping (SocialNetworkHandle) -> Void) {
        self.actionType = actionType
        self._platformName = State(wrappedValue: platformName ?? "")
        self._link = State(wrappedValue: link ?? "")
        self.onDone = onDone
    }
    
    private var allFieldsCompleted: Bool {
        !platformName.isEmpty && !link.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 16) {
            navigationBarView
            ScrollView(showsIndicators: false) {
                inputFields
            }
        }
        .padding(.top, 12)
        .background(Color.cultured)
        .onChange(of: platformName) { _ in
            if platformError != nil {
                platformError = nil
            }
        }
        .onChange(of: link) { _ in
            if linkError != nil {
                linkError = nil
            }
        }
        .onChange(of: selectedField) { newField in
            if newField == .socialHandle, platformName.isEmpty {
                platformError = AuthenticationError.invalidPlatformName
            }
        }
    }
    
    private var navigationBarView: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    switch actionType {
                    case .edit:
                        Image(.backIcon)
                    case .add:
                        Text(Strings.Buttons.cancel)
                            .font(kernedFont: .Secondary.p1MediumKerned)
                            .foregroundColor(.ebony)
                    }
                }
                .buttonStyle(.plain)
                Text(Strings.NavigationTitles.addOtherPlatform)
                    .font(kernedFont: .Main.p1RegularKerned)
                    .foregroundColor(.darkGreen)
                    .frame(maxWidth: .infinity)
                doneButton
            }
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            DividerView()
        }
    }
    
    private func validateAndSendPlatform() {
        do {
            try link.isValidWebsite()
            let socialNetwork = SocialNetworkHandle(type: .other, websiteUrl: URL(string: link), platformName: platformName)
            onDone(socialNetwork)
            dismiss()
        } catch {
            linkError = error
        }
    }
    
    private var doneButton: some View {
        Button {
            validateAndSendPlatform()
        } label: {
            Text(Strings.Buttons.done)
                .font(kernedFont: .Secondary.p2BoldKerned)
                .foregroundColor(.orangish)
        }
        .buttonStyle(.plain)
        .disabled(!allFieldsCompleted)
        .opacity(allFieldsCompleted ? 1 : 0)
        .animation(.easeOut, value: allFieldsCompleted)
    }
    
    private var inputFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            InputField(
                inputText: $platformName,
                scope: Strings.TextFieldScope.socialPlatform,
                placeholder: Strings.Placeholders.platformName,
                submitLabel: .next
            ) {
                selectedField = .socialHandle
            }
            .defaultFieldStyle(error: platformError, hint: nil, focusDelay: 0)
            .focused($selectedField, equals: .socialPlatform)
            InputField(
                inputText: $link,
                scope: Strings.TextFieldScope.link,
                placeholder: Strings.Placeholders.profileLink,
                submitLabel: .done,
                onSubmit: validateAndSendPlatform
            )
            .defaultFieldStyle(
                error: linkError,
                hint: Strings.TextFieldHints.profileLink,
                keyboardType: .URL
            )
            .focused($selectedField, equals: .socialHandle)
            .textInputAutocapitalization(.never)
        }
    }
}

#if DEBUG
struct OtherPlatformView_Previews: PreviewProvider {
    
    static var previews: some View {
        OtherPlatformViewPreview()
    }
    
    private struct OtherPlatformViewPreview: View {
        @State var show = true
        
        @State var handle: SocialNetworkHandle?
        
        var body: some View {
            OtherSocialPlatformView(isPresented: $show, socialNetworkHandle: handle)
                .padding(.horizontal, 16)
                .sheet(isPresented: $show) {
                    AddOtherSocialPlatformView(actionType: .add, platformName: handle?.platformName, link: handle?.websiteUrl?.absoluteString) {
                        handle = $0
                    }
                }
        }
    }
}
#endif
