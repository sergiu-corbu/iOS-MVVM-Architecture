//
//  SearchResultsContainerView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.07.2023.
//

import SwiftUI

struct SearchResultsContainerView: View {

    @ObservedObject var viewModel: SearchResultsContainerViewModel

    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(viewModel.configs) { config in
                Button {
                    viewModel.onSelectItem.send(config)
                } label: {
                    SearchResultItemView(config: config)
                }
                .buttonStyle(.plain)
                .task(priority: .utility) {
                    await viewModel.loadMoreIfNeeded(for: config.id)
                }
            }
        }
        .overlayLoadingIndicator(viewModel.loadingSourceType != nil, scale: 1, alignment: viewModel.loadingSourceType == .paged ? .bottom : .top)
    }
}

#if DEBUG
struct SearchResultsContainerView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsContainerView(viewModel: .init(searchService: MockSearchService()))
    }
}
#endif
