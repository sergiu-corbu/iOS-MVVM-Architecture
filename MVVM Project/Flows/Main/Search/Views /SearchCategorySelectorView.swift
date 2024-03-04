//
//  SearchCategorySelector.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 19.07.2023.
//

import SwiftUI

enum SearchTag: String, Hashable, Identifiable, CaseIterable {
    case all, shows, creators, products, brands
    
    var title: String {
        return rawValue.capitalized
    }
    
    var id: String { return rawValue }
}

struct SearchCategoriesSelectorView: View {

    @Binding var selectedSearchTag: SearchTag
    let searchTags: [SearchTag]
    var padding: CGFloat = 16
    var spacing: CGFloat = 8
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                Color.clear.frame(width: padding - spacing)
                ForEach(searchTags) { searchTag in
                    cell(searchTag: searchTag)
                }
                Color.clear.frame(width: padding - spacing)
            }
            .animation(.linear(duration: 0.2), value: selectedSearchTag)
        }
        .frame(height: 40)
    }
    
    private func cell(searchTag: SearchTag) -> some View {
        let isSelected = searchTag == selectedSearchTag
        return Button {
            if isSelected {
                return
            }
            selectedSearchTag = searchTag
        } label: {
            Text(searchTag.title)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(isSelected ? .white : .brownJet)            
                .padding(10)
                .background(isSelected ? Color.darkGreen : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .background {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.silver, lineWidth: 1)
                }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Search_CategoriesSelector_Previews: PreviewProvider {
          
    static var previews: some View {
        StatefulPreviewWrapper(SearchTag.all) { selection in
            SearchCategoriesSelectorView(selectedSearchTag: selection, searchTags: SearchTag.allCases)
        }
    }
}
