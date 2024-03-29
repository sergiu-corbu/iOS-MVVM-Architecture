# iOS-MVVM-Architecture
A project I worked on, but with no specifications related to the api/project resources.  Hybrid MVVM architecture

Tech Stack
 - Swift, SwiftUI, Combine, UIKit, AVFoundation, PassKit, PhotosUI, AgoraSDK, Sentry, Kingfisher, SwiftPackageManager

Flows - UI Part
 - relied heavily on reusable UI components (CollectionView, AVPlayer, Sliders, Etc)
 - developed a custom video player component using AVPlayer integrated with MVVM architecture.
 - utilized reusable UI components such as sliders for seeking through the video timeline and play/pause buttons.
 - implemented smooth animations for transitioning between different playback states (playing, paused, buffering).
 - ensured code isolation and separation of concerns by encapsulating video playback logic within ViewModel classes, making each screen testable.

Business Logic
  - used coordinators & subcoordinators for flow isolation / better management of states
  - it easy to understand how the app works. (Ex: RootCoordinator -> OnboardingCoordinator -> MainCoordinator -> TabBarCoordinator -> Tab1, Tab2, Tab3, etc)

Rest Services
   - each service is defined as a protocol -> gives the flexibility of injecting any implementation(mocked, rest api) and easily testable

User Management
 - user data -> saved locally into cache
 - session token & refresh token -> saved into Keychain
 - session invalidation mode

Outstanding Features
  - live streaming with Agora SDK (One Broadcaster to Many listeners)
  - follow / unfollow feature
  - sign in with email -> redirect into the app
  - deeplink handling / sharing of content
  - push notifications handling
  - video compression and upload to a server
  - image processing
  - complex flow for creating content
  - support for guest mode and user mode
  - custom HTTPClient service

Design Patterns used on this project:
 - Coordinator
 - Dependency Injection
 - Decorator
 - Facade
