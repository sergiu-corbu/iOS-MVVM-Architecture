//
//  View + Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import Foundation
import SwiftUI
import Combine

extension View {
    
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
    
    func roundedBorder<S>(
        _ content: S,
        cornerRadius: CGFloat = 5,
        lineWidth: CGFloat = 1
    ) -> some View where S: ShapeStyle {
        overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(content, lineWidth: lineWidth)
        }
    }
    
    /// Adds a rounded border to this view with the specified style and width
    /// Note: This method clips the bounding view
    func border<S>(
        _ content: S,
        cornerRadius: CGFloat = 5,
        lineWidth: CGFloat = 1
    ) -> some View where S: ShapeStyle {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self
            .background(shape.stroke(content, lineWidth: lineWidth))
            .clipShape(shape)
        
    }
    
    /// This function is a convenience implementation of `onReceive<T: Publisher>`.
    func debounce<T: Publisher>(
        publisher: T,
        for seconds: TimeInterval = 0.5,
        _ action: @escaping () -> Void
    ) -> some View where T.Failure == Never {
        onReceive(publisher.debounce(
            for: .seconds(seconds),
            scheduler: DispatchQueue.main
        )) { _ in
            action()
        }
    }
    
    func primaryBackground() -> some View {
        background(Color.cultured.ignoresSafeArea(.container, edges: .vertical))
    }
    
    func splitColorBackground(
        firstColor: Color = .darkGreen,
        secondColor: Color = .cultured
    ) -> some View {
        background(
            VStack(spacing: 0) {
                firstColor
                secondColor
            }
            .ignoresSafeArea(.container, edges: .vertical)
        )
    }
    
    @ViewBuilder
    func loadingIndicator(_ isLoading: Bool, scale: CGFloat = 1, tint: Color = .darkGreen) -> some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(tint)
                .scaleEffect(scale)
                .transition(.opacity.animation(.linear))
        } else {
            self
        }
    }
    
    func overlayLoadingIndicator(
        _ isLoading: Bool,
        tint: Color = .darkGreen,
        scale: CGFloat = 1.2,
        alignment: Alignment = .center,
        inset: EdgeInsets = EdgeInsets.zero,
        shouldDisableInteraction: Bool = true
    ) -> some View {
        self.overlay(alignment: alignment) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(scale)
                    .tint(tint)
                    .padding(inset)
                    .transition(.fadeAndScale())
            }
        }
        .disabled(isLoading && shouldDisableInteraction)
    }
    
    func overlayLoadingIndicator(loadingSourceType: LoadingSourceType?, tint: Color = .darkGreen) -> some View {
        self.overlay(alignment: loadingSourceType == .paged ? .bottom : .center) {
            if loadingSourceType != nil {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1)
                    .tint(tint)
                    .transition(.fadeAndScale())
            }
        }
    }
    
    func dashedBorder(
        strokeStyle: StrokeStyle = StrokeStyle(lineWidth: 1, dash: [5]),
        cornerRadius: CGFloat = 5,
        fillColor: Color = .middleGrey
    ) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(style: strokeStyle)
                .fill(fillColor)
                .background(Color.white.opacity(0.001))
        )
    }
    
    func roundedCorners(_ corners: UIRectCorner, radius: CGFloat) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
    
    func outlinedBackground(_ backgroundColor: Color = .ebony.opacity(0.15)) -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                ZStack {
                    backgroundColor
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.middleGrey)
                }
            }
            .padding(.horizontal, 16)
    }
    
    var safeAreaInsets: UIEdgeInsets {
        return UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }
    
    func safeAreaOverlay<Content: View>(@ViewBuilder _ content: () -> Content, edge: VerticalAlignment = .top) -> some View {
        let edgeSet: Edge.Set = edge == .top ? .top : .bottom
        return overlay(alignment: Alignment(horizontal: .center, vertical: edge)) {
            content()
                .frame(height: safeAreaInsets.top)
                .ignoresSafeArea(.container, edges: edgeSet)
        }
    }
    
    /// Positions this view within an invisible frame with the specified size.
    func frame(size: CGSize?, alignment: Alignment = .center) -> some View {
        frame(width: size?.width, height: size?.height, alignment: alignment)
    }
}

@available(iOS 16.0, *)
extension Layout {
    
    func eraseToAnyLayout() -> AnyLayout {
        return AnyLayout(self)
    }
}

struct PassthroughView<Content>: View where Content: View {
    
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack {
            content
        }
    }
}
