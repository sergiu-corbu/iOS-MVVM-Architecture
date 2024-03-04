//
//  Strings.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation

struct Strings {
    
}

//MARK: - NavigationTitles
extension Strings {
    struct NavigationTitles {
        static let join = "See Live. Buy Now."
        static let profileSetup = "Set Up Your Profile"
        static let search = "Search"
        static let allProducts = "All Products"
        static let notifications = "Notifications"
        static let yourBag = "Your Bag"
        static let orders = "Orders"
        static let welcomeBack = "Welcome Back"
        static let applyAsACreator = "Apply as Creator"
        static let completeCreatorProfile = "Complete Your Creator Profile"
        static let addOtherPlatform = "Link Other Accounts"
        static let editSocialLinks = "Edit Socials"
        static let signIn = "Sign In"
        static let edtiProfile = "Edit Profile"
        static let editBio = "Edit Bio"
        static let settings = "Settings"
        static let favorites = "Favorites"
        
        static let addShippingAddress = "Add Shipping Address"
        
        //MARK: CreateContent
        static let personalDetails = "Personal Information"
        static let createContent = "Share Content"
        static let yourCollaborations = "Your Collaborations"
        static let chooseProducts = "Choose Products"
        static let setupRoom = "Production Suite"
        static let giftingRequest = "Gifting Request"
        
        //MARK: Product Detail
        static let productDetails = "Product Details"
        
        static let howShippingWorks = "How shipping works"
    }
}

//MARK: - Guest Onboarding
extension Strings {
    struct GuestOnboarding {
        static let firstMessage = "Tune in to see your favorite creators live"
        static let secondMessage = "Shop the world's most coveted brands"
        static let thirdMessage = "Apply to join our community of creators"
        
        static let allowNotifications = "Allow notifications to receive "
        static let exclusiveDiscounts = "exclusive discounts"
    }
}

//MARK: - Discover
extension Strings {
    struct Discover {
        static let featuredShows = "Featured Shows"
        static let discover = "Discover"
        static let topDeals = "Featured Top Deals"
        static let justDropped = "Just Dropped"
        static let shopByCreator = "Shop by Creator"
        static let topBrands = "Top Brands"
        static let upcoming = "Upcoming"
        static let hotDeals = "Hot Deals"
        static let mostPopular = "Most Popular"
        static let otherCreators = "Others"
        static let justHappened = "Just happened"
        static let applyAsCreatorTitle = "Apply to be a creator"
        static let productsAndBrands = "Products & Brands"
        static let showsAndCreators = "Shows & Creators"
    }
}

// MARK: - ShowDetail
extension Strings {
    struct ShowDetail {
        
        static func shareMessage(sender: String) -> String {
            return "Hey, watch " + sender + " here."
        }
        
        static let scheduledShowTitle = "Scheduled for"
        static let featuringProducts = "Featuring products from:"
        static let liveTag = "Live"
        static let showTooltipMessage = "Swipe to move to the next show"
        static let setNotificationsReminder = "Set a reminder for new shows"
        static let pushNotificationsMessage = "Set a reminder for this show and get notified when new shows are added"
        
        static let followCreatorTitle = "Be notified when this creator posts"
        static let followBrandTitle = "Be notified when this brand posts"
        static let followCreatorMessage = "You'll receive a notification when they create a new show so you can stay up-to-date."
        static let followBrandMessage = "You'll receive a notification when they create a new show so you can stay up-to-date."
        
        static let endLiveShowMessage = "Are you sure you want to end your live show?"
        static let liveStreamEnded = "The live has ended"
        static let broadcasterConnectionLostMessage = "The live is connecting"
        static let noInternetConnection = "Slow or no internet connection"
        static let connectingToLiveStreamMessage = "The video is connecting"
        static let startingLiveStreamMessage = "The live is connecting"
        
        static let comeBackLaterAlert = "Come back later"
        static let scheduledShowReminder = "Set reminder for my scheduled live shows"
        static let scheduledShowReminderMessage = "Get a notification to remind you about your upcoming scheduled live shows."
        static let setupRoomNotAvailableMessage = "You'll be able to enter the live 30 minutes before the scheduled start time"
        
        static let shopMyShow = "Shop my show"
    }
}

