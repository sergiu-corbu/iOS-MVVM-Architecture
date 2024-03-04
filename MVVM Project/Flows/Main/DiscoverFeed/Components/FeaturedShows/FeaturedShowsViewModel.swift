//
//  FeaturedShowsViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.02.2023.
//

import Foundation
import Combine
import UIKit

struct CompositionalLayoutHandlerContext {
    let contentOffset: CGPoint
    let spacing: CGFloat
    let itemWidth: CGFloat
    
    func computeNewIndexWhenScrolling(at index: Int) -> Int {
        let spacing = max(0, spacing * CGFloat(index))
        let floatIndex = (contentOffset.x - spacing) / itemWidth
        return Int(round(floatIndex))
    }
}

class FeaturedShowsViewModel<DataStore>: ObservableObject where DataStore: ShowsDataStoreProtocol {
    
    //MARK: - Properties
    let showsDataStore: DataStore
    private(set) var videoInteractorsMap: [String : VideoInteractor] = [:]
    private weak var collectionView: UICollectionView?
    private var isDataStoreReloadEnabled = true
    private var currentShowIndex: Int = 0
    
    //MARK: - Getters
    var currentDisplayedShow: Show? {
        return showsDataStore.shows[safe: currentShowIndex]
    }
    var currentVideoInteractor: VideoInteractor? {
        return getVideoInteractor(at: currentShowIndex)
    }
    var shouldDisplayPlaceholderView: Bool {
        showsDataStore.loadingSourceType == .new && showsDataStore.shows.isEmpty
    }
    
