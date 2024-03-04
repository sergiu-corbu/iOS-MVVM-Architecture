//
//  GuestOnboardingView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 01.11.2022.
//

import SwiftUI

struct GuestOnboardingView: View {
    
    @ObservedObject var viewModel: GuestOnboardingViewModel
    @State private var showNotificationsPermission = false
    
    private let animationDuration: TimeInterval = 0.5
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mainContent
                .overlay(invisibleNavigation)
            PassthroughView {
                if viewModel.interactionsEnabled {
                    exploreButton
                }
            }
            .animation(.easeInOut(duration: animationDuration), value: viewModel.interactionsEnabled)
        }
        .onAppear {
            viewModel.cyclePages()
        }
        .sheet(isPresented: $showNotificationsPermission) {
            PushNotificationsPermissionView(pushNotificationsHandler: viewModel.pushNotificationsHandler, onDismiss: {
                showNotificationsPermission = false
                viewModel.onFinishedInteraction()
            }, content: {
                pushNotificationsPermissionView
            })
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            if viewModel.interactionsEnabled {
                Image(.logo)
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .padding(.top)
                    .transition(.moveBottomAndFade)
            }
            Spacer()
            VStack(spacing: 0) {
                PaginatedProgressView(
                    currentIndex: $viewModel.currentIndex,
                    states: viewModel.states,
                    tint: .cultured,
                    backgroundColor: .middleGrey,
                    maxIndex: viewModel.guestOnboardingPages.count,
                    autoAnimationDidFinish: viewModel.interactionsEnabled
                )
                .frame(width: 37 * CGFloat(viewModel.guestOnboardingPages.count), height: 3)
                Text(viewModel.currentPage.title)
                    .font(kernedFont: .Main.h1RegularKerned)
                    .foregroundColor(.cultured)
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .frame(maxHeight: .infinity)
                    .transaction { titleView in
                        titleView.animation = .linear(duration: animationDuration / 2)
                    }
            }
            .frame(maxHeight: 224)
            .padding(.bottom, 104)
        }
        .frame(maxWidth: .infinity)
        .background(currentPageImageWithGradient)
        .animation(.easeOut(duration: animationDuration), value: viewModel.currentIndex)
        .animation(.easeInOut(duration: animationDuration), value: viewModel.interactionsEnabled)
    }
    
    private var currentPageImageWithGradient: some View {
        GeometryReader { proxy in
            Image(viewModel.currentPage.image)
                .resizedToFill(size: proxy.size)
                .overlay(
                    LinearGradient(
                        colors: [Color.clear, .black.opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .ignoresSafeArea(.container, edges: .vertical)
    }
    
    private var exploreButton: some View {
        Buttons.FilledRoundedButton(title: Strings.Buttons.explore, fillColor: .cappuccino, tint: .darkGreen) {
            showNotificationsPermission = true
        }
        .padding(.bottom, 16)
        .transition(.moveBottomAndFade)
    }
    
    private var invisibleNavigation: some View {
        HStack(spacing: 0) {
            Color.white.opacity(0.001)
                .navigationGesture(viewModel.onBack)
            Color.white.opacity(0.001)
                .navigationGesture(viewModel.onNext)
        }
        .disabled(!viewModel.interactionsEnabled)
        .ignoresSafeArea(.container, edges: .vertical)
    }
    
    private var pushNotificationsPermissionView: some View {
        VStack(spacing: 42) {
            Image(.notificationsIcon)
            Text(Strings.GuestOnboarding.allowNotifications)
                .font(kernedFont: .Main.h1RegularKerned)
                .foregroundColor(.jet)
            + Text(Strings.GuestOnboarding.exclusiveDiscounts)
                .font(kernedFont: .Main.h1RegularKerned)
                .foregroundColor(.orangish)
        }
        .multilineTextAlignment(.center)
    }
}

fileprivate extension View {
    
    func navigationGesture(
        animation: Animation? = .easeInOut(duration: 0.2),
        _ action: @escaping () -> Void
    ) -> some View {
        
        self.highPriorityGesture(
            TapGesture(count: 1).onEnded { _ in
                withAnimation(animation) {
                    action()
                }
            }
        )
    }
}

class GuestOnboardingViewController: UIHostingController<GuestOnboardingView> {
    
    init(viewModel: GuestOnboardingViewModel) {
        super.init(rootView: GuestOnboardingView(viewModel: viewModel))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#if DEBUG
#Preview {
    GuestOnboardingView(viewModel: .preview)
}
#endif
