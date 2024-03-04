//
//  PushNotificationsInteractor.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.04.2023.
//

import Foundation
import Combine

protocol PushNotificationsInteractorProtocol {
    
    func processPushNotification(type pushNotificationType: PushNotificationType, objectID: String) async

    var newShowPublished: PassthroughSubject<Show, Never> { get }
    var creatorShouldOpenSetupRoom: PassthroughSubject<Show, Never> { get }
    var creatorShowStatusChanged: PassthroughSubject<String, Never> { get }
    var favoritesReminderPublisher: PassthroughSubject<FavoriteType, Never> { get }
}

class PushNotificationsInteractor: PushNotificationsInteractorProtocol {
    
    let newShowPublished = PassthroughSubject<Show, Never>()
    let creatorShouldOpenSetupRoom = PassthroughSubject<Show, Never>()
    let creatorShowStatusChanged = PassthroughSubject<String, Never>()
    let favoritesReminderPublisher = PassthroughSubject<FavoriteType, Never>()
    
    private let showService: ShowRepositoryProtocol
    
    init(showService: ShowRepositoryProtocol) {
        self.showService = showService
    }
    
    func processPushNotification(type pushNotificationType: PushNotificationType, objectID: String) async {
        do {
            switch pushNotificationType {
            case .newShowPosted, .showWasPublished:
                try await handlePublicShowPushNotification(showID: objectID)
            case .creatorShouldStartLiveSoon, .creatorShouldStartLive:
                try await handleCreatorPushNotification(showID: objectID)
            case .liveTurnedToPublished, .videoConverted:
                creatorShowStatusChanged.send(objectID)
            case .favoriteShowsReminder:
                favoritesReminderPublisher.send(.shows)
            case .favoriteProductsReminder:
                favoritesReminderPublisher.send(.products)
            }
        } catch {
            ToastDisplay.showErrorToast(error: error)
        }
    }

    //MARK: - Push Notification handling
    private func handleCreatorPushNotification(showID: String) async throws {
        guard let scheduledShow = try await showService.getCreatorShow(id: showID) else {
            return
        }
        
        creatorShouldOpenSetupRoom.send(scheduledShow)
    }
    
    private func handlePublicShowPushNotification(showID: String) async throws {
        guard let publicShow = try await showService.getPublicShow(id: showID) else {
            return
        }
            
        newShowPublished.send(publicShow)
    }
}
