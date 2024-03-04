//
//  Search+Analytics.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 15.08.2023.
//

import Foundation

extension SearchViewModel {
    
    func trackSearchTabSelection() {
        analyticsService.trackScreenEvent(.search, properties: nil)
    }
    
    func trackSearchAction() {
        let properties: AnalyticsProperties = [.search_text : searchBarViewModel.text, .search_filter: selectedSearchTag.title]
        analyticsService.trackActionEvent(.search_action, properties: properties)
    }
    
    func trackSearchFieldSelectionAction() {
        analyticsService.trackActionEvent(.search_field_selection, properties: nil)
    }
    
    func trackSearchFilterSelection(_ searchTag: SearchTag) {
        analyticsService.trackActionEvent(.search_filter_selection, properties: [.search_filter : searchTag.title])
    }
    
    func trackSearchResultSelection(_ selectionProperties: AnalyticsProperties) {
        var properties = AnalyticsProperties()
        properties[.search_result] = Dictionary(uniqueKeysWithValues: selectionProperties.map { ($0.key.rawValue, $0.value) })
        analyticsService.trackActionEvent(.search_result_selection, properties: properties)
    }
}
