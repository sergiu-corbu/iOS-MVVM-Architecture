//
//  AddressSuggestionViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.12.2023.
//

import Foundation
import Combine
import MapKit

class AddressSuggestionViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    //MARK: - Properties
    @Published private(set) var locationResults : [MKLocalSearchCompletion] = []
    @Published var searchQuery = ""
    @Published var isLoading = false
    @Published var error: Error?
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchRequest: MKLocalSearch?
    
    let onAddressSelected = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?
    
    //MARK: - Actions
    let onFinishedSearch: (CustomerAddress) -> Void
    
    init(onFinishedSearch: @escaping (CustomerAddress) -> Void) {
        self.onFinishedSearch = onFinishedSearch
        super.init()
        setup()
    }
    
    deinit {
        cancellable?.cancel()
        searchRequest?.cancel()
    }
    
    //MARK: - LocationSearch Setup
    private func setup() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .query]
        
        cancellable = $searchQuery
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .dropFirst()
            .removeDuplicates()
            .compactMap { $0 }
            .sink(receiveValue: { [weak self] query in
                if query.isEmpty {
                    return
                }
                self?.isLoading = true
                self?.searchCompleter.queryFragment = query
            })
    }
    
    func handleLocationSuggestionSelected(_ location: MKLocalSearchCompletion) {
        isLoading = true
        let request = MKLocalSearch.Request(completion: location)
        request.naturalLanguageQuery = location.title + " " + location.subtitle
        request.resultTypes = .address
        
        self.searchRequest = MKLocalSearch(request: request)
        searchRequest?.start { [weak self] searchResponse, error in
            defer {
                self?.isLoading = false
            }
            
            if let error {
                self?.error = error
                return
            }
            if let requestedPlacemark = searchResponse?.mapItems.first?.placemark,
               let address = CustomerAddress(placemark: requestedPlacemark) {
                self?.onAddressSelected.send()
                self?.onFinishedSearch(address)
            } else {
                self?.error = InvalidCustomerAddressError()
            }
        }
    }
    
    func clearQueryAndSuggestions() {
        searchQuery = ""
        locationResults = []
    }
    
    //MARK: - LocalSearch Delegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        isLoading = false
        locationResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        isLoading = false
        self.error = error
    }
}
