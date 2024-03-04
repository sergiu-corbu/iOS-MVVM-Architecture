//
//  UINavigationController+Util.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 31.07.2023.
//

import UIKit

extension UINavigationController {

  public func pushViewController(_ viewController: UIViewController,
                                 animated: Bool,
                                 completion: (() -> Void)? = nil) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }

}