    var showsCompositionalLayout: UICollectionViewLayout {
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.6),
            heightDimension: .fractionalHeight(1)
        )
        let layoutSectionHandler: (NSCollectionLayoutSection) -> Void = { layoutSection in
            layoutSection.visibleItemsInvalidationHandler = { [weak self] visibleItems, scrollOffset, env in
                guard let itemWidth = visibleItems.first?.bounds.width else { return }
                let layoutContext = CompositionalLayoutHandlerContext(contentOffset: scrollOffset, spacing: layoutSection.interGroupSpacing, itemWidth: itemWidth)
                self?.contentOffsetPublisher.send(layoutContext)
            }
        }
        
        return UICollectionViewLayout.horizontalCompositionalLayout(
            groupLayoutSize: groupSize,
            onCustomizeLayoutSection: layoutSectionHandler
        )
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Publishers
    let currentUserPublisher: AnyPublisher<User?, Never>?
    let showsSectionClosedSubject = PassthroughSubject<Show, Never>()
    let currentShowChangedPublisher = PassthroughSubject<Show, Never>()
    private let contentOffsetPublisher = PassthroughSubject<CompositionalLayoutHandlerContext, Never>()
    
    //MARK: - Actions
    let actionHandler: FeaturedShowsActionHandler
    var onErrorReceived: ((Error) -> Void)?
    
    //MARK: - Services
    private let analyticsService: AnalyticsServiceProtocol
    
    init(showsDataStore: DataStore, analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
         actionHandler: FeaturedShowsActionHandler, currentUserPublisher: AnyPublisher<User?, Never>? = nil) {
        
        self.showsDataStore = showsDataStore
        self.actionHandler = actionHandler
        self.currentUserPublisher = currentUserPublisher
        self.analyticsService = analyticsService
        
        setupBindings()
        loadInitialContent()
    }
    
    //MARK: - Setup
    private func setupBindings() {
        showsDataStore.objectWillChange
            .sink(receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            })
            .store(in: &cancellables)
        showsSectionClosedSubject.receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                self?.isDataStoreReloadEnabled = true
                self?.scrollTo(show: show, animated: true)
            }
            .store(in: &cancellables)
        contentOffsetPublisher.receive(on: DispatchQueue.main)
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { [weak self] layoutContext in
                self?.handleContentOffsetChanged(layoutContext: layoutContext)
            }
            .store(in: &cancellables)
        currentShowChangedPublisher.receive(on: DispatchQueue.main)
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.currentVideoInteractor?.play()
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialContent() {
        Task(priority: .userInitiated) { @MainActor [weak self] in
            do {
                try await self?.showsDataStore.loadInitialContent()
                if let show = self?.currentDisplayedShow {
                    self?.currentShowChangedPublisher.send(show)
                }
            } catch {
                self?.onErrorReceived?(error)
            }
        }
    }
    
    func reloadContent() {
        guard isDataStoreReloadEnabled else {
            return
        }
        loadInitialContent()
    }
    
    //MARK: - View Lifecycle
    func onViewAppeared() {
        analyticsService.trackScreenEvent(.featured, properties: nil)
        currentVideoInteractor?.play()
    }
    
    func onViewDisappeared() {
        currentVideoInteractor?.pause()
    }
    
    //MARK: - Actions
    func handleLoadMoreShows(_ showID: String?) {
        Task(priority: .userInitiated) { @MainActor [weak self] in
            do {
                try await self?.showsDataStore.loadMoreShowsIfNeeded(showID)
            } catch {
                self?.onErrorReceived?(error)
            }
        }
    }
    
    func handleShowSelection(show: Show) {
        isDataStoreReloadEnabled = false
        actionHandler.onSelectShow(show, showsSectionClosedSubject)
    }
    
    //MARK: - CollectionView configuration
    func configureCollectionView(_ collectionView: UICollectionView) {
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        self.collectionView = collectionView
    }
    
    private func handleContentOffsetChanged(layoutContext: CompositionalLayoutHandlerContext) {
        guard layoutContext.contentOffset.x >= .zero else {
            return
        }
        let currentIndex = layoutContext.computeNewIndexWhenScrolling(at: currentShowIndex)
        if currentIndex != self.currentShowIndex {
            currentVideoInteractor?.pause()
            DispatchQueue.main.async { [weak self] in
                self?.currentShowIndex = currentIndex
                if let show = self?.currentDisplayedShow {
                    self?.currentShowChangedPublisher.send(show)
                }
            }
        }
    }
    
    //MARK: - Scrolling
    func scrollToFirstShow(animated: Bool) {
        collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
    func scrollTo(show: Show, animated: Bool) {
        guard show.isFeatured else {
            return
        }
        if let showIndex = showsDataStore.shows.firstIndex(where: { $0.id == show.id }) {
            collectionView?.scrollToItem(at: IndexPath(item: showIndex, section: 0), at: .centeredHorizontally, animated: animated)
        }
    }
    
    //MARK: - Video Interactors Functionality
    func createVideoInteractor(for showID: String) -> VideoInteractor {
        let videoInteractor = VideoInteractor()
        videoInteractorsMap[showID] = videoInteractor
        return videoInteractor
    }
    
    private func pauseAllVideoStreams() {
        videoInteractorsMap.values.forEach({ $0.pause() })
    }
    
    private func clearAllVideoInteractors() {
        pauseAllVideoStreams()
        videoInteractorsMap = [:]
    }
    
    private func getVideoInteractor(at currentIndex: Int) -> VideoInteractor? {
        guard let currentShowID = showsDataStore.shows[safe: currentIndex]?.id else {
            return nil
        }
        return videoInteractorsMap[currentShowID]
    }
}

struct FeaturedShowsActionHandler {
    let onSelectShow: (Show, PassthroughSubject<Show, Never>?) -> Void
    let onSelectCreator: (Creator) -> Void
    let onSelectBrand: (Brand) -> Void
    let onSelectProduct: (ProductSelectableDTO) -> Void
}

#if DEBUG
extension FeaturedShowsView {
    static let mockedViewModel = FeaturedShowsViewModel(
        showsDataStore: PaginatedShowsDataStore(showService: MockShowService()), analyticsService: MockAnalyticsService(),
        actionHandler: .init(onSelectShow: {(_, _) in}, onSelectCreator: {_ in}, onSelectBrand: {_ in}, onSelectProduct: {_ in})
    )
}
#endif
