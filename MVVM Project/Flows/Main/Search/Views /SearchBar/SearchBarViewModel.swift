//
//  SearchBarViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.10.2023.
//

import Foundation
import Combine

class SearchBarViewModel: ObservableObject {
    
    @Published var text: String = ""
    @Published var cancelButtonVisible: Bool = false
    @Published var displayActivityIndicator: Bool = false
    
    var isSearchedState: Bool {
        return !isInputFieldActivePublisher.value && text != ""
    }
    
    let onClear = PassthroughSubject<Void, Never>()
    let onCancel = PassthroughSubject<Void, Never>()
    let isInputFieldActivePublisher = CurrentValueSubject<Bool, Never>(true)
    
    func cancelAction() {
        text = ""
        onCancel.send()
        resignFirstResponder()
        cancelButtonVisible = false
    }
    
    func clearButtonAction() {
        text = ""
        onClear.send()
        cancelButtonVisible = true
    }
}
