//
//  UIAlertController+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 09.01.2023.
//

import Foundation
import UIKit

extension UIAlertController {
    
    static func dismissActionAlert(onReturn: (() -> Void)? = nil, destructiveAction: @escaping () -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: Strings.Alerts.cancelActionTitle,
            message: Strings.Alerts.cancelActionMessage,
            preferredStyle: .alert
        )
        let returnAction = UIAlertAction(title: Strings.Buttons.return, style: .cancel) { _ in
            onReturn?()
        }
        let cancelAction = UIAlertAction(title: Strings.Buttons.cancel, style: .destructive) { _ in
            destructiveAction()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(returnAction)
        
        return alertController
    }
    
    static func appUpdateAlert(newVersionAvailable: String) -> UIAlertController {
        let alertController = UIAlertController(
            title: Strings.Others.appUpdateAvailable,
            message: Strings.Others.appUpdateMessage(newVersion: newVersionAvailable),
            preferredStyle: .alert
        )
        let updateButton = UIAlertAction(title: Strings.Buttons.update, style: .default) { (action: UIAlertAction) in
            UIApplication.shared.tryOpenURL(Constants.APP_APPSTORE_URL)
        }
        alertController.addAction(updateButton)
        
        return alertController
    }
}
