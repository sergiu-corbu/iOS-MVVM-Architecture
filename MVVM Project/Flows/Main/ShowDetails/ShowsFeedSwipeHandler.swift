//
//  ShowsFeedSwipeHandler.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 12.07.2023.
//

import Foundation
import Combine

/// - Note: The current business logic does not require the use of this helper class. It is ignored
class ShowsFeedSwipeHandler {
    
    //MARK: - Properties
    let maxShowSwipes: Int
    let currentUserPublisher: CurrentValueSubject<User?, Never>
    let currentShowSelectionPublisher: PassthroughSubject<String, Never>
    let authenticationRestrictionEnabled: Bool
    
    @UserDefault(key: "swipedShowsIds", defaultValue: Array<String>())
    private var swipedShowsIds: [String]
    
    //MARK: - Computed
    var isUserAuthenticated: Bool {
        return currentUserPublisher.value != nil
    }
    var showAuthenticationRestriction: Bool {
        guard authenticationRestrictionEnabled else {
            return false
        }
        return swipedShowsIds.count > maxShowSwipes - 1 && !isUserAuthenticated
    }
    
    init(authenticationRestrictionEnabled: Bool = true, maxShowSwipes: Int = 2,
         currentUserPublisher: CurrentValueSubject<User?, Never>,
         currentShowSelectionPublisher: PassthroughSubject<String, Never>) {
        
        self.authenticationRestrictionEnabled = authenticationRestrictionEnabled
        self.maxShowSwipes = maxShowSwipes
        self.currentUserPublisher = currentUserPublisher
        self.currentShowSelectionPublisher = currentShowSelectionPublisher
    }
    
    //MARK: - Functionality
    @discardableResult
    func processSwipeToShowAction(id: String) -> Bool {
        guard authenticationRestrictionEnabled, !isUserAuthenticated else {
            return false
        }
        
        if !swipedShowsIds.contains(id), !showAuthenticationRestriction {
            swipedShowsIds.append(id)
        }
        return showAuthenticationRestriction
    }
}
