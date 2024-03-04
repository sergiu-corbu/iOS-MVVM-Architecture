//
//  ToastDisplay+UIKit.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.01.2023.
//

import Foundation
import SwiftUI
import UIKit

private class ToastViewController: UIHostingController<ToastDisplay> {
    
    private let controller = ToastDisplay.Controller()
    
    init(title: String? = nil, message: String, style: ToastDisplay.Style, animates: Bool) {
        super.init(rootView: ToastDisplay(isPresented: .constant(true), style: style, title: title, message: message, controller: controller))
        
        commonSetup(with: controller, animates: animates)
    }
    
    init(error: Error, animates: Bool) {
        super.init(rootView: ToastDisplay(isPresented: .constant(true), style: .error, title: nil, message: error.localizedDescription, controller: controller))
        
        commonSetup(with: controller, animates: animates)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonSetup(with controller: ToastDisplay.Controller, animates: Bool) {
        view.backgroundColor = .clear
        
        controller.dismissAction = { [weak self] in
            self?.removeFromParentViewController(animated: animates)
        }
    }
}

extension ToastDisplay {
    
    static func showSuccessToast(from viewController: UIViewController? = UIApplication.shared.rootViewController, title: String? = nil, message: String, animated: Bool = true) {
        viewController?.embedChildViewController(ToastViewController(title: title, message: message, style: .success, animates: animated))
    }
    
    static func showInformativeToast(from viewController: UIViewController? = UIApplication.shared.rootViewController, title: String? = nil, message: String, animated: Bool = true) {
        viewController?.embedChildViewController(ToastViewController(title: title, message: message, style: .informative, animates: animated))
    }
    
    static func showErrorToast(from viewController: UIViewController? = UIApplication.shared.rootViewController, error: Error?, animated: Bool = true) {
        guard let error else {
            return
        }
        
        viewController?.embedChildViewController(ToastViewController(error: error, animates: animated))
    }
}

private extension UIViewController {
    
    func embedChildViewController(_ viewController: UIViewController, animated: Bool = true) {
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(viewController.view)
        
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        self.addChild(viewController)
        guard animated else {
            viewController.didMove(toParent: self)
            return
        }
        viewController.view.alpha = 0
        viewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.6, delay: 0, options: .transitionCurlDown) {
            viewController.view.alpha = 1
        } completion: { _ in
            viewController.didMove(toParent: self)
        }
    }
    
    func removeFromParentViewController(animated: Bool) {
        UIView.animate(withDuration: 0.6, delay: 0, options: .transitionCurlUp, animations: { [weak self] in
            self?.view.alpha = 0.0
        }, completion: { [weak self] _ in
            self?.willMove(toParent: nil)
            self?.view.removeFromSuperview()
            self?.removeFromParent()
        })
    }
}
