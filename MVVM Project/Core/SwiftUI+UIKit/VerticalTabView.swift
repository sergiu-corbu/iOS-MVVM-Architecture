//
//  VerticalTabView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.01.2023.
//

import SwiftUI
import UIKit

struct VerticalTabView<PageContent: View>: UIViewControllerRepresentable {
    
    @Binding var currentPage: Int
    let pages: [PageContent]
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        return pageViewController
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        context.coordinator.updateRootViews(with: pages)
        uiViewController.setViewControllers(
            [context.coordinator.viewControllers[currentPage]],
            direction: currentPage == 0 ? .reverse : .forward,
            animated: true
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(verticalTabView: self)
    }
    
    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
        let verticalTabView: VerticalTabView
        private(set) var viewControllers: [UIViewController]
        
        init(verticalTabView: VerticalTabView) {
            self.verticalTabView = verticalTabView
            self.viewControllers = verticalTabView.pages.map { UIHostingController(rootView: $0) }
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            
            guard let index = viewControllers.firstIndex(of: viewController), index > 0 else {
                return nil
            }
            return viewControllers[safe: index - 1]
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            
            guard let index = viewControllers.firstIndex(of: viewController), index < viewControllers.count - 1 else {
                return nil
            }
            return viewControllers[safe: index + 1]
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            
            if let visibleVC = pageViewController.viewControllers?.first,
               let index = viewControllers.firstIndex(of: visibleVC), completed {
                verticalTabView.currentPage = index
            }
        }
        
        func updateRootViews(with views: [PageContent]) {
            for (index, viewController) in viewControllers.enumerated() {
                (viewController as? UIHostingController<PageContent>)?.rootView = views[index]
            }
        }
    }
}
