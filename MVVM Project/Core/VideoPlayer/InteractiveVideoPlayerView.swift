//
//  InteractiveVideoPlayerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.05.2023.
//

import SwiftUI
import UIKit
import Combine

struct InteractiveVideoPlayerView<Content: View>: View {
    
    let interactionEnabled: Bool
    @ViewBuilder let content: Content
    
    init(show: Show, interactionEnabled: Bool = true, videoPlayerService: VideoPlayerService, @ViewBuilder content: () -> Content) {
        self.interactionEnabled = interactionEnabled
        self.content = content()
        self._viewModel = StateObject(wrappedValue: ViewModel(videoPlayerService: videoPlayerService, show: show))
    }
    
    //Internal State
    @StateObject private var viewModel: ViewModel
    
    private var videoPlayer: VideoPlayerService {
        return viewModel.videoPlayerService
    }
    private var displayedTimeValue: TimeInterval {
        return viewModel.seekedTime ?? viewModel.currentTime
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Group {
                if viewModel.isDragging {
                    PlayerInteractionDetailView(maximumValue: videoPlayer.currentItemDuration, currentValuePublisher: viewModel.previewSecondsPublisher)
                } else {
                    content
                }
            }
            .transition(.opacity)
            SliderView(
                currentValue: displayedTimeValue,
                maximumValue: max(videoPlayer.currentItemDuration - 1, 0),
                interactiveEventHandler: viewModel.handleInteractiveEvent(_:)
            )
            .disabled(!videoPlayer.isVideoPlayerReadyToPlay || !interactionEnabled)
        }
        .animation(.easeInOut, value: viewModel.isDragging)
    }
}

private extension InteractiveVideoPlayerView {
    
    final class ViewModel: ObservableObject {
        
        //MARK: - Properties
        @Published private(set) var currentTime: TimeInterval = .zero
        @Published private(set) var isDragging: Bool = false
        let show: Show
        private(set) var seekedTime: TimeInterval?
        let previewSecondsPublisher = PassthroughSubject<TimeInterval, Never>()
        
        //MARK: Services
        let videoPlayerService: VideoPlayerService
        let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
        
        private var cancellables = [AnyCancellable]()
        
        init(videoPlayerService: VideoPlayerService, show: Show) {
            self.show = show
            self.videoPlayerService = videoPlayerService
            setupBindings()
        }
        
        private func setupBindings() {
            videoPlayerService.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
            
            videoPlayerService.currentTimePublisher.sink { [weak self] value in
                if self?.videoPlayerService.isPaused == false {
                    self?.currentTime = value
                }
            }
            .store(in: &cancellables)
        }
        
        //MARK: - Interaction
        func handleInteractiveEvent(_ interactiveEvent: InteractivePlayerEventType) {
            switch interactiveEvent {
            case .dragStarted:
                isDragging = true
                videoPlayerService.videoPlayer?.pause()
                seekedTime = nil
            case .dragInProgress(let value):
                videoPlayerService.pauseIfNeeded()
                previewSecondsPublisher.send(value)
            case .dragEnded(let value):
                isDragging = false
                seekedTime = value
                trackVideoScrubbingEnded(value: value)
                videoPlayerService.seek(seconds: value, completionHandler: { [weak self] _ in
                    self?.seekedTime = nil
                })
            }
        }
        
        func trackVideoScrubbingEnded(value: TimeInterval) {
            var properties = show.baseAnalyticsProperties
            properties[.scrub_value] = value
            analyticsService.trackActionEvent(.show_scrub, properties: properties)
        }
    }
}

enum InteractivePlayerEventType {
    
    case dragStarted
    case dragInProgress(TimeInterval)
    case dragEnded(TimeInterval)
}

struct SliderView: UIViewRepresentable {
    
    let currentValue: TimeInterval
    let maximumValue: TimeInterval
    var minTrackColor: UIColor = .orangish
    
    var interactiveEventHandler: ((InteractivePlayerEventType) -> Void)?
    var onCustomizeSlider: ((UISlider) -> Void)?
    
    func makeUIView(context: Context) -> UISlider {
        let slider = CocoaSlider(sliderHeight: 6)
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = .battleshipGray.withAlphaComponent(0.55)
        slider.value = Float(currentValue)
        slider.maximumValue = Float(maximumValue)
        slider.setThumbImage(UIImage(named: "small_knob_icon"), for: .normal)
        slider.setThumbImage(UIImage(named: "knob_icon"), for: .highlighted)
        slider.isContinuous = true
        
        slider.addTarget(
            context.coordinator,
            action: #selector(context.coordinator.handleSliderInteraction(_:event:)),
            for: .valueChanged
        )
        
        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.setValue(Float(currentValue), animated: true)
        uiView.maximumValue = Float(maximumValue)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        
        let slider: SliderView
        
        init(_ slider: SliderView) {
            self.slider = slider
        }
        
        @objc func handleSliderInteraction(_ sender: UISlider, event: UIEvent) {
            guard let touchEvent = event.allTouches?.first else {
                return
            }
            let draggedValue = TimeInterval(sender.value)
            switch touchEvent.phase {
            case .began:
                slider.interactiveEventHandler?(.dragStarted)
            case .moved:
                slider.interactiveEventHandler?(.dragInProgress(draggedValue))
            case .ended:
                slider.interactiveEventHandler?(.dragEnded(draggedValue))
            default: break
            }
        }
    }
}

fileprivate class CocoaSlider: UISlider {
    
    let sliderHeight: CGFloat
    
    init(sliderHeight: CGFloat) {
        self.sliderHeight = sliderHeight
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds_ = self.bounds
        bounds_ = bounds.insetBy(dx: -20, dy: -10)
        return bounds_.contains(point)
    }
}

#if DEBUG
struct InteractiveSliderView_Previews: PreviewProvider {
    
    static var previews: some View {
        InteractiveSliderPreview()
    }
    
    struct InteractiveSliderPreview: View {
        
        @State var currentValue: TimeInterval = 10
        
        var body: some View {
            SliderView(currentValue: currentValue, maximumValue: 100, interactiveEventHandler: { event in
                switch event {
                case .dragEnded(let value):
                    currentValue = value
                default: break
                }
            })
            .padding()
        }
    }
}
#endif
