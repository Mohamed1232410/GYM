//
//  ContentView.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.
//



import SwiftUI

@main
struct GymAppApp: App {
    @StateObject private var subscriptionService = SubscriptionService()
    @StateObject private var userProfileVM = UserProfileViewModel()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var themeManager = ThemeManager()
    // Lifted here so language rebuilds don't wipe workout/diet data
    @StateObject private var workoutVM = WorkoutViewModel()
    @StateObject private var dietVM = DietViewModel()

    var body: some Scene {
        WindowGroup {
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
        }
    }
}
