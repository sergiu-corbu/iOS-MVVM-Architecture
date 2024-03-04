//
//  Errors.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.10.2022.
//

import Foundation

enum AuthenticationError: String, LocalizedError {
    
    case invalidEmail = "Please enter a valid email format"
    case invalidFullname = "Your name must not be empty"
    case invalidUsername = "Your username should have between 2 and 30 characters"
    case invalidWebsite = "Please enter a valid website format"
    case invalidPlatformName = "The platform name should not be empty"
    case invalidSocialNetwork = "Invalid format"
    
    var errorDescription: String? {
        return self.rawValue
    }
}

enum DeliveryContactError: String, LocalizedError {
    
    case fieldIsEmpty = "This field must not be empty"
    
    var errorDescription: String? {
        return self.rawValue
    }
}

enum MediaError: String, LocalizedError {
    
    case missingMediaFile = "The requested media file was not found"
    case accessDeniedForMediaFile = "You need to provide permission in order to select this video"
    case videoCompressionFailure = "Video compression completed with error"
    case videoTooLarge = "The video should have be between one second and 20 minutes in length"
    case teaserTooLarge = "The teaser video should be between one second and one minute in length"
    case assetTooLarge
    
    var errorDescription: String? {
        return self.rawValue
    }
}

enum PaymentError: String, LocalizedError {
    
    case missingContactInformation = "Missing contact information"
    case missingShippingInformation = "Please update your shipping information"
    case missingBillingInformation = "Please update your billing information"
    case deliveryNotAvailable = "This merchant does not offer shipping to your country."
    case applePayError = "Couldn't set up Apple Pay. Please check that you have a valid card set up"
    case missingPaymentIntent = "Some information is missing. Please try again later"
    case productOutOfStock = "The selected product is out of stock"
    case invalidDiscountCode = "Invalid discount code"
    case expiredDiscountCode = "Expired discount code"
    
    var errorDescription: String? {
        return self.rawValue
    }
}

enum LiveStreamError: String, LocalizedError {
    
    case mediaPermissionsDenied = "You need to grant media permissions in order to start a live stream"
    case missingChannelName = "The channel is missing. Please try again later"
    
    var errorDescription: String? {
        return self.rawValue
    }
}

enum LiveStreamSelectionError: String, Error {
    
    case setupRoomNotAvailable
    case mediaPermissionsNotGranted
}
