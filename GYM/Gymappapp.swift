//
//  ContentView.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.



import SwiftUI

@main
struct GymAppApp: App {
    @StateObject private var subscriptionService = SubscriptionService()
    @StateObject private var userProfileVM = UserProfileViewModel()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var workoutVM = WorkoutViewModel()
    @StateObject private var dietVM = DietViewModel()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(subscriptionService)
                    .environmentObject(userProfileVM)
                    .environmentObject(languageManager)
                    .environmentObject(themeManager)
                    .environmentObject(workoutVM)
                    .environmentObject(dietVM)
                    .preferredColorScheme(themeManager.current.colorScheme)
                    .id(languageManager.isArabic)
                    .environment(\.layoutDirection, languageManager.layoutDirection)
                    .environment(\.locale, languageManager.locale)
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                                withAnimation(.easeIn(duration: 0.4)) {
                                    showSplash = false
                                }
                            }
                        }
                }
            }
        }
    }
}
