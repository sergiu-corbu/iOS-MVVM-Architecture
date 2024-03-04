//
//  AccountValidationViewController.swift
//  Bond
//
//  Created by Mihai Mocanu on 09.11.2022.
//

import SwiftUI
import Combine
import MessageUI

class AccountValidationViewController: UIHostingController<AccountValidationView> {
    
    let viewModel: AccountValidationViewModel
    var mailActionController: MailActionSheetController?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: AccountValidationViewModel) {
        self.viewModel = viewModel
        
        super.init(rootView: AccountValidationView(viewModel: viewModel))
        setupCancellables()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCancellables() {
        viewModel.onOpenMail.sink { [unowned self] in
            let mailActionController = MailActionSheetController(presentationViewController: self, shouldComposeMessage: true)
            self.mailActionController = mailActionController
        }.store(in: &cancellables)
    }
}
