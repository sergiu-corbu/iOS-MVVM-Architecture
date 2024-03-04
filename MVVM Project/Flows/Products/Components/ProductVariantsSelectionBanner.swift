//
//  ProductVariantsSelectionBanner.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.09.2023.
//

import SwiftUI
import Combine

extension View {
    
    func productVariantsSelectionBanner(isPresented: Bool) -> some View {
        return self.modifier(ProductVariantsSelectionBannerViewModifier(showSelectionBanner: isPresented))
    }
    
    func scrollableVariantsSectionContainer(scrollPublisher: AnyPublisher<Bool, Never>) -> some View {
        ScrollViewReader { scrollProxy in
            self.onReceive(scrollPublisher) { shouldScroll in
                guard shouldScroll else {
                    return
                }
                scrollProxy.scrollTo(ProductVariantsSelectionView.sectionID, anchor: .bottom, delay: 0.1, animation: .easeIn(duration: 0.4))
            }
        }
    }
}

struct ProductVariantsSelectionBannerViewModifier: ViewModifier {
    
    let showSelectionBanner: Bool
    
    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if showSelectionBanner {
                SelectVariantsBannerView()
                    .offset(y: -(56 + 44))
            }
        }
        .animation(.easeOut(duration: 0.5), value: showSelectionBanner)
    }
}

#if DEBUG
struct ProductVariantsSelectionBanner_Previews: PreviewProvider {
    
    static var previews: some View {
        StatefulPreviewWrapper(false) { isPresentedBinding in
            VStack {
                Button("Show banner") {
                    isPresentedBinding.wrappedValue.toggle()
                }
                Color.blue.productVariantsSelectionBanner(isPresented: isPresentedBinding.wrappedValue)
            }
        }
    }
}
#endif
