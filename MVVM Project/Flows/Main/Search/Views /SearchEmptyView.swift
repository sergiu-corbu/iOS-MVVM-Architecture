//
//  SearchEmptyView.swift
//  MVVM Project
//
//  Created by Doru Cojocaru on 24.07.2023.
//

import SwiftUI

struct SearchEmptyView: View {

    let state: State

    var body: some View {
        VStack(spacing: 8) {
            Image(.packageThinIcon)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.ebony)
                .frame(width: 56, height: 56)

            Text(state.text)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.ebony)
                .multilineTextAlignment(.center)
        }
    }
}

extension SearchEmptyView {
    enum State {
        case idle, noResults

        var text: String {
            switch self {
            case .idle:
                return Strings.Search.description
            case .noResults:
                return Strings.ContentCreation.noResults
            }
        }
    }
}

#if DEBUG
struct SearchEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        SearchEmptyView(state: .idle)
    }
}
#endif
