//
//  ScheduledShowDetailView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.03.2023.
//

import SwiftUI

struct ScheduledShowDetailView: View {
    
    @ObservedObject var viewModel: ScheduledShowDetailViewModel
    @State private var showPushNotificationsPremissionView = false
    private var show: Show {
        return viewModel.show
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.shouldDisplayShowCountDownTimer {
                ShowCountDownTimerView(
                    publishDate: show.publishingDate ?? .now,
                    onCountDownTimerReached: {
                        viewModel.scheduledShowActionHandler(.scheduledTimerFinished)
                    }
                )
                .padding(.leading, 16)
            }
            showDetailView
            if viewModel.shouldDisplaySetReminderButton {
                setReminderButton
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fullScreenCover(isPresented: $showPushNotificationsPremissionView, content: pushNotificationsPermissionView)
    }
    
    private var setReminderButton: some View {
        Buttons.FilledRoundedButton(
            title: Strings.Buttons.setReminder,
            isLoading: viewModel.isLoading,
            fillColor: .cultured, tint: .darkGreen,
            additionalLeadingView: {
                Image(.bellIcon).resizedToFit(size: CGSize(width: 24, height: 24))
            }, action: {
                Task(priority: .userInitiated) {
                    showPushNotificationsPremissionView = await viewModel.handleSetReminderAction()
                }
            }
        )
        .transition(.opacity.animation(.easeIn))
    }
    
    private var showDetailView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(show.title ?? "")
                .textStyle(.showTitle)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            PassthroughView {
                if let featuredBrands = viewModel.uniqueFeaturedBrands {
                    FeaturedBrandsView(brands: featuredBrands, onSelectBrand: { brand in
                        viewModel.scheduledShowActionHandler(.selectBrand(brand))
                    })
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.uniqueFeaturedBrands)
        }
    }
    
    private func pushNotificationsPermissionView() -> some View {
        LegacyPushNotificationPermissionView(
            permissionType: .newShowsPosted,
            pushNotificationsHandler: viewModel.pushNotificationsPermissionHandler,
            notificationsInteractionFinished: { notificationsEnabled in
                showPushNotificationsPremissionView = false
                if notificationsEnabled {
                    Task(priority: .userInitiated) {
                        await viewModel.setReminderForScheduledShow()
                    }
                }
            }
        )
    }
}

struct FeaturedBrandsView: View {
    
    let brands: [Brand]
    let onSelectBrand: (Brand) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.ShowDetail.featuringProducts)
                .foregroundColor(.midGrey)
                .font(kernedFont: .Secondary.p2RegularKerned)
                .padding(.leading, 16)
                .shadow(color: .white.opacity(0.15), radius: 3)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(brands, id: \.id) {
                        brandCellView($0)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private func brandCellView(_ brand: Brand) -> some View {
        Button {
            onSelectBrand(brand)
        } label: {
            BrandLogoView(imageURL: brand.logoPictureURL, diameterSize: 48)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct ScheduledShowDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(spacing: 30) {
            ScheduledShowDetailPreview(show: .scheduled)
            Divider()
            ScheduledShowDetailPreview(show: .scheduled, displayReminder: false)
        }
        .padding(.vertical)
        .background(.teal)
    }
    
    private struct ScheduledShowDetailPreview: View {
        
        @StateObject var viewModel: ScheduledShowDetailViewModel
        
        init(show: Show, displayReminder: Bool = true) {
            self._viewModel = StateObject(wrappedValue: ScheduledShowDetailViewModel(
                show: show, pushNotificationsPermissionHandler: MockPushNotificationsHandler(), showService: MockShowService(), configureForConsumer: displayReminder, scheduledShowActionHandler: { _ in })
            )
        }
        
        var body: some View {
            ScheduledShowDetailView(viewModel: viewModel)
        }
    }
}
#endif
