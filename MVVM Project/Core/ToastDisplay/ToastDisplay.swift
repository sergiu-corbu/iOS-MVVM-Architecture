//
//  ToastDisplay.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.10.2022.
//

import SwiftUI

struct ToastDisplay: View {
    
    class Controller {
        var dismissAction: (() -> Void)?
        
        func dismiss() {
            dismissAction?()
            dismissAction = nil
        }
    }
    
    @Binding var isPresented: Bool
    let style: Style
    let title: String?
    let message: String
        
    private let controller: Controller?
    
    @State private var yTranslation: CGFloat = .zero
    @State private var isDragging = false
    private let displaySeconds: TimeInterval = 3
    
    init(isPresented: Binding<Bool>, style: Style, title: String?, message: String, controller: Controller? = nil) {
        self._isPresented = isPresented
        self.style = style
        self.title = title
        self.message = message
        self.controller = controller
    }
    
    var body: some View {
        ZStack {
            if isPresented {
                toastContent
                    .gesture(dragGesture)
                    .transition(.moveAndFade())
                    .task {
                        await dismissToast(after: displaySeconds)
                    }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPresented)
    }
    
    private var toastContent: some View {
        HStack(spacing: 12) {
            Image(style.image)
            VStack(alignment: .leading, spacing: 2) {
                if let title {
                    Text(title)
                        .font(.Secondary.p1Bold)
                        .foregroundColor(style.tint)
                }
                Text(message)
                    .textStyle(.toastMessage)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
        .roundedBorder(style.tint)
        .background(Color.cultured.cornerRadius(5))
        .padding(.horizontal, 16)
        .offset(y: yTranslation)
        .animation(.easeIn(duration: 0.4), value: yTranslation)
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                let draggedHeight = value.translation.height
                if !isDragging {
                    isDragging = true
                }
                
                guard draggedHeight < .zero else {
                    if draggedHeight < 50 {
                        yTranslation = draggedHeight
                    }
                    return
                }
                
                if abs(draggedHeight) > 40 {
                    dismissAction()
                } else {
                    yTranslation = draggedHeight
                }
            }
            .onEnded { _ in
                yTranslation = .zero
                isDragging = false
                Task(priority: .userInitiated) {
                    await dismissToast(after: displaySeconds)
                }
            }
    }
    
    @MainActor
    private func dismissToast(after seconds: TimeInterval) async {
        await Task.sleep(seconds: seconds)
        
        if !isDragging {
            dismissAction()
        }
    }
    
    private func dismissAction() {
        isPresented = false
        controller?.dismiss()
    }
}

#if DEBUG
struct ToastDisplay_Previews: PreviewProvider {
    
    static var previews: some View {
        ToastDisplayPreview()
    }
    
    private struct ToastDisplayPreview: View {
        
        @State var isPresented = false
        
        enum ToastError: String, LocalizedError {
            case title = "This is a short title"
            case message = "This is a regular error message"
            var errorDescription: String? {
                rawValue
            }
        }
        
        var body: some View {
            Color.beige
                .onTapGesture {
                    isPresented.toggle()
                }
                .successToast(isPresented: $isPresented, title: "Success", message: ToastError.message.localizedDescription + ToastError.message.localizedDescription)
//                .errorToast(isPresented: $isPresented, error: ToastError.message)
        }
    }
}
#endif
