//
//  EditCreatorBioView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 25.11.2022.
//

import SwiftUI

struct EditCreatorBioView: View {
    
    @ObservedObject var viewModel: EditCreatorBioViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            navigationView
            ScrollView {
                inputContainerView
            }
        }
        .padding(.top, 21)
        .primaryBackground()
        .errorToast(error: $viewModel.backendError)
    }
    
    private var navigationView: some View {
        VStack(spacing: 12) {
            ZStack {
                HStack(spacing: 0) {
                    Button {
                        dismiss()
                    } label: {
                        Text(Strings.Buttons.cancel)
                            .font(kernedFont: .Secondary.p5MediumKerned)
                            .foregroundColor(.ebony)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    saveButton
                }
                Text(Strings.NavigationTitles.editBio)
                    .font(kernedFont: .Main.p1RegularKerned)
                    .foregroundColor(.darkGreen)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            DividerView()
        }
    }
    
    private var saveButton: some View {
        Buttons.SaveButton(isEnabled: viewModel.saveButtonEnabled, isLoading: viewModel.isLoading) {
            viewModel.saveCreatorBio(completion: {
                dismiss()
            })
        }
    }
    
    private var inputContainerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.Profile.bioTitle.uppercased())
                .font(kernedFont: .Main.p1MediumKerned)
                .foregroundColor(.brownJet)
                .padding(.horizontal, 16)
            Text(Strings.Others.bioMessage)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
                .padding(.horizontal, 16)
            VStack(alignment: .trailing, spacing: 16) {
                TextView(text: $viewModel.creatorBio, maxCharachters: viewModel.maxCharachters, focusDelay: 0.5)
                    .frame(height: 184)
                    .roundedBorder(Color.midGrey)
                Text(viewModel.remainingCharachtersString)
                    .font(kernedFont: .Secondary.p2RegularKerned)
                    .monospacedDigit()
                    .foregroundColor(.middleGrey)
            }
            .padding(.horizontal, 16)
            DividerView()
        }
    }
}

#if DEBUG
struct EditCreatorBioView_Previews: PreviewProvider {
    
    static var previews: some View {
        EditCreatorBioViewPreview()
    }
    
    private struct EditCreatorBioViewPreview: View {
        
        @StateObject var viewModel = EditCreatorBioViewModel(creatorBio: "some input text", userRepository: MockUserRepository())
        
        var body: some View {
            EditCreatorBioView(viewModel: viewModel)
        }
    }
}
#endif
