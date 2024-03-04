//
//  SetupRoomViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 06.12.2022.
//

import Foundation
import UIKit
import SwiftUI

class SetupRoomViewController: UIHostingController<SetupRoomView> {
    
    let viewModel: SetupRoomViewModel
    
    init(viewModel: SetupRoomViewModel) {
        self.viewModel = viewModel
        super.init(rootView: SetupRoomView(viewModel: viewModel))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.videoUploadSectionViewModel.setupPresentationController(navigationController)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