// MARK: - Profile
extension Strings {
    struct Profile {
        static let following = "Following"
        static let followers = "Followers"
        static let orders = "Orders"
        static let join = "Join"
        static let creator = "Creator"
        static let brand = "Brand"
        static let signInToUseFeatures = "Please sign in or create an account to access the ultimate destination for discovery"
        static let existentAccountQuestion = "Already have an account?"
        
        static let about = "About"
        static let shows = "Shows"
        static let favorites = "Favorites"
        static let myStore = "My Store"
        static let products = "Products"
        
        static func welcome(name: String) -> String {
            "Welcome \(name)."
        }
        
        static func shareMessage(sender: String) -> String {
            return "Hey, check out \(sender)"
        }
        
        static let scheduledShow = "Scheduled"
        static let goLive = "Go live"
        static let deleteAccountDescription: String = "This will erase your content and personal information permanently and you will no longer be able to claim your username."
        
        static let emptyProfileBioMessage = "The creator hasn't added any bio yet"
        static let bioTitle = "Bio"
        static let collaborationTitle = "Brand Collaborations"
        static let location = "Location"
        static let collaborationDescription = "Brands you go live with will be listed as collaborations"
        static let onTheWebTitle = "Other Links"
        
        static let notFollowingUserMessage = "Don’t miss out on upcoming shows and products from this creator."
    }
}

//MARK: Orders
extension Strings {
    struct Orders {
        static let emptyOrders = "Your orders will appear here"
        static func orderNumber(_ orderNumber: Int) -> String {
            return "Order #" + orderNumber.description
        }
        static func orderPlacedOn(_ orderDateString: String) -> String {
            return "Placed on: " + orderDateString
        }
        static func numberOfOrderedItems(_ quantity: Int) -> String {
            return "\(quantity) item".pluralizedIfNeeded(quantity)
        }
        static let delivery = "Delivery"
        static let paymentMethod = "Payment Method"
        static let orderSummary = "Order summary"
        static let totalPrice = "Total Price "
        static let items = "Items"
        static let shipping = "Shipping"
        static let total = "Total"
        static let applePay = "Apple Pay"
    }
}

// MARK: - Alerts
extension Strings {
    struct Alerts {
        static let logOut = "Log Out"
        static let logOutMessage = "You can always access your profile by signing back in."
        
        static let cancelActionTitle = "Are you sure you want to cancel?"
        static let cancelActionMessage = "This will result in the loss of all progress made up until this point."
        
        static let messageRemoved = "Message removed"
        static let goLiveMessage = "If you change your mind, you can apply to go live in your profile."
        
        static let mediaPermissionsNotGranted = "You need to grant media permissions in order to start a live stream"
        static let permissionsHintMessage = "This can be changed in your Settings."
        
        static let notificationsNotEnabled = "You need to grant notifications permissions in order to be notified when this creator posts a new show"
        static let remindersSet = "Reminder set"
    }
}

// MARK: - MenuSection
extension Strings {
    struct MenuSection {
        static let general = "Profile"
        static let support = "Support"
        static let appSettings = "App Settings"
        static let personalDetails = "Personal Information"
        static let contactUs = "Contact Us"
        static let privacyPolicy = "Privacy Policy"
        static let termsAndConditions = "Terms of Service"
        static let manageAccount = "Access and Control"
        static let deleteAccount = "Delete Account Permanently"
        static let deleteAccountMessage = "Hello, \nI would like to request the deletion of my account.\nThank you."
    }
}

// MARK: - MailClients
extension Strings {
    struct MailClients {
        static let mail = "Mail"
        static let gmail = "Gmail"
        static let yahooMail = "Yahoo Mail"
        static let outlook = "Outlook"
    }
}

//MARK: - Authentication
extension Strings {
    struct Authentication {
        static let emailAddressQuestion = "What's your email?"
        static let almostReadyToShop = "You're almost there..."
        static let detailsLeft = "Just a couple of details left"
        static let profileCompleted = "You're all set up"
        static let welcomeMessage = "WELCOME"
        static let mailConfirmationMessage = "Confirm your email"
        static let mainConfirmationInfo = "We’ve sent an email to "
        static let mainConfirmationMessage = "Click on the link in the email to verify your address"
        static let applicationReceived = "We've received your application."
        static let applicationReceivedDescription = "We will be in touch soon with the status of your application"
        static let reviewingApplication = "We'll review your application and get back to you"
        static let progress = "Progress"
        static let accountCreated = "Your account\n has been created"
        static let completeProfileTitle = "Complete Your Creator Profile"
        static let completeProfileMessage = "Completing your profile will help us review your application faster."
        static let step = "Step"
        
