//
//  SegmentedPicker.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.12.2022.
//

import SwiftUI

protocol Segmentable {
    
    var segmentText: String { get }
}

typealias SegmentTexts = [Int:String]

struct SegmentedPicker<
    Items: RandomAccessCollection,
    SupplementaryViewForSegment: View
>: View where Items.Element: Hashable & Segmentable {
    
    typealias Segment = Items.Element
    
    @Binding var selection: Segment
    
    let items: Items
    var overrideSegmentTexts: SegmentTexts?
    
    var textFont: KernedFont = .Main.p2RegularKerned
    var selectedSegmentTintColor: Color = .ebony.opacity(0.15)
    let supplementaryViewForSegment: (Segment) -> SupplementaryViewForSegment
    
    private let segmentSpacing: CGFloat = 4
    private var numberOfSegments: Int {
        items.count
    }
    
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { (offset: Int, item: Segment) in
                    segmentView(item, offset: offset, in: proxy.size)
                }
            }
            .backgroundPreferenceValue(AnchorPreferenceKey.self) { anchor in
                selectedSegmentIndicator(in: anchor)
            }
            .padding(.horizontal, segmentSpacing)
            .background(Color.white)
            .roundedBorder(Color.midGrey)
        }
        .frame(height: 56)
    }
    
    @ViewBuilder
    private func selectedSegmentIndicator(in anchor: Anchor<CGRect>?) -> some View {
        if let anchor = anchor {
            GeometryReader { proxy in
                let size = proxy.size
                Rectangle()
                    .fill(selectedSegmentTintColor)
                    .frame(
                        width: size.width / CGFloat(numberOfSegments),
                        height: size.height - 2 * segmentSpacing
                    )
                    .roundedBorder(Color.darkGreen)
                    .offset(x: proxy[anchor].minX, y: segmentSpacing)
                    .animation(.easeInOut, value: selection)
            }
        }
    }
    
    
    private func segmentView(_ segment: Segment, offset: Int, in size: CGSize) -> some View {
        let isSelected = selection == segment
        return Button {
            selection = segment
        } label: {
            HStack(spacing: 8) {
                supplementaryViewForSegment(segment)
                Text(overrideSegmentTexts?[segment.hashValue] ?? segment.segmentText)
                    .font(kernedFont: textFont)
                    .foregroundColor(isSelected ? .darkGreen : .ebony)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
            .frame(width: size.width / CGFloat(numberOfSegments), height: size.height)
            .anchorPreference(key: AnchorPreferenceKey.self, value: .bounds) { anchor in
                isSelected ? anchor : nil
            }
            .background(Color.cultured.opacity(0.001))
            .background(
                segmentDivider(at: offset), alignment: .trailing
            )
        }
        .buttonStyle(.scaled)
    }
    
    private func showDivider(at segmentIndex: Int) -> Bool {
        guard segmentIndex < numberOfSegments - 1, numberOfSegments > 2,
              let selectionIndex = items.firstIndex(of: selection) as? Int else {
            return false
        }
        return ![selectionIndex - 1, selectionIndex].contains(segmentIndex)
    }
    
    @ViewBuilder
    func segmentDivider(at segmentIndex: Int) -> some View {
        if showDivider(at: segmentIndex) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 1)
                .transition(.opacity)
        }
    }
}

extension SegmentedPicker where SupplementaryViewForSegment == EmptyView {
    
    init(selection: Binding<Segment>, items: Items) {
        self._selection = selection
        self.items = items
        supplementaryViewForSegment = { _ in
            EmptyView.init()
        }
    }
    
    init(selection: Binding<Segment>, items: Items, textFont: KernedFont, selectedSegmentTintColor: Color, overrideSegmentTexts: SegmentTexts?) {
        self.init(selection: selection, items: items)
        self.textFont = textFont
        self.overrideSegmentTexts = overrideSegmentTexts
        self.selectedSegmentTintColor = selectedSegmentTintColor
    }
}


#if DEBUG
struct SegmentedPicker_Previews: PreviewProvider {

    static var previews: some View {
        SegmentedPickerPreview()
    }
    
    private struct SegmentedPickerPreview: View {
        
        @State private var selection: ShowPublishTime = .now
        
        
        var body: some View {
            VStack {
                SegmentedPicker(selection: $selection, items: ShowPublishTime.allCases)
            }
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }
}
#endif
