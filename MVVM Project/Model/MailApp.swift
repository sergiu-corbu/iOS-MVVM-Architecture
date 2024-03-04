//
//  MailApp.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 04.11.2022.
//

import Foundation

enum MailApp: String, CaseIterable {
    
    case mail = "message://"
    case gmail = "googlegmail://"
    case yahoo = "ymail://mail/"
    case outlook = "ms-outlook://"
    
    var name: String {
        switch self {
        case .mail: return Strings.MailClients.mail
        case .gmail: return Strings.MailClients.gmail
        case .yahoo: return Strings.MailClients.yahooMail
        case .outlook: return Strings.MailClients.outlook
        }
    }
    
    private var composePath: String {
        switch self {
        case .mail: return ""
        case .gmail: return "co?to=support@join.co"
        case .yahoo, .outlook: return "compose?to=support@join.co"
        }
    }
    
    func createMailURL(includingComposePath: Bool) -> URL? {
        var mailString = self.rawValue
        if includingComposePath {
            mailString.append(composePath)
        }
        
        return URL(string: mailString)
    }
}
