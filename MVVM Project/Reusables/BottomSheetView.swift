//
//  BottomSheetView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.12.2022.
//

import SwiftUI

extension View {
        
    func bottomSheet<Content>(
        isPresented: Binding<Bool>,
        showGrabber: Bool = true,
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View where Content: View {
        overlay(
            BottomSheetView(
                isPresented: isPresented,
                isGrabberVisible: showGrabber,
                content: content
            )
            .ignoresSafeArea(.container, edges: .bottom), alignment: .bottom
        )
    }
}

/// A container view that must be used as an `overlay` to the parent view.
/// - Note: Apply the `.ignoresSafeArea()` modifier when using it outside the existing `.bottomSheet` modifier.
struct BottomSheetView<Content: View>: View {
    
    @Binding var isPresented: Bool
    
    var backgroundColor: Color = .cultured
    var isGrabberVisible: Bool = true
    
    @ViewBuilder var content: Content
    
    @State private var yOffset: CGFloat = .zero
    
    var body: some View {
        ZStack {
            if isPresented {
                ZStack(alignment: .bottom) {
                    backgroundView
                    mainContent
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.4), value: yOffset)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.75), value: isPresented)
    }
    
    private var mainContent: some View {
        VStack(spacing: 12) {
            if isGrabberVisible {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray)
                    .frame(width: 56, height: 3)
                    .padding(.top, 4)
            }
            content
        }
        .background(backgroundColor)
        .offset(y: yOffset)
        .systemScrollIgnoringGesture(dragGesture)
    }
    
    private var backgroundView: some View {
        Color.jet
            .opacity(0.35)
            .transaction { bg in
                bg.animation = nil
            }
            .ignoresSafeArea(.container, edges: .top)
            .onTapGesture {
                isPresented = false
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                let draggedHeight = value.translation.height
                guard draggedHeight > 0 else {
                    return
                }
                yOffset = draggedHeight
            }
            .onEnded { value in
                if value.translation.height > 60 {
                    isPresented = false
                }
                yOffset = .zero
            }
    }
}

#if DEBUG
struct BottomSheetView_Previews: PreviewProvider {
    
    static var previews: some View {
        BottomSheetViewPreview()
    }
    
    private struct BottomSheetViewPreview: View {
        @State var isPresented = true
        
        var body: some View {
            VStack {
                Button("Toggle sheet") {
                    isPresented.toggle()
                }
                Color.feldgrau
            }
            .bottomSheet(isPresented: $isPresented) {
                Color.clear
                    .frame(height: 300)
                    .overlay {
                        Text("yaaay")
                    }
            }
        }
    }
}
#endif
