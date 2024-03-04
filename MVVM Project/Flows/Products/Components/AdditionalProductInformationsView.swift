//
//  AdditionalProductInformationsView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 20.09.2023.
//

import SwiftUI

struct AdditionalProductInformationsView: View {
    
    enum AdditionalInformationType: Int, CaseIterable {
        case sizeGuides, returnPolicy

        var title: String {
            switch self {
            case .sizeGuides: return Strings.ProductsDetail.sizeGuides
            case .returnPolicy: return Strings.ProductsDetail.returnPolicy
            }
        }
    }
    
    let sizeGuides: String?
    let returnPolicy: String?
    
    //Internal
    @State private var expandedTypesMap = Dictionary(
        uniqueKeysWithValues: AdditionalInformationType.allCases.map { ($0, false) }
    )
    private var isContentAvailable: Bool {
        return sizeGuides != nil || returnPolicy != nil
    }
    
    var body: some View {
        let content = VStack(alignment: .leading, spacing: 16) {
            ForEach(AdditionalInformationType.allCases, id: \.rawValue) { type in
                additionalInformationView(type: type)
            }
        }
        .animation(.easeInOut, value: expandedTypesMap)
        
        if isContentAvailable {
            content
        }
    }
    
    @ViewBuilder
    private func additionalInformationView(type: AdditionalInformationType) -> some View {
        let isExpanded = expandedTypesMap[type] == true
        if let additionalInformation = getAdditionalInformation(for: type) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    Text(type.title)
                        .font(kernedFont: .Main.p1MediumKerned)
                        .foregroundColor(.jet)
                    Spacer()
                    Button {
                        expandedTypesMap[type] = !isExpanded
                    } label: {
                        Image(systemName: isExpanded ? "minus" : "plus")
                            .renderingMode(.template)
                            .foregroundColor(.ebony)
                    }
                    .buttonStyle(.plain)
                }
                
                if isExpanded {
                    Text(additionalInformation)
                        .font(kernedFont: .Secondary.p1RegularKerned)
                        .foregroundColor(.ebony)
                        .transition(.opacity)
                }
            }
        }
    }
    
    private func getAdditionalInformation(for type: AdditionalInformationType) -> String? {
        switch type {
        case .returnPolicy: return returnPolicy
        case .sizeGuides: return sizeGuides
        }
    }
}

extension AdditionalProductInformationsView {
    
    init(brand: Brand) {
        self.sizeGuides = brand.sizeGuides
        self.returnPolicy = brand.returnPolicy
    }
}

#if DEBUG
struct AdditionalProductInformationsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AdditionalProductInformationsView(sizeGuides: "Some random size and fit guides", returnPolicy: "Random return policy for this brand")
            AdditionalProductInformationsView(sizeGuides: nil, returnPolicy: nil)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
