//
//  NotificationsViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation
import UIKit
import SwiftUI

class NotificationsViewController: UIHostingController<NotificationsView> {
    
    init() {
        super.init(rootView: .init())
//        configureTabBarItem(.notifications)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
