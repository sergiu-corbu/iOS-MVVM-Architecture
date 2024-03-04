//
//  ReusableComponents.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.11.2022.
//

import SwiftUI

//MARK: DividerView
struct DividerView: View {
    
    var tint: Color = .ebony.opacity(0.15)
    
    var body: some View {
        Rectangle()
            .fill(tint)
            .frame(height: 1)
    }
}

struct GrabberView: View {
    
    var tint: Color = .jet.opacity(0.3)
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(tint)
            .frame(width: 56, height: 3)
            .padding(.top, 4)
    }
}

//MARK: Placeholders
struct ComingSoonView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            Image(.comingSoonPlaceholder)
            Text(Strings.Placeholders.comingSoon)
                .font(kernedFont: .Main.p1RegularKerned)
                .foregroundColor(.brightGold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .primaryBackground()
    }
}

struct ProductPlaceholderView: View {
    
    var body: some View {
        Image(.fashionIcon)
            .resizedToFit(size: nil)
    }
}

struct ImagePlaceholderView: View {
    
    var body: some View {
        VStack(spacing: 14) {
            Image(.plusIconLight)
            Text(Strings.Placeholders.coverImage.uppercased())
                .font(kernedFont: .Secondary.p3BoldKerned)
                .foregroundColor(.brownJet)
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16))
    }
}

struct EmptyProductsSearchView: View {
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.beige)
                Image(.informativeIcon)
            }
            .frame(width: 56, height: 56)
            Text(Strings.ContentCreation.noResults)
                .font(kernedFont: .Secondary.p1BoldKerned)
                .foregroundColor(.jet)
            Text(Strings.ContentCreation.searchQueryIndication)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.jet)
        }
        .padding(.horizontal, 16)
        .multilineTextAlignment(.center)
        .transition(.opacity.animation(.easeInOut(duration: 0.25)))
    }
}

struct LoadingResultsView: View {
    
    var body: some View {
        VStack(spacing: 12) {
            Text(Strings.Others.loadingResults)
                .font(kernedFont: .Secondary.p1RegularKerned)
                .foregroundColor(.jet)
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.jet)
                .scaleEffect(1.3)
        }
        .transition(.opacity.animation(.linear(duration: 0.25)))
    }
}

//MARK: Checkmark
struct CheckmarkView: View {
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.darkGreen)
                .frame(width: 18, height: 18)
            Image(systemName: "checkmark")
                .renderingMode(.template)
                .resizable()
                .frame(width: 9, height: 9)
                .foregroundColor(.white)
        }
        .transition(.opacity.animation(.linear(duration: 0.25)))
    }
}

//MARK: CircularPaginatedProgressView
struct CircularPaginatedProgressView: View {
    
    let currentIndex: Int
    var tint: Color = .cultured
    var backgroundColor: Color = .middleGrey
    let maxIndex: Int
    
    @Namespace private var animationNamespace
    private let animationID = "circularProgresViewID"
        
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<maxIndex, id: \.self) { index in
                dotView(isCurrent: index == currentIndex)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: currentIndex)
    }
    
    private func dotView(isCurrent: Bool) -> some View {
        Circle()
            .fill(isCurrent ? Color.cultured : .middleGrey)
            .frame(width: 4, height: 4)
            .background {
                if isCurrent {
                    Circle()
                        .fill(Color.jet)
                        .frame(width: 8, height: 8)
                        .matchedGeometryEffect(id: animationID, in: animationNamespace, properties: .position)
                        .transition(.opacity)
                }
            }
    }
}


//MARK: PaginatedProgressView
struct PaginatedProgressView: View {
    
    @Binding var currentIndex: Int
    
    let states: [ProgressState]
    let tint: Color
    let backgroundColor: Color
    let maxIndex: Int
    var animationDuration: TimeInterval = 3
    var autoAnimationDidFinish: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<maxIndex, id: \.self) { index in
                dashView(at: index)
            }
        }
    }
    
    private func dashAnimation(state: ProgressState) -> Animation? {
        guard !autoAnimationDidFinish else {
            return state == .idle ? nil : .linear(duration: 0.5)
        }
        return .linear(duration: animationDuration)
    }
    
    private func dashView(at index: Int) -> some View {
        let state = states[index]
        var progress: CGFloat {
            switch state {
            case .idle:
                return currentIndex == index ? 0.05 : 0
            case .progress(let progressValue):
                return index > currentIndex ? 0 : progressValue
            }
        }
        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 1)
                .fill(backgroundColor)
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 1)
                    .fill(tint)
                    .frame(width: progress * proxy.size.width)
                    .animation(dashAnimation(state: state), value: state)
            }
        }
    }
}

