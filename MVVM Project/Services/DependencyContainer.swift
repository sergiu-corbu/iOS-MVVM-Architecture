//
//  DependencyContainer.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 07.11.2022.
//

import Foundation

class DependencyContainer {
    
    var tabBarController: (() -> TabBarController?)?
    var forceAppUpdateMiddleware: ForceUpdateMiddleware?
    let authenticationService: AuthenticationServiceProtocol
    let creatorService: CreatorServiceProtocol
    let brandService: BrandServiceProtocol
    let showRepository: ShowRepository
    let contentCreationService: ContentCreationServiceProtocol
    let deeplinkService: DeeplinkService
    let userRepository: UserRepository
    let guestUserRepository: GuestUserRepository
    let uploadService: AWSUploadServiceProtocol
    let checkoutService: CheckoutServiceProtocol
    let liveStreamService: LiveStreamServiceProtocol
    let orderService: OrderServiceProtocol
    let pushNotificationsManager: PushNotificationsManager
    let followService: FollowServiceProtocol
    let productService: ProductServiceProtocol
    let searchService: SearchServiceProtocol
    let promotionalBannerContentProvider: PromotionalBannerContentProviderProtocol
    let favoritesService: FavoritesServiceProtocol
    let favoritesManager: FavoritesManager
    let checkoutCartManager: CheckoutCartManager
    let userSession = UserSession()
    
    let httpClient: HTTPClient
    
    lazy var showVideoStreamBuilder: ShowVideoStreamBuilder = {
        return ShowVideoStreamBuilder(
            showRepository: showRepository,
            liveStreamService: liveStreamService,
            deeplinkProvider: deeplinkService,
            userRepository: userRepository,
            pushNotificationsHandler: pushNotificationsManager,
            followService: followService,
            favoritesManager: favoritesManager
        )
    }()
    lazy var justDroppedProductsDataStore = JustDroppedProductsDataStore(productService: productService)
    
    init(httpClient: HTTPClient) {
        self.authenticationService = AuthenticationService(client: httpClient)
        self.creatorService = CreatorService(client: httpClient)
        self.brandService = BrandService(client: httpClient)
        self.userRepository = UserRepository(userService: UserService(client: httpClient), creatorService: creatorService)
        self.guestUserRepository = GuestUserRepository(userSession: userSession, authenticationService: authenticationService)
        let favoriteService = FavoritesService(client: httpClient)
        self.favoritesManager = FavoritesManager(favoritesService: favoriteService, currentUserPublisher: userRepository.currentUserSubject)
        self.showRepository = ShowRepository(showSevice: ShowService(client: httpClient), favoritesManager: favoritesManager)
        self.uploadService = AWSUploadService(client: httpClient)
        self.contentCreationService = ContentCreationService(client: httpClient)
        self.checkoutService = CheckoutService(client: httpClient)
        self.orderService = OrderService(client: httpClient)
        self.followService = FollowService(client: httpClient)
        self.pushNotificationsManager = PushNotificationsManager(
            pushNotificationsService: PushNotificationsService(client: httpClient),
            interactor: PushNotificationsInteractor(showService: showRepository),
            userSession: userSession
        )
        self.httpClient = httpClient
        self.deeplinkService = DeeplinkService()
        self.productService = ProductService(client: httpClient)
        self.searchService = SearchService(client: httpClient)
        self.liveStreamService = LiveStreamService(client: httpClient)
        self.promotionalBannerContentProvider = PromotionalBannerContentRepository(client: httpClient)
        self.checkoutCartManager = CheckoutCartManager(checkoutService: checkoutService,
                                                       sessionPublisher: userSession.isValidSessionPublisher)
        self.favoritesService = favoriteService
    }
    
    init(authenticationService: AuthenticationServiceProtocol,
         uploadService: AWSUploadServiceProtocol,
         creatorService: CreatorServiceProtocol,
         brandsService: BrandServiceProtocol,
         showRepository: ShowRepositoryProtocol,
         contentCreationService: ContentCreationServiceProtocol,
         deeplinkService: DeeplinkService,
         userRepository: UserRepository,
         checkoutService: CheckoutServiceProtocol,
         liveStreamService: LiveStreamServiceProtocol,
         orderService: OrderServiceProtocol,
         pushNotificationsService: PushNotificationsServiceProtocol,
         followService: FollowServiceProtocol,
         productService: ProductServiceProtocol,
         searchService: SearchServiceProtocol,
         favoritesService: FavoritesServiceProtocol,
         promotionalBannerContentProvider: PromotionalBannerContentProviderProtocol,
         httpClient: HTTPClient,
         forceAppUpdateMiddleware: ForceUpdateMiddleware
    ) {
        self.authenticationService = authenticationService
        self.creatorService = creatorService
        self.brandService = brandsService
        self.favoritesManager = FavoritesManager(favoritesService: favoritesService, currentUserPublisher: userRepository.currentUserSubject)
        self.showRepository = ShowRepository(showSevice: ShowService(client: httpClient), favoritesManager: favoritesManager)
        self.contentCreationService = contentCreationService
        self.deeplinkService = deeplinkService
        self.userRepository = userRepository
        self.guestUserRepository = GuestUserRepository(userSession: userSession, authenticationService: authenticationService)
        self.checkoutService = checkoutService
        self.uploadService = uploadService
        self.orderService = orderService
        self.pushNotificationsManager = PushNotificationsManager(
            pushNotificationsService: pushNotificationsService,
            interactor: PushNotificationsInteractor(showService: showRepository), userSession: userSession
        )
        self.followService = followService
        self.httpClient = httpClient
        self.liveStreamService = liveStreamService
        self.productService = productService
        self.searchService = searchService
        self.favoritesService = favoritesService
        self.promotionalBannerContentProvider = promotionalBannerContentProvider
        self.checkoutCartManager = CheckoutCartManager(checkoutService: checkoutService,
                                                       sessionPublisher: userSession.isValidSessionPublisher)
        self.forceAppUpdateMiddleware = forceAppUpdateMiddleware
    }
}

class DependencyContainerBuilder {
    
    let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    init() {
        self.httpClient = HTTPClient(configuration: DefaultClientConfiguration())
    }
    
    func createDependencyContainer() -> DependencyContainer {
        let dependencyContainer = DependencyContainer(httpClient: httpClient)
        dependencyContainer.userSession.userProvider = dependencyContainer.userRepository
        createHTTPClientMiddlewares(dependencyContainer: dependencyContainer)
        
        return dependencyContainer
    }
    
    private func createHTTPClientMiddlewares(dependencyContainer: DependencyContainer) {
        let userSessionMiddleware = UserSessionMiddleware(dependencyContainer.userSession, authenticationService: dependencyContainer.authenticationService)
        httpClient.addMiddleware(userSessionMiddleware)
        
        let forceAppUpdateMiddleware = ForceUpdateMiddleware()
        httpClient.addMiddleware(forceAppUpdateMiddleware)
        dependencyContainer.forceAppUpdateMiddleware = forceAppUpdateMiddleware
    }
}