        static func thankYou(name: String) -> String {
            "Thank you \(name)."
        }
        
        static let creatorApproved = "You've been approved! Time to get creating."
        static let creatorFillProfileMessage = "Complete your creator profile so our community can get to know you better."
        static let fillProfileGuidance = "Make sure to:"
        
        //MARK: CreatorAuthentication
        static let linkHandlesMessage = "Let us know your social handles"
        static let approvalInfo = "This will help us in the approval process."
        static let brandOwnership = "Are you a brand owner?"
        static let brandWebsite = "Nice. We'd love to know what your brand's website is"
        static let allowToPromoteMyBrand = "Allow other creators to promote my brand"
        static let brandPartnerships = "Are you currently involved in any brand partnerships?"
        static let brandPartners = "With which brands?"
        static let receivedBrandProducts = "Do you currently have any products from these brands?"
        
        static let oneMoment = "Hold tight..."
        static let accountConfirmationMessage = "We're just confirming things. You'll be able to continue in a few seconds."
        static let joinUs = "Join Us"
        static let accountCreationMessage = "You need an account in order to view more content"
    }
}

//MARK: - ContentCreation
extension Strings {
    struct ContentCreation {
        static let uploadQuestion = "Time to create and curate. Choose a format."
        static let brandSelection = "Select the brand(s) you'll be promoting in your content"
        static let brandForGiftRequestMessage = "Select the brand from which you’d like to request products"
        static let collaborations = "Your Collaborations"
        static let productsSelectionMessage = "Please indicate which product(s) you'll feature in your show"
        static let productsRequestMessage = "Choose the products you'd like to receive"
        static let giftingInstructions = "Gifting instructions and requirements"
        static let noResults = "No results found."
        static let searchQueryIndication = "Please double check your spelling or try another search"
        static let uploadVideo = "Upload your main video"
        static let uploadTeaserVideo = "Upload teaser video"
        static let showTitle = "Add a title for your show"
        static let videoUploadFileTypeMessage = "Max. video length is 20 minutes"
        static let teaserUploadFileMessage = "Max. video length is 1 minute"
        static let uploadGuidelines = "By uploading a video you agree to our"
        static let publishingTimeSelection = "Publish"
        static let now = "Now"
        static let later = "Later"
        static let featuredProducts = "Featured products"
        static let videoThumbnailMessage = "Add a custom thumbnail"
        static let videoThumbnailDescription = "The first frame of your video will be the thumbnail for your show. You can also upload an image if you'd like to change it."
        
        static func numberOfProductsInSearch(_ productsCount: Int) -> String {
            let format = "Showing %@ products from:"
            return String(format: format, "\(productsCount)")
        }
        
        static let communityGuidelines = "Community Guidelines"
        static let uploadingVideoFile = "Uploading file"
        static let customThumbnail = "Custom Thumbnail"
        static let customThumbnailMessage = "This is how your show will appear to others"
        
        static let congratsMessage = "All done"
        static let showIsBeingPublished = "We're working on getting your show published"
        static let videoIsCompressing = "Video\nCompressing"
        static let videoIsUploading = "Video\nUploading"
        static let videoIsProcessing = "Video\nProcessing"
        static let videoIsProcessingDescription = "We'll notify you\non completion"
        
        static let scheduledShowUploaded = "Your show is scheduled"
        static let showUploaded = "Your show is ready to be watched"
        
        static let liveShowSetupSucceeded = "Exciting. Your live is all set up and ready to go."
        static let shareLiveShowLinkMessage = "Share your link with your followers on social. It will only be available to view once you've started your live."
        
        static let scheduledLiveStreamMessage = "Check – we've scheduled your live successfully."
        static let shareLiveStreamLinkMessage = "Share the link to your live with your followers on social:"
        static let linkCopiedMessage = "Link copied"
        static let productRequestQuestion = "Don't have product for your show?"
        static let deliveryAddress = "Delivery Address"
        static let phoneNumber = "Phone Number"
        static let requestedProducts = "Requested Products"
        static let productRequestSuccessMessage =  "Products request successful"
        static let brandConfirmationMessage = "The brand will get soon in touch with you."
        static let orderAndShippingConfirmation = "Look out for your order and shipping confirmation\nemail."
        
