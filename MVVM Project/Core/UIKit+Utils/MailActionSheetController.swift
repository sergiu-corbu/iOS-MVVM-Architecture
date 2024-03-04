//
//  MailActionSheetController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.11.2022.
//

import UIKit
import MessageUI

class MailActionSheetController: NSObject {
    
    weak var presentationViewController: UIViewController?
    let shouldComposeMessage: Bool
    let messageBody: String?
    
    init(presentationViewController: UIViewController?, shouldComposeMessage: Bool, messageBody: String? = nil) {
        self.presentationViewController = presentationViewController
        self.shouldComposeMessage = shouldComposeMessage
        self.messageBody = messageBody
        
        super.init()
        presentMailOptions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentMailOptions(animated: Bool = true) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        MailApp.allCases.forEach { mailApp in
            let uiApplication: UIApplication = .shared
            guard let mailURL = mailApp.createMailURL(includingComposePath: shouldComposeMessage),
                uiApplication.canOpenURL(mailURL) else {
                return
            }
            
            let mailAction = UIAlertAction(title: mailApp.name, style: .default) { [weak self] _ in
                if self?.shouldComposeMessage == true, mailApp == .mail {
                    self?.presentMailView(animated: animated)
                } else {
                    uiApplication.open(mailURL)
                }
            }
            alertController.addAction(mailAction)
        }
        alertController.addAction(UIAlertAction(title: Strings.Buttons.cancel, style: .cancel))
        presentationViewController?.present(alertController, animated: animated)
    }
    
    private func presentMailView(animated: Bool) {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setToRecipients([Constants.EMAIL_ADDRESS])
        if let messageBody {
            mailController.setMessageBody(messageBody, isHTML: false)
        }
        presentationViewController?.present(mailController, animated: animated)
    }
}

extension MailActionSheetController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
