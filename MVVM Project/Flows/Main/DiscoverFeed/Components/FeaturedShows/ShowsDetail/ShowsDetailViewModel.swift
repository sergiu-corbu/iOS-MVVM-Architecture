//
//  ShowsDetailViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 11.04.2023.
//

import Foundation
import Combine
import UIKit

class ShowsDetailViewModel<DataStore: ShowsDataStoreProtocol>: NSObject, ObservableObject, UICollectionViewDelegate {
    
    @Published private(set) var shouldShowTooltip: Bool = true
    @Published var error: Error?
    @UserDefault(key: UserSession.StorageKeys.didShowTooltip, defaultValue: false)
    private(set) var didShowTooltip: Bool
    
    //MARK: Properties
    private(set) var currentIndex: Int {
        didSet {
            if let id = shows[safe: currentIndex]?.id {
                currentShowIdPublisher.send(id)
            }
        }
    }
    let currentShowIdPublisher = PassthroughSubject<String, Never>()
    private var currentUserID: String?
    private(set) var videoInteractorsMap: [String : VideoInteractor] = [:]
    
    var shows: [Show] {
        return showsDataStore.shows
    }
    var isLoadingMore: Bool {
        return showsDataStore.loadingSourceType == .paged
    }
    var currentVideoInteractor: VideoInteractor? {
        return getVideoInteractor(at: currentIndex)
    }
    private(set) var tooltipViewModel = ShowsDetailTooltipViewModel()
    
