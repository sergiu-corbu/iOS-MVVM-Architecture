//
//  FilterButtonView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 30.08.2023.
//

import SwiftUI
import Combine

struct FilterButtonView: View {
    
    let action: () -> Void
    let filtersCountPublisher: CurrentValueSubject<Int, Never>
    
    //Internal
    @State private var filtersCount: Int = 0
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(Strings.Buttons.filter.uppercased() + (filtersCount > 0 ? " (\(filtersCount))" : ""))
                .font(kernedFont: .Secondary.p3BoldExtraKerned)
                .foregroundColor(.orangish)
                .monospacedDigit()
        }
        .buttonStyle(.plain)
        .onReceive(filtersCountPublisher) { filtersCount in
            self.filtersCount = filtersCount
        }
    }
}

#if DEBUG
struct FilterButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let publisher = CurrentValueSubject<Int, Never>(0)
        FilterButtonView(action: {publisher.send(publisher.value + 1)}, filtersCountPublisher: publisher)
    }
}
#endif
