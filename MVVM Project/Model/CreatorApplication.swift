//
//  CreatorApplication.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.11.2022.
//

import Foundation

struct CreatorApplication {
    
    let brandWebsite: String?
    let brands: [Brand]
    let allowsBrandPromotion: Bool
    let creartorOwnsBrand: Bool
    let creatorHasPartnerships: Bool
    
    enum Keys: String, CodingKey {
        case brandWebsite = "brandWebsiteUrl"
        case brands = "ambassadorBrands"
        case creatorHasPartnerships = "hasPartnerships"
        case allowsBrandPromotion = "allowsPromotion"
        case creartorOwnsBrand = "ownsBrand"
    }
}
