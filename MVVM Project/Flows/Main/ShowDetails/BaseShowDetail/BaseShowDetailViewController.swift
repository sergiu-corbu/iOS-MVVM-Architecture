//
//  BaseShowDetailViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 13.04.2023.
//

import Foundation
import UIKit
import SwiftUI

class BaseShowDetailViewController<ShowDetailView: View>: UIHostingController<ShowDetailView> {
    
    override init(rootView: ShowDetailView) {
        super.init(rootView: rootView)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.darkContent
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .cultured
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