//MARK: LogoContainerView
struct LogoContainerView<Content: View>: View {
    
    let buttonTitle: String
    @ViewBuilder var contentView: Content
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Image(.logo)
                .padding(.top, 40)
            contentView
                .frame(maxHeight: .infinity)
            Buttons.FilledRoundedButton(
                title: buttonTitle,
                fillColor: .beige,
                tint: .darkGreen,
                action: action
            )
        }
        .background(Color.darkGreen)
    }
}

//MARK: SquareStyledCheckmark
struct SquareStyledCheckmarkView: View {
    
    let isSelected: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isSelected ? Color.darkGreen : .white)
            .frame(width: 18, height: 18)
            .roundedBorder(
                isSelected ? Color.clear : .ebony,
                cornerRadius: 2, lineWidth: 1.5
            )
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 9, height: 9)
                        .foregroundColor(.white)
                        .transition(.opacity)
                }
            }
    }
}

//MARK: ProductCategoriesContainer
struct ProductCategoriesContainerView: View {
    
    let productCategories: [ProductCategory]
    let onTagSelected: (_ tagID: String) -> Void
    
    init(productCategories: [ProductCategory], onTagSelected: @escaping (_: String) -> Void) {
        self.productCategories = productCategories.sorted(using: KeyPathComparator(\.name, order: .forward))
        self.onTagSelected = onTagSelected
    }
    
    var body: some View {
        if !productCategories.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(productCategories, id: \.id) { productCategory in
                        CategoryTagView(productCategory: productCategory) { _ in
                            onTagSelected(productCategory.violetId)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 32)
        }
    }
    
    struct CategoryTagView: View {
        
        let productCategory: ProductCategory
        let onSelect: (Bool) -> Void
        
        @State private var isSelected = false
        
        var body: some View {
            Button {
                isSelected = !isSelected
                onSelect(isSelected)
            } label: {
                Text(productCategory.name)
                    .font(kernedFont: .Secondary.p1RegularKerned)
                    .foregroundColor(isSelected ? .white : .jet)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background((isSelected ? Color.darkGreen : .clear).cornerRadius(4))
                    .animation(.linear, value: isSelected)
                    .roundedBorder(isSelected ? Color.darkGreen : .middleGrey, cornerRadius: 4)
            }
            .buttonStyle(.scaled)
        }
    }
}

//MARK: Previews
#if DEBUG
struct ReusableComponents_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollView {
            VStack(spacing: 30) {
                CircularPaginatedProgressView(currentIndex: 1, tint: .cultured, backgroundColor: .middleGrey, maxIndex: 3)
                ProductPlaceholderView()
                    .frame(height: 55)
                LoadingResultsView()
                EmptyProductsSearchView()
                HStack {
                    SquareStyledCheckmarkView(isSelected: true)
                    SquareStyledCheckmarkView(isSelected: false)
                }
                .padding()
                .background(Color.beige)
                ProductTypePreviews()
                CheckmarkView()
                ImagePlaceholderView()
                    .frame(height: 200)
                    .dashedBorder()
                    .padding(.horizontal, 16)
                PaginatedProgressViewPreview()
            }
        }
        LogoContainerView(buttonTitle: Strings.Buttons.startDiscovering) {
           Spacer()
        } action: { }
    }
    
    private struct PaginatedProgressViewPreview: View {
        
        @State var index = 0
        @State var finish = false
        
        var body: some View {
            VStack {
                PaginatedProgressView(
                    currentIndex: $index,
                    states: Array(repeating: ProgressState.idle, count: 3),
                    tint: .cultured,
                    backgroundColor: .middleGrey,
                    maxIndex: 3,
                    autoAnimationDidFinish: finish
                )
                .frame(height: 5)
            }
            .padding()
            .background(Color.red)
        }
    }
    
    private struct ProductTypePreviews: View {
        
        @State var categories = ProductCategory.all
        
        var body: some View {
            ProductCategoriesContainerView(productCategories: categories) {_ in}
        }
    }
}
#endif
