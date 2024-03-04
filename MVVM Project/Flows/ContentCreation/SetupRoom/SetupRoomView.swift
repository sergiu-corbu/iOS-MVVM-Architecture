//
//  SetupRoomView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.12.2022.
//

import SwiftUI

struct SetupRoomView: View {
    
    @ObservedObject var viewModel: SetupRoomViewModel
    @State private var progressStates = ProgressState.createStaticStates(currentIndex: 3)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            navigationView
            ScrollView {
                mainContent
            }
            .scrollDismissesKeyboard(.immediately)
            .overlayLoadingIndicator(viewModel.loadingScope == .draftShowLoading, scale: 1.1)
        }
        .primaryBackground()
        .errorToast(error: $viewModel.error)
        .bottomSheet(isPresented: $viewModel.showPublishTimePicker) {
            ShowTimePublishingPicker(
                publishDate: viewModel.laterPublishDate,
                startDateInAdvance: .now.nearestTime(minutes: 60).adding(component: .minute, value: 60),
                onCancel: {
                    viewModel.showPublishTimePicker = false
                }, onSave: viewModel.saveLaterPublishDate(_:)
            )
        }
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 32) {
            switch viewModel.contentCreationType {
            case .recordedVideo:
                VideoUploadSectionView(viewModel: viewModel.videoUploadSectionViewModel)
                showTitleView
            case .liveStream:
                showTitleView
                VideoUploadSectionView(viewModel: viewModel.videoUploadSectionViewModel)
            }
            publishingTimeView
            FeaturedProductsCollectionView(viewModel.selectedProductsForCollaboration)
            publishButton
        }
        .padding(.top, 24)
        .disabled(viewModel.loadingScope == .showUploading)
    }
}

//MARK: NavigationView
private extension SetupRoomView {
    
    var navigationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationBar(
                inlineTitle: Strings.NavigationTitles.setupRoom,
                onDismiss: viewModel.onBack.send,
                trailingView: {
                    Buttons.QuickActionButton(action: viewModel.onCancel.send)
                }
            )
            StepProgressView(currentIndex: 3, progressStates: progressStates)
                .onChange(of: viewModel.publishButtonEnabled) { newValue in
                    progressStates[3] = newValue ? .progress(1) : .idle
                }
        }
    }
    
    var publishButton: some View {
        Buttons.FilledRoundedButton(
            title: viewModel.publishButtonStringLabel,
            isEnabled: viewModel.publishButtonEnabled,
            isLoading: viewModel.loadingScope == .showUploading,
            action: viewModel.publishContent
        )
    }
}

//MARK: Show Information
private extension SetupRoomView {
    
    var showTitleView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.ContentCreation.showTitle.uppercased())
                .font(kernedFont: .Main.p1MediumKerned)
                .foregroundColor(.jet)
                .padding(.leading, 16)
            InputField(
                inputText: $viewModel.showTitle, scope: nil,
                placeholder: Strings.Placeholders.showTitle, onSubmit: {})
            .defaultFieldStyle(hint: nil)
        }
    }
    
    var publishingTimeView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.ContentCreation.publishingTimeSelection.uppercased())
                .font(kernedFont: .Main.p1MediumKerned)
                .foregroundColor(.jet)
                .padding(.horizontal, 16)
            switch viewModel.contentCreationType {
            case .recordedVideo:
                publishingTimeSection(ShowPublishTime.allCases, selectionBinding: $viewModel.publishTime)
                    .onChange(of: viewModel.publishTime) { newValue in
                        switch newValue {
                        case .later:
                            viewModel.showPublishTimePicker = true
                        case .now:
                            viewModel.videoUploadSectionViewModel.updateTeaserVideoSectionIfNeeded(shouldInsert: false)
                        }
                    }
            case .liveStream:
                let scheduleTimeBinding = Binding(get: {
                    return ShowPublishTime.later
                }, set: { _ in
                    viewModel.showPublishTimePicker.toggle()
                })
                publishingTimeSection([.later], selectionBinding: scheduleTimeBinding)
            }
        }
    }
    
    private func publishingTimeSection(_ availablePublishTimes: [ShowPublishTime], selectionBinding: Binding<ShowPublishTime>) -> some View {
        SegmentedPicker(
            selection: selectionBinding,
            items: availablePublishTimes,
            overrideSegmentTexts: viewModel.customSegmentsLabel
        ) { segment in
            segment?.image
                .renderingMode(.template)
                .foregroundColor(segment == viewModel.publishTime ? .darkGreen : .middleGrey)
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
struct SetupRoomView_Previews: PreviewProvider {
    
    static var previews: some View {        
        LiveStreamSetupRoomPreview()
            .previewDisplayName("Live Stream")
        RecordedSetupRoomPreview()
            .previewDisplayName("Recorded Video")
    }
    
    private struct LiveStreamSetupRoomPreview: View {
        
        @StateObject var viewModel = SetupRoomViewModel(
            selectedProductsForCollaboration: [.prod1, .prod7, .prod3],
            contentCreationType: .liveStream,
            contentCreationService: MockContentCreationService(),
            uploadService: MockAWSUploadService()
        )
        var body: some View {
            SetupRoomView(viewModel: viewModel)
        }
    }
    
    private struct RecordedSetupRoomPreview: View {
        
        @StateObject var viewModel = SetupRoomViewModel(
            selectedProductsForCollaboration: [.prod1, .prod7, .prod3],
            contentCreationType: .recordedVideo,
            contentCreationService: MockContentCreationService(),
            uploadService: MockAWSUploadService()
        )
        var body: some View {
            SetupRoomView(viewModel: viewModel)
        }
    }

}
#endif
