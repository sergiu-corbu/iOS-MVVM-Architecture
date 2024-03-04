//
//  StatefulPreviewWrapper.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.07.2023.
//

import SwiftUI

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content
    
    var body: some View {
        content($value)
    }
    
    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
}

struct ViewModelPreviewWrapper<ViewModel: ObservableObject, Content: View>: View {
    @StateObject var viewModel: ViewModel
    var content: (ViewModel) -> Content
    
    var body: some View {
        content(viewModel)
    }
    
    init(_ viewModel: ViewModel, content: @escaping (ViewModel) -> Content) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.content = content
    }
}
