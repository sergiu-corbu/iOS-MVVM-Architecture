//
//  VideoUploadSectionView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.12.2022.
//

import SwiftUI
import AVKit

struct VideoUploadSectionView: View {
    
    @ObservedObject var viewModel: VideoUploadSectionViewModel
    @State private var showThumbnailPreview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.availableVideoSections) { videoSection in
                createVideoUploadView(sectionType: videoSection)
            }
            communityGuidelinesView
            DividerView()
        }
        .animation(.easeInOut(duration: 0.75), value: viewModel.previewImagesMap)
        .animation(.easeInOut, value: viewModel.availableVideoSections)
        .fullScreenCover(isPresented: $showThumbnailPreview) {
            if let thumbnail = viewModel.thumbnailImage {
                ThumbnailPreview(thumbnail)
            }
        }
        .fullScreenCover(item: $viewModel.selectedPreviewVideoSection) {
            if let videoAsset = viewModel.videoAssetsMap[$0] {
                VideoPreview(videoAsset: videoAsset)
            }
        }
    }
    
    private func createVideoUploadView(sectionType videoSectionType: VideoSectionType) -> some View {
        VideoUploadView(
            videoSection: videoSectionType,
            isLoadingAsset: viewModel.remoteAssetFetchingSection == videoSectionType,
            showPreviewContent: viewModel.previewImagesMap[videoSectionType] != nil,
            previewContent: {
                if let previewImage = viewModel.previewImagesMap[videoSectionType] {
                    videoPreviewImage(previewImage, videoSection: videoSectionType)
                }
            }, uploadAction: {
                viewModel.presentVideoSelection(for: videoSectionType)
            }
        )
        .transition(.asymmetric(insertion: .opacity, removal: .identity))
    }
    
    private var communityGuidelinesView: some View {
        VStack(spacing: 2) {
            Text(Strings.ContentCreation.uploadGuidelines)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
            Link(destination: Constants.COMMUNITY_GUIDELINES) {
                Text(Strings.ContentCreation.communityGuidelines)
                    .font(kernedFont: .Secondary.p1BoldKerned)
                    .foregroundColor(.orangish)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }
}

//MARK: Recording & Teaser Upload
private extension VideoUploadSectionView {
    
    struct VideoUploadView<PreviewContent: View>: View {
        
        let videoSection: VideoSectionType
        let isLoadingAsset: Bool
        let showPreviewContent: Bool
        @ViewBuilder let previewContent: PreviewContent
        let uploadAction: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(videoSection.uploadSectionHeader.uppercased())
                    .font(kernedFont: .Main.p1MediumKerned)
                    .foregroundColor(.jet)
                    .padding(.leading, 16)
                DividerView()
                    .background(Color.beige.padding(.bottom, -12))
                
                if showPreviewContent {
                    previewContent
                } else {
                    VStack(spacing: 16) {
                        uploadButtonView
                        Text(videoSection.uploadVideoGuidelinesMessage)
                            .font(kernedFont: .Secondary.p1RegularKerned)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.jet)
                    }
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .background(Color.beige)
                    .transition(.opacity)
                }
            }
        }
        
        private var uploadButtonView: some View {
            Button {
                uploadAction()
            } label: {
                let loadingAssetView = HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.jet)
                        .scaleEffect(1.3)
                    Text(Strings.ContentCreation.uploadingVideoFile)
                        .font(kernedFont: .Secondary.p1BoldKerned)
                        .foregroundColor(.jet)
                }
                .transition(.opacity)

                return ZStack {
                    if isLoadingAsset {
                        loadingAssetView
                    } else {
                        Circle()
                            .fill(Color.beige)
                            .frame(width: 40, height: 40)
                        Image(.plusIconLight)
                            .resizedToFit(width: 15, height: 15)
                    }
                }
                .animation(.easeInOut, value: isLoadingAsset)
                .frame(maxWidth: .infinity, minHeight: 72)
                .dashedBorder(
                    strokeStyle: StrokeStyle(lineWidth: 1, dash: [3]),
                    cornerRadius: 8, fillColor: .ebony.opacity(0.55)
                )
                .background(Color.cultured.cornerRadius(8))
            }
            .buttonStyle(.plain)
        }
    }
}

//MARK: previewImage
private extension VideoUploadSectionView {
    
