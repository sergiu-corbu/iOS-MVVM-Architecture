//
//  LineLimitedTextView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.02.2023.
//

import SwiftUI

extension Text {
    
    func lineLimitedTextView(
        isExpanded: Binding<Bool>, text: String,
        defaultLineLimit: Int = 2, font: Font,
        kern: CGFloat? = nil
    ) -> some View {
        
        return self
            .font(font)
            .kerning(kern ?? .zero)
            .modifier(
                LineLimitedTextViewModifier(
                    isExpanded: isExpanded, text: text,
                    defaultLineLimit: defaultLineLimit, font: font, kern: kern
                )
            )
    }
    
    private struct LineLimitedTextViewModifier: ViewModifier {
        
        @Binding var isExpanded: Bool
        
        let text: String
        let defaultLineLimit: Int
        let font: Font
        let kern: CGFloat?
        
        func body(content: Content) -> some View {
            content
                .lineLimit(isExpanded ? nil : defaultLineLimit)
                .background {
                    if !isExpanded {
                        unlimitedTextViewHelper(content: content).hidden()
                    }
                }
        }
        
        private func unlimitedTextViewHelper(content: Content) -> some View {
            let originalTextHeight = (text as NSString)
                .size(withAttributes: [.font: UIFont.Secondary.regular(13) as Any, .kern: 0.3]).height
            return GeometryReader { geometryProxy in
                content
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        Color.clear.onAppear {
                            isExpanded = geometryProxy.size.height / originalTextHeight < CGFloat(defaultLineLimit)
                        }
                    )
            }
        }
    }
}

#if DEBUG
struct LineLimitedTextView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(spacing: 20) {
            LineLimitedTextPreview(text: "Short textlr\nrfre")
            LineLimitedTextPreview(text: Strings.ContentCreation.videoThumbnailDescription)
        }
        .frame(height: 100, alignment: .top)
        .padding()
    }
    
    private struct LineLimitedTextPreview: View {
        
        let text: String
        var font: KernedFont = .Secondary.p1RegularKerned
        var defaultLineLimit: Int = 2
        
        @State private var showExpandButton = false
        
        var body: some View {
            Text(text)
                .font(kernedFont: font)
                .lineLimitedTextView(isExpanded: $showExpandButton, text: text, defaultLineLimit: defaultLineLimit, font: font.font, kern: font.kern)
                .overlay(alignment: .bottomTrailing) {
                    if !showExpandButton {
                        expandButton
                    }
                }
        }
        
        private var expandButton: some View {
            Button {
                showExpandButton.toggle()
            } label: {
                Text("... " + Strings.Buttons.more)
                    .font(kernedFont: .Secondary.p2BoldKerned)
                    .foregroundColor(.darkGreen)
            }
            .buttonStyle(.plain)
            .background(Color.cultured)
        }
    }
}
#endif
