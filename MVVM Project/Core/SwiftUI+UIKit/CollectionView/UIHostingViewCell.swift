//
//  UIHostingViewCell.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 25.01.2023.
//

import Foundation
import UIKit
import SwiftUI

class UIHostingViewCell<CellContent: View>: UICollectionViewCell {
    
    private var contentHostingController: UIHostingController<CellContent>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    override func prepareForReuse() {
        contentHostingController?.view.removeFromSuperview()
        contentHostingController = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with content: CellContent) {
        addHostingController(view: content)
    }

    private func addHostingController(view: CellContent) {
        contentHostingController?.view.removeFromSuperview()
        
        let contentHostingController = UIHostingController(rootView: view)
        self.contentHostingController = contentHostingController
        contentHostingController.view.backgroundColor = .clear
        contentHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentHostingController.view)
        contentHostingController.view.constrainAllMargins(with: self)
    }
}

extension UIHostingViewCell {
    static var reuseIdentifier: String {
        return "UIHostingViewCellIdentifier"
    }
}
