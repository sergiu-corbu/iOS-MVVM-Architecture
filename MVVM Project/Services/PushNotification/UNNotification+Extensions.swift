//
//  UNNotification+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 12.04.2023.
//

import UserNotifications

extension UNNotification {
        
    var userInfoData: [String:Any]? {
        let userInfo = self.request.content.userInfo
        return userInfo["data"] as? [String: Any]
    }
}
