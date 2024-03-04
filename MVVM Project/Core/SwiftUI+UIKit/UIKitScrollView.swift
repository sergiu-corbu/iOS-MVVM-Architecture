////
////  UIKitScrollView.swift
////  MVVM Project
////
////  Created by Sergiu Corbu on 03.03.2023.
////
//
import SwiftUI
import UIKit
//
//class UIScrollViewViewControllerWrapper<Content: View>: UIViewController {
//
//    lazy var scrollView: UIScrollView = {
//        let v = UIScrollView()
//        v.isPagingEnabled = true
//        return v
//    }()
//
//    var hostingController: UIHostingController<Content>!
//
//    let content: Content
//
//    init(content: Content) {
//        self.content = content
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.addSubview(scrollView)
//        self.pinEdges(of: scrollView, to: view)
//        scrollView.contentInsetAdjustmentBehavior = .never
//        setupHostingController()
//    }
//
//    private func setupHostingController() {
//        let hostingController = UIHostingController(rootView: content)
//        self.hostingController = hostingController
//        self.hostingController.willMove(toParent: self)
//        self.scrollView.addSubview(self.hostingController.view)
//        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
//        self.hostingController.didMove(toParent: self)
//    }
//
//    func pinEdges(of viewA: UIView, to viewB: UIView) {
//        viewA.translatesAutoresizingMaskIntoConstraints = false
//        viewB.addConstraints([
//            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
//            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
//            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
//            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor),
//        ])
//    }
//
//}
//
//struct UIKitScrollView<Content: View>: UIViewRepresentable {
//
//    @ViewBuilder var content: Content
//
//    var onCustomizeScrollView: ((UIScrollView) -> Void)?
//
//    func makeUIView(context: Context) -> UIScrollView {
//        let scrollView = UIScrollView()
//        let hostingVC = UIHostingController(rootView: content)
//        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(hostingVC.view)
//        hostingVC.view.constrainAllMargins(with: scrollView)
//
//        context.coordinator.hostingVC = hostingVC
//        onCustomizeScrollView?(scrollView)
//        return scrollView
//    }
//
//    func updateUIView(_ uiView: UIScrollView, context: Context) {
//        context.coordinator.hostingVC?.rootView = content
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//
//    class Coordinator {
//        var hostingVC: UIHostingController<Content>?
//    }
//
////    func makeUIViewController(context: Context) -> UIScrollViewViewControllerWrapper<Content> {
////        let scrollVCWrapper = UIScrollViewViewControllerWrapper(content: content)
////        onCustomizeScrollView?(scrollVCWrapper.scrollView)
////        return scrollVCWrapper
////    }
////
////    func updateUIViewController(_ viewController: UIScrollViewViewControllerWrapper<Content>, context: Context) {
////        viewController.hostingController.rootView = content
////    }
//}


class UIScrollViewViewController: UIViewController {

    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.isPagingEnabled = true
        v.refreshControl = UIRefreshControl()
//        
        return v
    }()

    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.scrollView)
        self.pinEdges(of: self.scrollView, to: self.view)

        self.hostingController.willMove(toParent: self)
        self.scrollView.addSubview(self.hostingController.view)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)

    }

    func pinEdges(of viewA: UIView, to viewB: UIView) {
        viewA.translatesAutoresizingMaskIntoConstraints = false
        viewB.addConstraints([
            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor),
        ])
    }

}

struct UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {

    var content: () -> Content
    let onCustomizeScrollView: (UIScrollView) -> Void

    func makeUIViewController(context: Context) -> UIScrollViewViewController {
        let vc = UIScrollViewViewController()
        vc.hostingController.rootView = AnyView(self.content())
        onCustomizeScrollView(vc.scrollView)
        return vc
    }

    func updateUIViewController(_ viewController: UIScrollViewViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
    }
}
