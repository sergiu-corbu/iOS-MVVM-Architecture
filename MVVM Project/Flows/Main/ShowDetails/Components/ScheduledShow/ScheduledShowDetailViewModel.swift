//
//  ScheduledShowDetailViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.04.2023.
//

import Foundation
import Combine

class ScheduledShowDetailViewModel: ObservableObject {

    //MARK: Properties
    @Published private(set) var isLoading = false
    @Published private(set) var uniqueFeaturedBrands: [Brand]?
    @UserDefault(key: UserSession.StorageKeys.reminderShowIDs, defaultValue: Dictionary<String, Bool>())
    private static var reminderShowIDs: [String : Bool]
    
    let show: Show
    let configureForConsumer: Bool
    
    var shouldDisplayShowCountDownTimer: Bool {
        return show.status == .scheduled && show.publishingDate?.isLessThanOneDay == true
    }
    var shouldDisplaySetReminderButton: Bool {
        return show.status == .scheduled && configureForConsumer && !isReminderSetForShow
    }
    private var isReminderSetForShow: Bool
    private var fcmToken: String?
    private var cancellable: AnyCancellable?
    
    //MARK: Actions
    enum Action {
        case scheduledTimerFinished
        case setReminderForShow
        case selectBrand(Brand)
    }
    
    let scheduledShowActionHandler: (Action) -> Void
    var onErrorReceived: ((Error) -> Void)?
    
    //MARK: Services
    let pushNotificationsPermissionHandler: PushNotificationsPermissionHandler
    let showService: ShowRepositoryProtocol
    
    init(show: Show, pushNotificationsPermissionHandler: PushNotificationsPermissionHandler, showService: ShowRepositoryProtocol,
         configureForConsumer: Bool = true, scheduledShowActionHandler: @escaping (Action) -> Void) {
        
        self.show = show
        self.configureForConsumer = configureForConsumer
        self.scheduledShowActionHandler = scheduledShowActionHandler
        self.pushNotificationsPermissionHandler = pushNotificationsPermissionHandler
        self.showService = showService
        self.isReminderSetForShow = Self.reminderShowIDs[show.id] != nil
        self.fcmToken = pushNotificationsPermissionHandler.pushNotificationsTokenPublisher.value
        self.cancellable = pushNotificationsPermissionHandler.pushNotificationsTokenPublisher
            .sink { [weak self] token in
                guard let self, self.fcmToken != token else { return }
                self.fcmToken = token
                Task(priority: .userInitiated) {
                    await self.setReminderForScheduledShow()
                }
            }
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    //MARK: Show reminder
    @MainActor
    func setReminderForScheduledShow() async {
        guard show.status == .scheduled, let pushNotificationToken = fcmToken, configureForConsumer, !isReminderSetForShow else {
            return
        }
        isLoading = true
        do {
            try await showService.setShowReminder(id: show.id, fcmToken: pushNotificationToken)
            Self.reminderShowIDs.updateValue(true, forKey: show.id)
            isReminderSetForShow = true
            scheduledShowActionHandler(.setReminderForShow)
            self.objectWillChange.send()
        } catch {
            onErrorReceived?(error)
        }
        isLoading = false
    }
    
    func handleSetReminderAction() async -> Bool {
        let shouldRequestNotificationPermission = await pushNotificationsPermissionHandler.shouldRequestPermission()
        if !shouldRequestNotificationPermission, fcmToken != nil {
            await setReminderForScheduledShow()
        }
        return shouldRequestNotificationPermission
    }
    
    func updateFeaturedBrands(_ featuredBrands: [Brand]?) {
        guard let featuredBrands else {
            return
        }
        self.uniqueFeaturedBrands = Array(Set(featuredBrands)).sorted(using: KeyPathComparator(\.name, order: .forward))
    }
}
