//
//  ProductDetailsViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 12.05.2023.
//

import Foundation
import UIKit
import SwiftUI

class ProductDetailsViewController: UIHostingController<ProductDetailsView> {
    
    var onDissappear: (() -> Void)?
    
    override init(rootView: ProductDetailsView) {
        super.init(rootView: rootView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()        
        setupSheetPresentationController()
        view.backgroundColor = .cultured
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            onDissappear?()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.darkContent
    }
    
    private func setupSheetPresentationController() {
        guard let sheetPresentationController else {
            return
        }
        sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        sheetPresentationController.preferredCornerRadius = 12
        sheetPresentationController.prefersGrabberVisible = false
        sheetPresentationController.detents = [
            .custom(resolver: { context in
                return context.maximumDetentValue * 0.8
            }), .large()
        ]
    }
}
