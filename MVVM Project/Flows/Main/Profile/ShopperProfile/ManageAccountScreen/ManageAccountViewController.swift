//
//  ManageAccountViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.11.2022.
//

import SwiftUI
import Combine

class ManageAccountViewController: UIHostingController<ManageAccountView> {
    
    let viewModel: ManageAccountViewModel
    private var mailController: MailActionSheetController?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ManageAccountViewModel) {
        self.viewModel = viewModel
        super.init(rootView: ManageAccountView(viewModel: viewModel))
        setupCancellables()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCancellables() {
        viewModel.onPresentLogOutAlert.sink { [weak self] in
            self?.showLogoutAlert()
        }.store(in: &cancellables)
        viewModel.onDeleteAccount.sink { [weak self] in
            self?.mailController = MailActionSheetController(presentationViewController: self, shouldComposeMessage: true, messageBody: Strings.MenuSection.deleteAccountMessage)
            self?.viewModel.trackDeleteAccountEvent()
        }.store(in: &cancellables)
    }
    
    private func showLogoutAlert() {
        let alertController = UIAlertController(
            title: Strings.Alerts.logOut,
            message: Strings.Alerts.logOutMessage,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: Strings.Buttons.cancel, style: .cancel))
        alertController.addAction(UIAlertAction(title: Strings.Buttons.logOut, style: .default) { [weak self] _ in
            self?.viewModel.logout()
        })
        present(alertController, animated: true)
    }
}
