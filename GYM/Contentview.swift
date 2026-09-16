//
//  GYMApp.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.
//



import SwiftUI

struct ContentView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var lm: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab: Int = 0

    var body: some View {
        Group {
            if !userProfileVM.hasCompletedOnboarding {
                OnboardingView()
                    .environmentObject(lm)
                    .environmentObject(themeManager)
            } else if !subscriptionService.isSubscribed {
                PaywallView()
                    .environmentObject(subscriptionService)
                    .environmentObject(lm)
                    .environmentObject(themeManager)
            } else {
                MainTabView(selectedTab: $selectedTab)
            }
        }
    }
}
