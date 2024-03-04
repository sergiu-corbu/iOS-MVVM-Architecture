//
//  AccountValidationViewModel.swift
//  Bond
//
//  Created by Mihai Mocanu on 09.11.2022.
//

import Combine

class AccountValidationViewModel: ObservableObject {
    
    let onBackNavigation = PassthroughSubject<Void, Never>()
    let onOpenMail = PassthroughSubject<Void, Never>()
}