        static let videoCompressionAlertTitle = "Video compression in progress"
        static let videoCompressionAlertMessage = "Please don't leave the app just yet"
        static let videoCompressionFinalizedAlertTitle = "Video compression complete"
        static let videoCompressionFinalizedAlertMessage = "Your upload will continue in the background"
    }
}

//MARK: - Product Detail
extension Strings {
    struct ProductsDetail {
        static let buyWithApplePay = "Buy with Pay"
        
        static let sizeGuides = "Size & Fit"
        static let returnPolicy = "Return Policy"
        
        static func startingFromPrice(_ price: String?) -> String {
            return "From " + (price ?? "")
        }
        static func shareMessage(product: String, brand: String) -> String {
            return "Buy \(product) from \(brand) here:"
        }
        static let selectAllVariants = "Complete all selections"
        static let productBrandBagWarningTitle = "Your bag has products from\nanother brand"
        static let productBrandBagWarningMessage = "Adding products from another brand will delete your\nexisting products."
    }
}

extension Strings {
    enum Search {
        static var description = "Search for your favorite shows, creators,\nproducts or brands"
    }
}

//MARK: - Payment
extension Strings {
    struct Payment {
        static let paymentInProgress = "We're taking a moment to verify that every item in your order is exactly as it should be"
        static let shipping = "Shipping"
        static let discountCode = "Discount Code"
        static let discount = "Discount"
        static let discountCodeApplied = "Discount code applied"
        static let invalidDiscountCode = "Invalid discount code"
        
        static let continueShopping = "Continue Shopping"
        static let thankYouForOrder = "Thank You For Your Order"
        static func orderNumberMessage(_ orderNumber: Int) -> String {
            return "Your order confirmation number is\n" + "#\(orderNumber)"
        }
        
        static let contactInfo = "Contact Info"
        static let checkout = "Checkout"
        static let yourBag = "Your Bag"
        static let orderReview = "Review Order"
        static let orderConfirmationMessage = "Keep an eye out for your shipping confirmation email from"
        static let tax = "Tax"
        static let taxAndShipping = "Tax & Shipping"
        static let howTaxesAreCalculated = "Calculated at next step"
        static let soldBy = "Sold & Shipped by: "
        static let cardExpiration = "Expires"
        
        static let cartDeletionWarningTitle = "Your bag has products from\nanother brand"
        static let cartDeletionWarningMessage = "We currently only support checkout of multiple products from the same brand. Adding products from another brand will delete your existing shopping bag."
        
        static let paymentDetails = "Payment Details"
        static let secureTransactions = "All transactions are secure and encrypted."
        static let sameBillingAddress = "Use shipping address as billing address."
        static let creditCard = "Credit Card"
        static let savedCreditCard = "Saved Credit Card"
        static let expressCheckout = "Express Checkout"
        
        static let savedShippingAddress = "Saved Shipping"
        static let shippingMethod = "Shipping Method"
        static let shippingAddress = "Shipping Address"
        static let billingAddress = "Billing Address"
        static let billingInformation = "Billing Information"
        static let shippingMethodPlaceholder = "Enter your shipping address to view available\nshipping methods."
        static let saveShippingAddress = "Save my information for a faster checkout."
        static let transactionSecurityInformation = "All transactions are secure and encrypted."
        
        static let enterShipping = "Enter shipping address"
        static let calculatingShippingCost = "Calculating..."
        
        static func paymentLabel(brandName: String) -> String {
            return brandName
        }
    }
}

//MARK: - TextFieldScope
extension Strings {
    struct TextFieldScope {
        static let email = "Email Address"
        static let fullName = "Full Name"
        static let phoneNumber = "Phone number"
        static let postalCode = "Postal Code"
        static let address = "Address"
        static let city = "City"
        static let state = "State"
        static let country = "Country"
        static let username = "Username"
        static let website = "Your website"
        static let brands = "Brands"
        static let socialPlatform = "Platform Name"
        static let link = "Link"
        static let search = "Search"
        static let searchProduct = "Please type the name of the product"
        static let discountCode = "Discount Code"
    }
}

