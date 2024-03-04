//
//  ForceUpdateViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 29.05.2023.
//

import Foundation
import SwiftUI
import UIKit

class ForceUpdateViewController: UIHostingController<ForceUpdateView> {
    
    override init(rootView: ForceUpdateView = ForceUpdateView()) {
        super.init(rootView: rootView)
        isModalInPresentation = true
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
