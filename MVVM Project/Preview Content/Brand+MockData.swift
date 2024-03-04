//
//  Brand+MockData.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.11.2022.
//

import Foundation

#if DEBUG
extension PartnershipBrand {
    
    static let tommyHilfiger = PartnershipBrand(name: "Tommy Hilfiger")
    static let ralphLauren = PartnershipBrand(name: "Ralph Lauren")
    static let gucci = PartnershipBrand(name: "Gucci")
    static let robertoCavalli = PartnershipBrand(name: "Roberto Cavalli")
    static let armani = PartnershipBrand(name: "Armani")
    static let calvinKlein = PartnershipBrand(name: "CalvinKlein")
    static let baldinini = PartnershipBrand(name: "Baldinini")
    static let bottegaVeneta = PartnershipBrand(name: "Bottega Veneta")
    
    static var allBrands: [Self] {
        [tommyHilfiger, ralphLauren, gucci, robertoCavalli, armani, calvinKlein, baldinini, .bottegaVeneta]
    }
}

extension Brand {
    
    static let tommyHilfiger = Brand(name: "Tommy Hilfiger", logoPictureURL: URL.sampleImageURL, followerCount: 123, sizeGuides: "This is a sizing guide")
    static let ralphLauren = Brand(name: "Ralph Lauren")
    static let gucci = Brand(name: "Gucci")
    static let robertoCavalli = Brand(name: "Roberto Cavalli")
    static let armani = Brand(name: "Armani", city: "Cluj-Napoca", country: "Romania")
    static let calvinKlein = Brand(name: "CalvinKlein")
    static let baldinini = Brand(name: "Baldinini")
    static let bottegaVeneta = Brand(name: "Bottega Veneta", sizeGuides: "Random size guides", returnPolicy: "Some return policy")
    
    static var allBrands: [Self] {
        [tommyHilfiger, ralphLauren, gucci, robertoCavalli, armani, calvinKlein, baldinini, .bottegaVeneta]
    }
}
#endif
