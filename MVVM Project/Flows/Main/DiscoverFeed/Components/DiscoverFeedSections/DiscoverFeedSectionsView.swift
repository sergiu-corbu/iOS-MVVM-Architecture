//
//  DiscoverFeedSectionsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.11.2023.
//

import SwiftUI

enum DiscoverProductsFeedType: String, CaseIterable {
    case justDropped
    case topDeals
    case hotDeals
    
    var title: String {
        switch self {
        case .justDropped: Strings.Discover.justDropped
        case .topDeals: Strings.Discover.topDeals
        case .hotDeals: Strings.Discover.hotDeals
        }
    }
}

enum DiscoverShowsFeedType: String, CaseIterable {
    case mostPopular
    case justHappened
    
    var title: String {
        switch self {
        case .mostPopular: Strings.Discover.mostPopular
        case .justHappened: Strings.Discover.justHappened
        }
    }
}

struct DiscoverFeedSectionsView: View {
    
    @ObservedObject var viewModel: DiscoverFeedSectionsViewModel
    var spacing: CGFloat = 16
    
    //Internal
    @State private var currentDiscoverSectionType: DiscoverFeedSectionType = .productsAndBrands
    @State private var viewportSize: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2 * spacing) {
            ScrollViewReader { scrollProxy in
                LazyVStack(alignment: .leading, spacing: 2 * spacing, pinnedViews: .sectionHeaders) {
                    contentView(scrollProxy: scrollProxy)
                }
            }
            HotDealsFeedView(
                viewModel: viewModel.hotDealsViewModel,
                viewportSize: viewportSize,
                spacing: spacing,
                onSelectProduct: { product in
                    viewModel.actionHandler.onSelectProduct(product)
                }
            )
        }
    }
    
    private func contentView(scrollProxy: ScrollViewProxy) -> some View {
        Section(content: {
            sectionTypeChangeableView(content: productsSectionView(for: .topDeals), targetSection: .productsAndBrands)
            topBrandsSectionView
            productsSectionView(for: .justDropped)
            sectionTypeChangeableView(content: showsFeedSectionView(for: .justHappened), targetSection: .showsAndCreators)
            shopByCreatorSectionView
            showsFeedSectionView(for: .mostPopular)
            applyView
        }, header: {
            DiscoverFeedSectionHeaderView(
                currentDiscoverSection: $currentDiscoverSectionType,
                onSectionSelected: {
                    scrollProxy.scrollTo(
                        currentDiscoverSectionType.id, anchor: .center,
                        animation: .smooth.delay(0.1)
                    )
                }
            )
            .padding(.bottom, 8)
            .background(Color.cappuccino.padding(.top, -spacing))
        })
        .setViewportLayoutSize(
            Binding(get: {
                return viewportSize
            }, set: { newValue in //we only need to update the width
                if viewportSize.width == .zero {
                    viewportSize = newValue
                }
            })
        )
    }
    
    //Product Section
    private func productsSectionView(for section: DiscoverProductsFeedType, scrollIdentifier: Int? = nil) -> some View {
        let products = viewModel.productSections[section]
        let showPlaceholder = products?.isEmpty == true
        let viewportSize = CGSize(width: viewportSize.width - 2 * spacing, height: .zero)
        lazy var productsContent = PinterestGridView(gridItems: products ?? [], viewportSize: viewportSize, configuration: .triple,
            cellContent: { product in
                Button(action: {
                    viewModel.actionHandler.onSelectProduct(product)
                }, label: {
                    DiscoverFeedProductView(product: product)
                })
                .buttonStyle(.plain)
            }
        ).padding(.horizontal, spacing)

        return DiscoverFeedContainerSectionView(
            title: section.title,
            expandActionEnabled: !showPlaceholder,
            onExpandSection: {
                viewModel.actionHandler.onSelectExpandedSectionContent(.products(section))
            }, content: {
                if showPlaceholder {
                    DiscoverProductsPlaceholderView(viewportSize: viewportSize)
                        .padding(.horizontal, spacing)
                } else {
                    productsContent
                }
            }
        )
    }
    
    //Top Brands
    private var topBrandsSectionView: some View {
        let showPlaceholder = viewModel.topBrands?.count == nil
        return DiscoverFeedContainerSectionView(
            title: Strings.Discover.topBrands,
            expandActionEnabled: !showPlaceholder,
            onExpandSection: {
                viewModel.actionHandler.onSelectExpandedSectionContent(.brands)
            }, content: {
                if showPlaceholder {
                    HStack(spacing: spacing / 2) {
                        Image(.brandPlaceholder)
                        Image(.brandPlaceholder)
                    }
                    .padding(.horizontal, spacing)
                } else {
                    CollectionView(
                        dataSource: viewModel.topBrands ?? [],
                        collectionViewLayout: viewModel.brandsFlowLayout(availableSize: viewportSize, spacing: spacing)
                    ) { brand in
                        Button {
                            viewModel.actionHandler.onSelectBrand(brand)
                        } label: {
                            BrandHeaderView(brandName: brand.name, pictureURL: brand.logoPictureURL)
                                .padding(spacing)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.beige, in: RoundedRectangle(cornerRadius: 6))
                        }.buttonStyle(.plain)
                    }
                    .frame(height: 232)
                    .padding(.horizontal, spacing)
                }
            }
        ).animation(.smooth, value: viewModel.topBrands)
    }
    
    private func showsFeedSectionView(for sectionType: DiscoverShowsFeedType, scrollIdentifier: Int? = nil) -> some View {
        let showsListView = ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 8) {
                let shows = viewModel.showSections[sectionType] ?? []
                ForEach(shows) { show in
                    Button {
                        viewModel.actionHandler.onSelectShow(
                            ShowsFeedDiscoverSection(shows: shows, selectedShowID: show.id, feedType: sectionType)
                        )
                    } label: {
                        DiscoverShowCard(show: show)
                    }.buttonStyle(.scaled)
                }
            }
            .padding(.horizontal, spacing)
            .animation(.smooth, value: viewModel.topCreators)
        }
        
        return DiscoverFeedContainerSectionView(
            title: sectionType.title,
            expandActionEnabled: viewModel.showSections[sectionType]?.isEmpty == false,
            onExpandSection: {
                viewModel.actionHandler.onSelectExpandedSectionContent(.shows(sectionType))
            }, content: {
                showsListView
            }
        )
    }
    
    //Shop by Creator
    private var shopByCreatorSectionView: some View {
        let showPlaceholder = viewModel.topCreators?.isEmpty == true
        lazy var creatorsListView = ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(viewModel.topCreators ?? []) { creator in
                    Button {
                        viewModel.actionHandler.onSelectCreator(creator)
                    } label: {
                        TopCreatorThumbnailView(creator: creator)
                    } .buttonStyle(.scaled)
                }
            }
            .padding(.horizontal, spacing)
            .animation(.smooth, value: viewModel.topCreators)
        }
        
        return DiscoverFeedContainerSectionView(
            title: Strings.Discover.shopByCreator,
            expandActionEnabled: !showPlaceholder,
            onExpandSection: {
                viewModel.actionHandler.onSelectExpandedSectionContent(.creators)
            }, content: {
                if showPlaceholder {
                    HStack {
                        ForEach(0..<3, id: \.self) { _ in
                            Image(.creatorPlaceholder)
                        }
                    }
                    .padding(.horizontal, spacing)
                } else {
                    creatorsListView
                }
            }
        )
    }
    
    //Apply
    private var applyView: some View {
        ApplyAsCreatorView(
            currentUserSubject: viewModel.currentUserPublisher,
            onApply: viewModel.actionHandler.onApplyAsCreator,
            onDismiss: {
                ToastDisplay.showInformativeToast(
                    title: Strings.Alerts.messageRemoved,
                    message: Strings.Alerts.goLiveMessage,
                    animated: true
                )
            }
        )
    }
}

fileprivate extension DiscoverFeedSectionsView {
    
    func sectionTypeChangeableView(content: some View, targetSection: DiscoverFeedSectionType) -> some View {
        content.id(targetSection.id)
    }
}

#if DEBUG
#Preview {
    ScrollView {
        DiscoverFeedSectionsView(viewModel: .preview)
    }
    .background(Color.cappuccino)
}
#endif
