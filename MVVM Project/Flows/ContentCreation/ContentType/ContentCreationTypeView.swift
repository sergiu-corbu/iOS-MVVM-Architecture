//
//  ContentCreationTypeView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.11.2022.
//

import SwiftUI

typealias ShowStreamingType = ContentCreationType

enum ContentCreationType: String, CaseIterable, Decodable {
    
    case liveStream = "live"
    case recordedVideo = "prerecorded"
    
    var image: Image {
        switch self {
        case .liveStream: return Image(.playIcon)
        case .recordedVideo: return Image(.addMediaIcon)
        }
    }
    
    var label: String {
        switch self {
        case .liveStream: return Strings.Buttons.goLive
        case .recordedVideo: return Strings.Buttons.uploadVideo
        }
    }
}

enum VideoSectionType: Int, CaseIterable, Identifiable {
    case recorded
    case teaser
    
    var id: Int {
        return rawValue
    }
    
    var uploadSectionHeader: String {
        switch self {
        case .teaser: return Strings.ContentCreation.uploadTeaserVideo
        case .recorded: return Strings.ContentCreation.uploadVideo
        }
    }
    
    var uploadVideoGuidelinesMessage: String {
        switch self {
        case .teaser: return Strings.ContentCreation.teaserUploadFileMessage
        case .recorded: return Strings.ContentCreation.videoUploadFileTypeMessage
        }
    }
    
    var videoUploadScope: UploadScope {
        switch self {
        case .recorded: return .videoShow
        case .teaser: return .teaserShow
        }
    }
    
    var maximumAssetDuration: TimeInterval {
        switch self {
        case .recorded: return 20 * 60
        case .teaser: return 60
        }
    }
}

struct ContentCreationTypeView: View {
    
    @State private var progressStates = ProgressState.createStaticStates(currentIndex: 0)
    @State private var selectedCreationType: ContentCreationType?
    
    enum Action {
        case cancel
        case selectCreationType(ContentCreationType)
        case requestProduct
    }
    let actionHandler: (Action) -> Void
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 24) {
                NavigationBar(
                    inlineTitle: Strings.NavigationTitles.createContent, onDismiss: {},
                    trailingView: {
                        Buttons.QuickActionButton(action: { actionHandler(.cancel)})
                    }
                )
                .backButtonHidden(true)
                StepProgressView(currentIndex: 0, progressStates: progressStates)
                Text(Strings.ContentCreation.uploadQuestion)
                    .font(kernedFont: .Main.h1MediumKerned)
                    .foregroundColor(.jet)
                    .padding(.horizontal, 16)
                Spacer()
            }
            .primaryBackground()
            creationTypeView
        }
        .onDisappear {
            progressStates[0] = .idle
            selectedCreationType = nil
        }
    }
    
    private var creationTypeView: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: 16) {
                Color.clear.frame(height: geometryProxy.size.height / 2)
                HStack(spacing: 8) {
                    ForEach(ContentCreationType.allCases, id: \.rawValue) { creationType in
                        contentCreationButtonView(creationType)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16))
                DividerView()
                    .padding(.horizontal, 16)
                GiftSelectionView(onRequestProduct: { actionHandler(.requestProduct) })
            }
        }
    }
    
    private func contentCreationButtonView(_ creationType: ContentCreationType) -> some View {
        let isSelected = selectedCreationType == creationType
        return Button {
            Task(priority: .userInitiated) { @MainActor in
                guard selectedCreationType == nil else {
                    return
                }
                progressStates[0] = .progress(1)
                selectedCreationType = creationType
                await Task.sleep(seconds: 0.2)
                actionHandler(.selectCreationType(creationType))
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.ebony)
                HStack(spacing: 8) {
                    creationType.image
                        .renderingMode(.template)
                        .resizedToFit(width: 24, height: 24)
                    Text(creationType.label)
                        .font(kernedFont: .Secondary.p1BoldKerned)
                }
                .foregroundColor(isSelected ? .darkGreen : .ebony)
            }
            .frame(height: 72)
            .background(Color.ebony.opacity(isSelected ? 0.15 : 0.001))
            .animation(.easeInOut, value: selectedCreationType)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct ContentCreationTypeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentCreationTypeView(actionHandler: { _ in})
    }
}
#endif
