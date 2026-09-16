//
//  Maintabview.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.




import SwiftUI

struct MainTabView: View {
    @Binding var selectedTab: Int

    // All received from environment — not recreated on language switch
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @EnvironmentObject var dietVM: DietViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var lm: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionService: SubscriptionService

    var homeLabel: String { lm.isArabic ? "الرئيسية" : "Home" }

    var body: some View {
        TabView(selection: $selectedTab) {

            HomeView()
                .environmentObject(workoutVM)
                .environmentObject(dietVM)
                .environmentObject(lm)
                .environmentObject(userProfileVM)
                .environmentObject(themeManager)
                .tabItem { Label(homeLabel, systemImage: "house.fill") }
                .tag(0)

            WorkoutView()
                .environmentObject(workoutVM)
                .environmentObject(lm)
                .environmentObject(themeManager)
                .tabItem { Label(lm.t(.workouts), systemImage: "figure.strengthtraining.traditional") }
                .tag(1)

            DietView()
                .environmentObject(dietVM)
                .environmentObject(lm)
                .environmentObject(themeManager)
                .tabItem { Label(lm.t(.diet), systemImage: "fork.knife") }
                .tag(2)

            GymProgressView()
                .environmentObject(workoutVM)
                .environmentObject(userProfileVM)
                .environmentObject(lm)
                .environmentObject(themeManager)
                .tabItem { Label(lm.t(.progress), systemImage: "chart.line.uptrend.xyaxis") }
                .tag(3)

            ProfileView()
                .environmentObject(userProfileVM)
                .environmentObject(subscriptionService)
                .environmentObject(lm)
                .environmentObject(themeManager)
                .tabItem { Label(lm.t(.profile), systemImage: "person.fill") }
                .tag(4)
        }
        .tint(Color.green)
    }
}