//MARK: - TextFieldScope
extension Strings {
    struct TextFieldHints {
        static let username = "Usernames can contain letters (a-z), numbers (0-9), and periods (.)"
        static let fullName = "This is used to process your orders"
        static let brandNotFound = "We can’t find any matches in our database. You can still add this brand manually."
        static let profileLink = "Type in the full URL so we can review your profile"
    }
}

//MARK: - Placeholders
extension Strings {
    struct Placeholders {
        static let email = "mail@domain.com"
        static let fullName = "Your full name"
        static let firstName = "First name"
        static let lastName = "Last name"
        static let username = "Please enter a username"
        static let comingSoon = "Coming soon..."
        static let phoneNumber = "Please enter phone number"
        static let city = "Please enter city"
        static let state = "Please enter a state"
        static let country = "Please enter country"
        static let selectCountry = "Select country"
        static let address = "Please enter address"
        static let postalCode = "Please enter postal code"
        static let featuredShows = "Your shows will appear here"
        static let addProfilePicture = "Add a profile picture"
        static let fillCreatorBio = "Fill in your bio"
        static let website = "www.namewebsite.com"
        static let platformName = "Please enter the name of the platform"
        static let profileLink = "Please enter the link to your profile"
        static let creatorShows = "You have no published shows\non right now."
        static func guestShows(owner: String) -> String {
            return "The \(owner) does not have any published shows\non right now."
        }
        static let creatorFavorites = "Products from your shows\nwill appear here."
        static func guestFavorites(owner: String) -> String {
            return "Products from the \(owner)'s shows\nwill appear here."
        }
        static let coverImage = "Add Cover Image"
        static let showTitle = "Write a title..."
        static let followers = "Followers will appear here"
        static let following = "Followed creators appear here"
        static let brands = "Followed brands appear here"
        static let generatingShareLink = "Generating share link..."
        static let discountCode = "Please enter discount code"
        static let discoverAnything = "Discover anything..."
        static let searchPlace = "Search for a place..."
        static let favoriteShows = "The shows that you add to favorites\nwill appear here"
        static let favoriteProducts = "The products that you add to favorites\nwill appear here"
        
        static let cardNumber = "Card Number"
    }
}

//MARK: - Buttons
extension Strings {
    struct Buttons {
        static let `continue` = "Continue"
        static let startDiscovering = "Start Discovering"
        static let explore = "Explore"
        static let createAnAccount = "Create An Account"
        static let signIn = "Sign In"
        static let applyToGoLive = "Apply To Be A Creator"
        static let apply = "Apply"
        static let orders = "Orders"
        static let favorites = "Favorites"
        static let logOut = "Log Out"
        static let cancel = "Cancel"
        static let openMail = "Open Mail"
        static let no = "No"
        static let yes = "Yes"
        static let add = "Add"
        static let addToBag = "Add To Bag"
        static let buyOnSenseWebsite = "Buy on SSENSE"
        static let placeOrder = "Place Order"
        static let skip = "Skip"
        static let getStarted = "Get Started"
        static let noWebsite = "I don’t have a website"
        static let other = "Other"
        static let done = "Done"
        static let editProfile = "Edit Profile"
        static let addBio = "Add Bio"
        static let addSocial = "Add Handle"
        static let createShow = "Create A Show"
        static let save = "Save"
        static let saveChanges = "Save Changes"
        static let edit = "Edit"
        static let close = "Close"
        static let dismiss = "Dismiss"
        
        static let goLive = "Go Live"
        static let uploadVideo = "Upload Video"
        static let publish = "Publish"
        static let clear = "Clear"
        static let clearAll = "Clear All"
        static let changeCover = "Change cover"
        static let schedule = "Schedule"
        static let submitRequest = "Sumbit Request"
        
        static let openSettings = "Open Settings"
        static let selectMoreVideos = "Select More Videos"
        static let keepPhotoSelection = "Keep Current Selection"
        
        static let `return` = "Return"
        static let seeAll = "See all"
        static let seeMore = "See more"
        static let seeLess = "See less"
        static let follow = "Follow"
        static let unfollow = "Unfollow"
        static let following = "Following"
        static let setReminder = "Set Reminder"
        static let remove = "Remove"
        static let endShow = "End Show"
        static let allow = "Allow"
        static let noThanks = "No, Thanks"
        