    func videoPreviewImage(_ previewImage: UIImage, videoSection: VideoSectionType) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Image(uiImage: previewImage)
                    .resizedToFit(size: nil)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                VStack(spacing: 8) {
                    Buttons.MaterialButton(image: Image(.plusIconLight)) {
                        viewModel.presentVideoSelection(for: videoSection)
                    }
                    Buttons.MaterialButton(image: Image(.eyeIcon)) {
                        viewModel.presentVideoPreview(for: videoSection)
                    }
                }
            }
            .frame(height: 278)
            if videoSection == .recorded {
                DividerView()
                Group {
                    if let thumbnailImage = viewModel.thumbnailImage {
                        thumbnailContainerView(thumbnailImage, videoSection: videoSection)
                    } else {
                        thumbnailPlaceholderView(onImageSelection: {
                            viewModel.presentImageSelection()
                        })
                    }
                }
                .padding(.horizontal, 16)
                .transition(.opacity)
            }
            DividerView()
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.thumbnailImage)
        .background(Color.beige)
    }
}

//MARK: Thumbnail Section
private extension VideoUploadSectionView {
    
    func thumbnailContainerView(_ thumbnail: UIImage, videoSection: VideoSectionType) -> some View {
        HStack(spacing: 8) {
            Button {
                showThumbnailPreview = true
            } label: {
                Image(uiImage: thumbnail)
                    .resizedToFill(width: 56, height: 100)
                    .overlay(
                        ZStack {
                            Color.ebony.opacity(0.15)
                            Color.jet.opacity(0.25)
                            Image(.eyeIcon)
                        }
                    )
                    .cornerRadius(5)
                    .clipped()
                    .roundedBorder(Color.ebony.opacity(0.15))
                                }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.ContentCreation.customThumbnail)
                    .font(kernedFont: .Secondary.p1BoldKerned)
                    .foregroundColor(.jet)
                Text(Strings.ContentCreation.customThumbnailMessage)
                    .font(kernedFont: .Secondary.p2RegularKerned)
                    .foregroundColor(.ebony)
                HStack(spacing: 8) {
                    Buttons.BorderedActionButton(
                        title: Strings.Buttons.clear.uppercased(),
                        tint: .firebrick
                    ) {
                        viewModel.thumbnailImage = nil
                    }
                    Buttons.BorderedActionButton(title: Strings.Buttons.changeCover.uppercased(), tint: .jet) {
                        viewModel.presentImageSelection()
                    }
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func thumbnailPlaceholderView(onImageSelection: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Button {
                onImageSelection()
            } label: {
                VStack(spacing: 6) {
                    Image(.mediaContentIcon)
                        .renderingMode(.template)
                        .foregroundColor(.paleSilver)
                    Text(Strings.Buttons.add.uppercased())
                        .font(kernedFont: .Secondary.p3BoldKerned)
                        .foregroundColor(.orangish)
                }
                .padding(.horizontal, 16)
                .frame(height: 100)
                .background(Color.cappuccino.cornerRadius(5))
                .roundedBorder(Color.midGrey)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 4) {
                Label {
                    Text(Strings.Others.optional.uppercased())
                        .font(kernedFont: .Secondary.p3RegularKerned)
                        .foregroundColor(.ebony)
                } icon: {
                    Image(.informativeIcon)
                }
                .padding(.bottom, 8)
                Text(Strings.ContentCreation.videoThumbnailMessage)
                    .font(kernedFont: .Secondary.p3BoldKerned)
                    .foregroundColor(.jet)
                Text(Strings.ContentCreation.videoThumbnailDescription)
                    .font(kernedFont: .Secondary.p2RegularKerned)
                    .foregroundColor(.ebony)
                    .lineLimit(3)
                    .minimumScaleFactor(0.9)
            }
        }
    }
}

#if DEBUG
struct VideoUploadSectionView_Previews: PreviewProvider {

    static var previews: some View {
        VideoUploadSelectionPreview(contentCreationType: .recordedVideo)
            .previewDisplayName("Recorded Video")
        VideoUploadSelectionPreview(contentCreationType: .liveStream)
            .previewDisplayName("Prepare to go live")
    }

    private struct VideoUploadSelectionPreview: View {

        @StateObject var viewModel: VideoUploadSectionViewModel
        
        init(contentCreationType: ContentCreationType) {
            self._viewModel = StateObject(wrappedValue: VideoUploadSectionViewModel(contentCreationType: contentCreationType,
                mediaAssetProvider: MockMediaAssetProvider(), presentationController: nil))
        }

        var body: some View {
            VideoUploadSectionView(viewModel: viewModel)
                .task {
                    //await Task.sleep(seconds: 1.5)
                    //viewModel.previewImage = UIImage(named: "sweatshirt")
                    viewModel.thumbnailImage = UIImage(named: "sweatshirt")
                }
        }
    }
}
#endif
