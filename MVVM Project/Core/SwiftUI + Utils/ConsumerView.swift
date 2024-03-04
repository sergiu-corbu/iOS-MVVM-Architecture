//
//  ConsumerView.swift
//  Bond
//
//  Created by Sergiu Corbu on 13.01.2023.
//

import Foundation
import Combine
import SwiftUI

struct Consumer<Content: View, P: Publisher>: View {
    
    @ObservedObject private var viewModel: ConsumerViewModel<P>
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
    }
    
    init(of publisher: P, @ViewBuilder content: @escaping () -> Content) {
        self.viewModel = .init(publisher)
        self.content = content
    }
    
    init<O: ObservableObject>(of observable: O, @ViewBuilder content: @escaping () -> Content) where P == O.ObjectWillChangePublisher {
        self.viewModel =  .init(observable.objectWillChange)
        self.content = content
    }
}

private class ConsumerViewModel<P: Publisher>: ObservableObject {
    
    private var disposeBag = [AnyCancellable]()
    
    init(_ publisher: P) {
        publisher.sink { _ in
        } receiveValue: { [weak self] newValue in
            self?.objectWillChange.send()
        }.store(in: &disposeBag)
    }
}
