//
//  Analytics+Events.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.05.2023.
//

import Foundation

extension AnalyticsService {
        
    //MARK: User traits
    enum UserTrait: String {
        case user_id
        case username
        case email
        case createdAt
        case account_type
        case notification_permission
        case total_orders
        case app_locale
    }
    
    //MARK: Properties
    enum EventProperty: String {
        case name
        case source
        
        //user & creator
        case creator_id
        case creator_username
        case username
        
        //show
        case show_id
        case show_name
        case show_type
        case is_teaser
        case scrub_value = "seconds_mark"
        
        //eCommerce
        case order_id
        case affiliation
        case total
        case revenue
        case shipping
        case tax
        case currency
        case buy_with_apple_pay
        case buy_with_credit_card
        case checkout_step
        
        //search
        case search_text
        case search_filter
        case search_result
        
        //product
        case products
        case brand
        case brands
        case product_id
        case product_variant = "variant"
        case product_price = "price"
        case product_position = "position"
        case product_image_url = "url"
        case quantity
        case sku_id = "sku"
        
        //brand
        case brand_id
        case brand_name
        
        //registration
        case registration_step = "step"
        case account_name
        case context
        case account_id = "group_id"
        case registrationSource = "registration_source"
        
        //deeplink
        case deep_link_url
        
        //gifting
        case start_gifting_flow = "start_gifting_request_flow"
        case select_gifting_brand = "select_brand"
        case select_gifting_product = "select_product_details"
        case review_gifting_delivery_details = "review_delivery_details"
        case submit_gifting_request
        case submit_gifting_success_screen
        
        //follow
        case follow_type = "followed_type"
        case followed_id = "followed_id"
        
        //promotional banner
        case promotional_banner_type
        case promotional_banner_title
        
        //checkout
        case cart_id
    }
    
    //MARK: Events
    enum ScreenEvent: String {
        case featured
        case discovery
        case personal_profile = "Personal Profile"
        case creator_profile = "Creator Profile"
        case brand_profile = "Brand Profile"
        case orders
        case search
    }
    
    enum ActionEvent: String {
        case appInstall = "Install"
        case action_tap = "Action Tap"
        
        //checkout
        case orderCompleted = "Order Completed"
        case add_product_to_cart = "Product Added to Cart"
        case remove_product_from_cart = "Product Removed from Cart"
        case cart_created = "Cart Created"
        case cart_deleted = "Cart Deleted"
        case checkout_cart_opened = "Bag Details"
        case discount_applied = "Discount Applied"
        case discount_removed = "Discount Removed"
        case creditCardCheckoutProgress = "Checkout Progress"
        
        //show
        case show_view_start = "Show View Start"
        case show_view_end = "Show View End"
        case show_scrub = "Show Scrub"
        
        //profile
        case select_creator_favorite_product = "Select Creator Favorite Product"
        case select_creator_show = "Select Creator Show"
        case select_brand_collaboration = "Select Brand Collaboration"
        case select_brand_product = "Select Brand Product"
        
        //search
        case search_action = "Search Action"
        case search_field_selection = "Search Type"
        case search_filter_selection = "Search Filter"
        case search_result_selection = "Search Result Selection"
        
        //registration
        case shopper_registration_steps = "Shopper Registration Steps"
        case creator_registration_steps = "Creator Registration Steps"
        case account_created = "Account Created"
        case account_deleted = "Account Deleted"
        case signed_in = "Signed In"
        case signed_out = "Signed Out"
        
        //deeplink
        case deeplinkOpened = "Deep Link Opened"
        
        //product
        case product_clicked = "Product Clicked"
        case product_viewed = "Product Viewed"
        case product_zoom = "Product Zoom"
        case ssense_product_selected = "Buy on SSENSE Tapped"
        case affiliate_product_selected = "Affiliate Product Tapped"
        
        case creator_gifting_steps = "Creator Gifting Steps"
        
        //favorites
        case add_to_favorites = "Add to Favorites"
        case remove_from_favorites = "Remove from Favorites"
        case see_favorite_shows = "See Favorite Shows"
        case see_favorite_products = "See Favorite Products"
        
        //follow
        case follow_brand = "Follow Brand"
        case follow_creator = "Follow Creator"
        case unfollow_brand = "Unfollow Brand"
        case unfollow_creator = "Unfollow Creator"
        
        //promo banners
        case select_promo_banner = "Promo Banner"
        
        var skadEventValue: Int? {
            switch self {
            case .appInstall: return 0
            case .show_view_start: return 10
            case .account_created: return 20
            case .orderCompleted: return 63
            default: return nil
            }
        }
    }
}
