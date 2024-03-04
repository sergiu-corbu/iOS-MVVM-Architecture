//
//  EditCreatorProfileView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 23.11.2022.
//

import SwiftUI

struct EditCreatorProfileView: View {
    
    @ObservedObject var viewModel: EditCreatorProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            NavigationBar(
                inlineTitle: Strings.NavigationTitles.edtiProfile,
                onDismiss: viewModel.onBack.send
            )
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    imagePreview
                    userInfoSection
                }
            }
        }
        .primaryBackground()
        .errorToast(error: $viewModel.error)
        .sheet(isPresented: $viewModel.isEditBioPresented, content: editBioView)
    }
    
    private func editBioView() -> some View {
        let editBioViewModel = EditCreatorBioViewModel(
            creatorBio: viewModel.user.bio,
            userRepository: viewModel.userRepository
        )
        return EditCreatorBioView(viewModel: editBioViewModel)
    }
    
    private var imagePreview: some View {
        ZStack {
            AsyncImageView(
                imageURL: viewModel.user.profilePictureUrl,
                localImage: viewModel.localProfileImage,
                placeholder: {
                    Button {
                        viewModel.onAddProfilePicture.send()
                    } label: {
                        ImagePlaceholderView()
                            .frame(width: 181, height: 242)
                            .dashedBorder()
                    }
                    .buttonStyle(.plain)
                }
            )
            .transition(.opacity.animation(.easeInOut(duration: 1)))
            .aspectRatio(contentMode: .fit)
            .cornerRadius(5)
            .frame(maxWidth: 181, maxHeight: 242)
            .overlay {
                if viewModel.isUploadingImage {
                    uploadingImageIndicatorView
                }
            }
            if viewModel.user.profilePictureUrl != nil, !viewModel.isUploadingImage {
                Button {
                    viewModel.onAddProfilePicture.send()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.brightGold.opacity(0.45))
                            .frame(width: 87, height: 87)
                            .background(.ultraThinMaterial, in: Circle())
                            .opacity(0.65)
                        Text(Strings.Buttons.changeCover.uppercased())
                            .foregroundColor(.white)
                            .font(kernedFont: .Secondary.p3BoldKerned)
                            .multilineTextAlignment(.center)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var uploadingImageIndicatorView: some View {
        ZStack {
            LinearGradient(
                colors: [.middleGrey.opacity(0.45), .jet.opacity(0.45)],
                startPoint: .top, endPoint: .bottom
            )
            .cornerRadius(5)
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.4)
        }
        .transition(.opacity.animation(.easeInOut(duration: 1)))
    }
    
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 32) {
            ProfileComponents.BioSectionView(bio: viewModel.user.bio, isEditable: true, onUpdateBio: {
                viewModel.isEditBioPresented = true
            })
            ProfileComponents.SocialLinksSectionView(socialLinks: viewModel.user.socialNetworks, isEditable: true, onUpdateSocialLinks: {
                viewModel.onAddSocial.send()
            })
        }
        .padding(.vertical, 16)
    }
}

#if DEBUG
struct EditCreatorProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        EditCreatorProfileViewPreview()
    }
    
    private struct EditCreatorProfileViewPreview: View {
        
        @StateObject var viewModel = EditCreatorProfileViewModel(
            user: User.creator,
            localProfileImage: nil,
            userRepository: MockUserRepository(),
            uploadService: MockAWSUploadService()
        )
        
        var body: some View {
            EditCreatorProfileView(viewModel: viewModel)
                .task {
                    await Task.sleep(seconds: 1)
                    //viewModel.localProfileImage = UIImage(named: "user_profile")
                    //viewModel.isUploadingImage = true
//                    await Task.sleep(seconds: 4)
//                    viewModel.isUploadingImage = false
                }
        }
    }
}
#endif
