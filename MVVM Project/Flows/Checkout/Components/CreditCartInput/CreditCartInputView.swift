//
//  CreditCartInputView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.12.2023.
//

import SwiftUI

struct CreditCartInputView: View {
    
    @ObservedObject var viewModel: CreditCartInputViewModel
    
    var body: some View {
        STPPaymentCardInputView(paymentMethodParams: $viewModel.creditCardParameters)
            .frame(height: 56)
            .background(Color.beige, in: RoundedRectangle(cornerRadius: 5))
            .padding(.horizontal, -16)
            .modifier(ValidationInputFieldStyle(error: viewModel.inputFieldErrors[.creditCard], hint: nil, focusDelay: nil))
            .onAppear {
                viewModel.analyticsService.toggleUXOcclusion(true)
            }
            .onDisappear {
                viewModel.analyticsService.toggleUXOcclusion(false)
            }
    }
}

#if DEBUG
#Preview {
    CreditCartInputView(viewModel: .init())
}
#endif
