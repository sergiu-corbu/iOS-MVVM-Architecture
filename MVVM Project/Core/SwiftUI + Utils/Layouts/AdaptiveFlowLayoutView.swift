//
//  AdaptiveFlowLayoutView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.11.2022.
//

import SwiftUI

struct AdaptiveFlowLayoutView<Data: RandomAccessCollection, CellView: View>: View where Data.Element: Hashable {
    
    let data: Data
    var interitemSpacing: CGFloat = 16
    var lineSpacing: CGFloat = 16
    
    @ViewBuilder var layoutCellView: (Data.Element) -> CellView
    @State private var layout: _AdaptiveFlowLayout = .empty
    
    var body: some View {
        AdaptiveFlowLayout(interitemSpacing: interitemSpacing, lineSpacing: lineSpacing) {
            ForEach(data, id: \.self) { item in
                layoutCellView(item)
            }
        }
    }
}

extension View {
    
    func layoutOffset(_ offset: CGPoint?) -> some View {
        self.offset(CGSize(width: offset?.x ?? .zero, height: offset?.y ?? .zero))
    }
    
    func setAdaptiveLayoutPreference() -> some View {
        self.background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: AdaptiveFlowLayoutPreferenceKey.self, value: [proxy.size])
            }
        )
    }
}

fileprivate struct AdaptiveFlowLayoutPreferenceKey: PreferenceKey {
    typealias Value = [CGSize]
    
    static var defaultValue: [CGSize] {
        return []
    }
    
    static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
        value += nextValue()
    }
}

fileprivate struct _AdaptiveFlowLayout {
    
    let contentSize: CGSize
    let positions: [CGPoint]
    
    static func computeAdaptiveFlowLayout(
        for sizes: [CGSize],
        maximumWidth: CGFloat,
        interitemSpacing: CGFloat,
        lineSpacing: CGFloat
    ) -> Self {
        
        var result = [CGPoint]()
        var currentX: CGFloat = .zero
        var currentY: CGFloat = .zero
        var lineHeight: CGFloat = .zero
        
        sizes.forEach { childViewSize in
            if currentX + childViewSize.width + interitemSpacing > maximumWidth {
                currentX = .zero
                currentY += lineHeight + lineSpacing
                lineHeight = .zero
            }
            lineHeight = max(lineHeight, childViewSize.height)
            result.append(CGPoint(x: currentX, y: currentY))
            currentX += childViewSize.width + interitemSpacing
        }
        
        return Self.init(contentSize: CGSize(width: maximumWidth, height: currentY + lineHeight), positions: result)
    }
    
    static var empty: Self {
        return Self.init(contentSize: .zero, positions: [])
    }
}

#if DEBUG
struct AdaptiveFlowLayoutView_Previews: PreviewProvider {
    static let data = Array(80..<130)
    
    static let nums = ["one", "twooooooo", "thereee", "fooor", "random text", "tongeurg", "fefefurehferuferuferufre"]
    
    static var previews: some View {
        ScrollView {
            AdaptiveFlowLayoutView(data: nums) { num in
                Text(num)
                    .padding(6)
                    .background(Color.random)
            }
            .background(Color.green)
            .padding()
        }
    }
}
#endif

//iOS 15 implementation
/*
 //            GeometryReader { proxy in
 //                ZStack(alignment: .topLeading) {
 //                    Color.clear
 //                        .frame(width: layout.contentSize.width, height: layout.contentSize.width)
 //                    ForEach(Array(data.enumerated()), id: \.offset) { (offset, item) in
 //                        layoutCellView(item)
 //                            .layoutOffset(layout.positions[safe: offset])
 //                            .setAdaptiveLayoutPreference()
 //                    }
 //                }
 //                .onPreferenceChange(AdaptiveFlowLayoutPreferenceKey.self) { value in
 //                    DispatchQueue.main.async {
 //                        layout = _AdaptiveFlowLayout.computeAdaptiveFlowLayout(
 //                            for: value,
 //                            maximumWidth: proxy.size.width,
 //                            interitemSpacing: interitemSpacing, lineSpacing: lineSpacing
 //                        )
 //                    }
 //                }
 //            }
 //            .frame(height: layout.contentSize.height)
 //        }

 */