        static let more = "More"
        static let copyLink = "Copy link"
        static let addToCalendar = "Add To My Calendar"
        static let setupLiveShow = "Set Up Live"
        static let backToDiscover = "Back to Discover"
        static let update = "Update"
        static let authenticate = "Log In Or Sign Up"
        static let requestProduct = "Request Product"
        static let outOfStock = "Out Of Stock"
        static let checkout = "Checkout"
        static let filter = "Filter"
        static let applyFilters = "Apply Filters"
        static let resetFilters = "Reset All"
        static let searchLocation = "Search Location"
        
        static let brands = "Brands"
        static let creators = "Creators"
        static let products = "Products"
        static let shows = "Shows"
        static let howShippingWorks = "How it works"
        static let addProduct = "Add Product"
        
        static func confirmForShow(_ items: Int) -> String {
            let format = "Confirm for show (%@)"
            return String(format: format, "\(items)")
        }
        static func confirmForGifting(_ items: Int) -> String {
            let format = "Confirm for Gifting (%@)"
            return String(format: format, "\(items)")
        }
    }
}

//MARK: - Filter & Sort
extension Strings {
    struct FilterAndSort {
        static let lowToHigh = "Low to high"
        static let highToLow = "High to low"
        static let sortByPrice = "Sort by price"
        static let filterBy = "Filter by"
        
        static let all = "All"
        static let categories = "Categories"
        static let brands = "Brands"
        static let sizes = "Sizes"
    }
}

//MARK: - Others
extension Strings {
    struct Others {
        static let orderGratitude = "Thank you for your order."
        
        static let socialHandlesMessage = "You can add up to five external links that will be displayed on your profile."
        
        static func orderConfirmationNumber(confirmationNumber: String) -> String {
            "Your order confirmation number is \(confirmationNumber)"
        }
        
        static func shippingConfirmation(brand: String) -> String {
            "Look out for your shipping confirmation email from \(brand)"
        }
        
        static let bioMessage = "Please write a short description so our community can get to know you better"
        static let loadingResults = "Loading results"
        static let optional = "Optional"
        
        static let appUpdateAvailable = "New Version Available"
        static func appUpdateMessage(newVersion: String) -> String {
            return "Version \(newVersion) is now available on the App Store. We recommend you update the app so you can access the latest features."
        }
        static func appVersion(_ version: String) -> String {
            return "App Version " + version
        }
        static let newVersionAvailable = "New Version\nAvailable"
        static let forceUpdateMessage = "Get the latest version from the AppStore to keep using"
    }
}

//MARK: - Terms & Conditions
extension Strings {
    struct TermsAndConditions {
        static let continueAgreement = "By continuing I declare I am over 13 and agree to the"
        static let termsAndConditions = "Terms of Service"
        static let personalDataPrivacyMessage = "This will only be visible to the brand."
    }
}

//MARK: - Permissions
extension Strings {
    struct Permissions {
        
        static let videoPermissionMessage = "Would Like to Access Your Videos"
        
        static let videoAccessMessage = "You must grant Library access in order to upload your video"
        static let pushNotificationsPermissionTitle = "Don’t miss out on exclusive brand discounts"
        static let pushNotificationsPermissionMessage = "Enable push notifications now, we promise\nnot to spam you!"
    }
}

//MARK: - Shipping Details
extension Strings {
    
    struct ShippingDetails {
        
        static let goodToKnow = "Good To Know"
        static let payment = "Payment"
        static let shipping = "Shipping"
        static let returns = "Returns"
        static let questions = "Questions?"
        
        static let goodToKnowDetails = "When shopping, you are buying directly from the brands. We have a full integration and official partnership with all of the brands on our app."
        static let paymentDetails = "We use Apple Pay as our payment method to keep the checkout secure, quick and seamless."
        static let shippingDetails = "You will see shipping information (method and cost) after clicking the “Buy with Apple Pay” button. Don’t worry, you will still need to confirm the purchase with a double button press, so you can check the final price without any risk of an accidental transaction.\nYou'll get an order & shipping confirmation email from the brand, who will ship the product to you directly."
        static let returnsDetails = "To see the return policy for any item, click the product image to view products details. You will find the return policy there. You can also access it via the order confirmation email from the brand."
        static let questionsDetails = "If you have any questions about the purchase, get in touch! We’d love to hear from you."
    }
}
