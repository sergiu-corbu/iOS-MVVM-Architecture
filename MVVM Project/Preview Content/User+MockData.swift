//
//  User + MockData.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation

#if DEBUG
extension User {
    
    init(email: String, fullName: String, username: String, role: User.Role) {
        self.id = UUID().uuidString
        self.email = email
        self.fullName = fullName
        self.username = username
        self.role = role
        self.profilePictureUrl = .sampleImageURL
        self.socialNetworks = SocialNetworkHandle.all
        self.partnershipBrands = [.armani, .baldinini,.robertoCavalli]
        self.bio = "This is a bio"
        self.livestreamUserID = 0
        self.numberOfOrders = Int.random(in: 0...10)
        self.createdAt = Date.now.dateString(formatType: .defaultDate)
        self.addresses = []
        self.phoneNumber = "7337372941"
    }
    
    static let customer = User(email: "sergiu@icloud.com", fullName: "Sergiu Corbu", username: "sergiu_c", role: .shopper)
    static let customer1 = User(email: "sergiu@icloud.com", fullName: "Daniel Orsato", username: "sergiu_c", role: .shopper)
    static let creator = User(email: "sergiu@icloud.com", fullName: "Daniel Simmons", username: "sergiu_c", role: .creator)
    static let creator1 = User(email: "sergiu@icloud.com", fullName: "Allysa Maz", username: "sergiu_c", role: .creator)
    
    static var mockUsers: [User] {
        return [.creator, customer, .creator1, .customer1]
    }
}
#endif
