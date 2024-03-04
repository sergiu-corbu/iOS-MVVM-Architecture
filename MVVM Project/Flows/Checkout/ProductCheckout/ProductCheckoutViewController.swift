//
//  ProductCheckoutViewController.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.01.2024.
//

import Foundation
import Stripe
import SwiftUI

class ProductCheckoutViewController: UIHostingController<ProductCheckoutView> {
    
    let viewModel: ProductCheckoutViewModel
    
    init(viewModel: ProductCheckoutViewModel) {
        self.viewModel = viewModel
        super.init(rootView: ProductCheckoutView(viewModel: viewModel))
        self.viewModel.stpAuthenticationContext = self
        
        viewModel.onEditCheckout = { [weak self] section in
            self?.showEditCheckoutSection(checkoutSectionType: section, animated: true)
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Edit Checkout Details
    private func showEditCheckoutSection(checkoutSectionType: CheckoutSectionType, animated: Bool) {
        let editCheckoutVM = EditCheckoutSectionViewModel(
            checkoutSectionType: checkoutSectionType,
            productCheckoutViewModel: viewModel,
            onDismiss: { [weak self] in
                self?.navigationController?.popViewController(animated: animated)
            }
        )
        navigationController?.pushHostingController(EditCheckoutSectionView(viewModel: editCheckoutVM), animated: animated)
    }
}

extension ProductCheckoutViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
