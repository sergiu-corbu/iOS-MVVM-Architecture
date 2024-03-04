//
//  UIView+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 05.12.2022.
//

import UIKit

extension UIView {
    
    func constrainAllMargins(with other: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: other.topAnchor),
            bottomAnchor.constraint(equalTo: other.bottomAnchor),
            leadingAnchor.constraint(equalTo: other.leadingAnchor),
            trailingAnchor.constraint(equalTo: other.trailingAnchor)
        ])
    }
}
