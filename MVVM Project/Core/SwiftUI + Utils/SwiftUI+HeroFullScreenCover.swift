//
//  SwiftUI+HeroFullScreenCover.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 10.02.2023.
//

import SwiftUI

extension View {
    
    func heroFullScreenCover<Content>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        
        return modifier(HeroFullScreenCoverModifier(isPresented: isPresented, supplementaryView: content()))
    }
}

fileprivate struct HeroFullScreenCoverModifier<SupplementaryView: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    let supplementaryView: SupplementaryView
    
    @State private var presentedHostingVC: PresentedHostingViewController<SupplementaryView>?
    @State private var parentVC: UIViewController?
    
    func body(content: Content) -> some View {
        content
            .background(
                HostingViewHelper(hostingViewController: $presentedHostingVC, content: supplementaryView, parentViewControllerChanged: { parentVC in
                    self.parentVC = parentVC
                })
            )
            .onChange(of: isPresented) { newValue in
                if newValue {
                    let hostingVC = PresentedHostingViewController(isPresented: $isPresented, rootView: supplementaryView)
                    self.presentedHostingVC = hostingVC
                    hostingVC.modalTransitionStyle = .crossDissolve
                    hostingVC.modalPresentationStyle = .overCurrentContext
                    hostingVC.view.backgroundColor = .clear
                    parentVC?.present(hostingVC, animated: false)
                } else {
                    presentedHostingVC?.dismiss(animated: false)
                }
            }
    }
}

extension HeroFullScreenCoverModifier {
    
    struct HostingViewHelper<Content: View>: UIViewRepresentable {
        
        @Binding var hostingViewController: PresentedHostingViewController<Content>?
        let content: Content
        let parentViewControllerChanged: (UIViewController?) -> Void
        
        func makeUIView(context: Context) -> UIView {
            return UIView()
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            hostingViewController?.rootView = content
            DispatchQueue.main.async {
                parentViewControllerChanged(uiView.superview?.superview?.parentController)
            }
        }
    }
    
    class PresentedHostingViewController<Content: View>: UIHostingController<Content> {
        
        @Binding var isPresented: Bool
        
        init(isPresented: Binding<Bool>, rootView: Content) {
            self._isPresented = isPresented
            super.init(rootView: rootView)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(false)
            isPresented = false
        }
        
        required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

fileprivate extension UIView {
    
    var parentController: UIViewController? {
        var responder = self.next
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}

#if DEBUG
struct HeroFullScreenCover_Previews: PreviewProvider {
    
    static var previews: some View {
        HeroFullScreenCoverPreview()
    }
    
    static let models: [Model] = [
        Model(color: .red),Model(color: .green),Model(color: .blue) ,Model(color: .black),Model(color: .orange),Model(color: .brown),Model(color: .cyan),
        Model(color: .indigo), Model(color: .mint),Model(color: .pink)
    ]
    
    struct Model: Identifiable {
        var id = UUID()
        var color: Color
    }
    
    struct HeroFullScreenCoverPreview: View {
        
        @State var isPresented = false
        @State var selectedRow: Model?
        @Namespace private var heroAnimationNamespace
        
        var body: some View {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 6), count: 3), spacing: 6) {
                        ForEach(models) { model in
                            if selectedRow?.id == model.id  {
                                Rectangle()
                                    .fill(.clear)
                                    .frame(height: 100)
                            } else {
                                Rectangle()
                                    .fill(model.color)
                                    .matchedGeometryEffect(id: model.id.uuidString, in: heroAnimationNamespace)
                                    .frame(height: 100)
                                    .onTapGesture {
                                        withAnimation(.hero) {
                                            selectedRow = model
                                            isPresented.toggle()
                                        }
                                    }
                            }
                        }
                    }
                    .padding(15)
                }
                .heroFullScreenCover(isPresented: $isPresented, content: {
                    DetailView(row: $selectedRow, animationID: heroAnimationNamespace)
                })
            }
            .navigationBarHidden(true)
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
        }
    }
    
    struct DetailView: View {
        
        @Binding var row: Model?
        let animationID: Namespace.ID
        
        @State private var animateHeroView = false
        @State private var animateContent = false
        
        @Environment(\.dismiss) private var dismissHandler
        
        var body: some View {
            VStack {
                if animateHeroView, let row {
                    Rectangle()
                        .fill(row.color)
                        .matchedGeometryEffect(id: row.id.uuidString, in: animationID)
                        .frame(width: 200, height: 200)
                        .transition(.asymmetric(insertion: .identity, removal: .offset(x: 10, y: 10)))
                } else {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 200, height: 200)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.opacity(animateContent ? 1 : 0))
            .overlay(alignment: .topLeading) {
                dismissButton
            }
            .onAppear(perform: startAnimations)
        }
        
        private func startAnimations() {
            withAnimation(.hero) {
                animateContent = true
                animateHeroView = true
            }
        }
        
        var dismissButton: some View {
            Button("Dismiss") {
                withAnimation(.hero) {
                    animateContent = false
                    animateHeroView = false
                    row = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        dismissHandler()
                    }
                }
            }
            .padding()
            .opacity(animateContent ? 1 : 0)
        }
    }
}
#endif