    private weak var collectionView: UICollectionView?
    private var initialSelectedShowID: String?
    private lazy var cellSize: CGSize? = {
        return (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize
    }()
    
    //MARK: Services
    let showsDataStore: DataStore
    let showVideoStreamBuilder: ShowVideoStreamBuilder
//    lazy var showsFeedSwipeHandler: ShowsFeedSwipeHandler = {
//        return ShowsFeedSwipeHandler(
//            currentUserPublisher: showVideoStreamBuilder.userRepository.currentUserSubject,
//            currentShowSelectionPublisher: currentShowIdPublisher
//        )
//    }()
    
    let analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init(selectedShowID: String, showsDataStore: DataStore, showVideoStreamBuilder: ShowVideoStreamBuilder) {
        self.showsDataStore = showsDataStore
        self.showVideoStreamBuilder = showVideoStreamBuilder
        self.currentIndex = showsDataStore.shows.firstIndex(where: { $0.id == selectedShowID  }) ?? 0
        self.initialSelectedShowID = selectedShowID
        super.init()
        
        self.shouldShowTooltip = !didShowTooltip
        currentShowIdPublisher.send(shows[currentIndex].id)
        setupObservers()
    }
    
    // MARK: - Observers
    func setupObservers() {
        showsDataStore.objectWillChange.sink { [weak self] _ in
            self?.clearAllVideoInteractors()
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
        showVideoStreamBuilder.userRepository.currentUserSubject.sink { [weak self] user in
            self?.updateCurrentCreatorID(user)
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
    
    //MARK: - CollectionView Setup
    func setupCollectionView(_ collectionView: UICollectionView) {
        if self.collectionView != nil {
            return
        }
        
        self.collectionView = collectionView
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.tintColor = .darkGreen
        collectionView.refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.delegate = self
    }
    
    //MARK: - ScrollDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleScrollOffsetChanged(newOffset: scrollView.contentOffset, itemHeight: cellSize?.height ?? scrollView.bounds.height)
    }
    
    @objc private func reloadData() {
        let endRefreshingAnimationDuration: TimeInterval = 0.5
        Task(priority: .userInitiated) { @MainActor in
            do {
                currentVideoInteractor?.pause()
                try await showsDataStore.refreshContent(delay: endRefreshingAnimationDuration)
            } catch {
                self.error = error
            }
            collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    func scrollToSelectedShow() {
        guard initialSelectedShowID != nil else {
             return
        }
        
        trackShowViewStartEvent()
        collectionView?.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .top, animated: false)
        playSelectedVideoStream()
        initialSelectedShowID = nil
    }
    
    private func handleScrollOffsetChanged(newOffset: CGPoint, itemHeight: CGFloat) {
        guard initialSelectedShowID == nil else {
            return
        }
        
        let calculatedFloatIndex = newOffset.y / itemHeight
        let calculatedIntIndex = Int(calculatedFloatIndex)
        let reminderValue = (floor((calculatedFloatIndex - CGFloat(calculatedIntIndex)) * 10) / 10.0)
        
        guard reminderValue == .zero, calculatedIntIndex != currentIndex else {
            return
        }
        
        let oldIndex = currentIndex
        trackShowViewEndEvent()
        currentIndex = calculatedIntIndex
        trackShowViewStartEvent()
        updateVideoInteractors(oldIndex: oldIndex)
        
        if calculatedIntIndex >= shows.count - 1, !isLoadingMore {
            Task(priority: .userInitiated) { @MainActor [weak self] in
                do {
                    try await self?.showsDataStore.loadMoreShowsIfNeeded(self?.shows[safe: calculatedIntIndex]?.id)
                } catch {
                    self?.error = error
                }
            }
        }
    }
    
    //MARK: - Video interactor functionality
    func createVideoInteractor(for showID: String) -> VideoInteractor {
        let videoInteractor = VideoInteractor()
        videoInteractorsMap[showID] = videoInteractor
        return videoInteractor
    }
    
    func playSelectedVideoStream() {
        DispatchQueue.main.asyncAfter(seconds: 0.1) {
            self.currentVideoInteractor?.play()
        }
    }
    
    private func pauseAllVideoStreams() {
        videoInteractorsMap.values.forEach({ $0.pause() })
    }
    
    private func clearAllVideoInteractors() {
        pauseAllVideoStreams()
        videoInteractorsMap = [:]
    }
    
    private func updateVideoInteractors(oldIndex: Int) {
        let previousVideoInteractor = getVideoInteractor(at: oldIndex)
        previousVideoInteractor?.pause()
        currentVideoInteractor?.play()
    }
    
    private func getVideoInteractor(at currentIndex: Int) -> VideoInteractor? {
        guard let currentShowID = shows[safe: currentIndex]?.id else {
            return nil
        }
        return videoInteractorsMap[currentShowID]
    }
    
    private func updateCurrentCreatorID(_ user: User?) {
        guard user?.role == .creator else {
            currentUserID = nil
            return
        }
        self.currentUserID = user?.id
    }

    //MARK: - Tooltip
    func setupTooltipViewModel() {
        tooltipViewModel.setupBindings(to: collectionView)
    }
    
    @MainActor
    func setupTooltip() async {
        guard shouldShowTooltip else {
            return
        }
        setupTooltipViewModel()
        await Task.sleep(seconds: 0.4)
        tooltipViewModel.startAnimating()
    }
    
    func handleTooltipGestureEnded() {
        shouldShowTooltip = false
        didShowTooltip = true
        tooltipViewModel.stopAnimating()
    }
}

//MARK: - Analytics
extension ShowsDetailViewModel {
    
    func trackShowViewEndEvent() {
        analyticsService.trackActionEvent(.show_view_end, properties: showViewEventProperties)
    }
    
    func trackShowViewStartEvent() {
        analyticsService.trackActionEvent(.show_view_start, properties: showViewEventProperties)
    }
    
    private var showViewEventProperties: AnalyticsProperties? {
        guard let currentShow = shows[safe: currentIndex] else {
            return nil
        }
        var properties = currentShow.baseAnalyticsProperties
        
        if let products = currentShow.featuredProducts {
            properties[.products] = products.map { product in
                Dictionary(uniqueKeysWithValues: product.baseAnalyticsProperties.map { ($0.key.rawValue, $0.value)} )
            }
        }
        
        return properties
    }
}
