//
// ApprovedCreatorViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 18.11.2022.
//

import Foundation
import SwiftUI
import UIKit

class ApprovedCreatorViewController: UIHostingController<ApprovedCreatorView> {
    
    init(onGetStarted: @escaping () -> Void) {
        super.init(rootView: ApprovedCreatorView(action: onGetStarted))
    }
    
    override func loadView() {
        super.loadView()
        setupBottomSheetAppearance()
        view.backgroundColor = .clear
    }
    
    private func setupBottomSheetAppearance() {
        guard let bottomSheet = sheetPresentationController else {
            return
        }
        bottomSheet.detents = [.medium()]
        bottomSheet.prefersGrabberVisible = true
        bottomSheet.prefersScrollingExpandsWhenScrolledToEdge = false
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
