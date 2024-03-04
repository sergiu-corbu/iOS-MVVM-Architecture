//
//  Gesture+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.12.2022.
//

import SwiftUI

extension View {
    
    /// This method prevents a gesture to interfer with `system gestures`, having a lower priority.
    /// - Note: Having a vertical drag gesture on a view that is a child view of a `ScrollView`, in order the two gestures to be independent, this method must be used
    func systemScrollIgnoringGesture<G: Gesture>(_ gesture: G) -> some View {
        self.simultaneousGesture(TapGesture().exclusively(before: gesture))
    }
}
