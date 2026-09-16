//
//  Profileview.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.
//



import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var subscriptionService: SubscriptionService
    @EnvironmentObject var lm: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isEditing = false
    @State private var showingSubscription = false
    @State private var showingLogoutConfirm = false
    @State private var showingPhotoPicker = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 16) {
                        // Tappable avatar with camera badge
                        ZStack {
                            ProfileAvatarView(size: 72, showEditBadge: true) {
                                showingPhotoPicker = true
                            }
                            .environmentObject(userProfileVM)
                        }

                        VStack(alignment: lm.isArabic ? .trailing : .leading, spacing: 4) {
                            Text(userProfileVM.profile.name.isEmpty ? lm.t(.athlete) : userProfileVM.profile.name)
                                .font(.title3).bold()
                            HStack {
                                Image(systemName: userProfileVM.profile.fitnessGoal.icon)
                                    .foregroundColor(userProfileVM.profile.fitnessGoal.color)
                                Text(userProfileVM.profile.fitnessGoal.localizedName(lm))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)

                    // Change Photo button row
                    Button(action: { showingPhotoPicker = true }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.green)
                            Text(lm.isArabic ? "تغيير صورة الملف الشخصي" : "Change Profile Photo")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Body Stats
                Section("Body Stats") {
                    ProfileRow(label: "Age", value: "\(userProfileVM.profile.age) years")
                    ProfileRow(label: "Weight", value: String(format: "%.1f kg", userProfileVM.profile.weightKg))
                    ProfileRow(label: "Height", value: String(format: "%.0f cm", userProfileVM.profile.heightCm))
                    ProfileRow(label: "BMI", value: String(format: "%.1f", userProfileVM.profile.bmi))
                    ProfileRow(label: "Daily Calories", value: "\(userProfileVM.profile.bmrCalories) kcal")
                }

                // Fitness Profile
                Section("Fitness Profile") {
                    ProfileRow(label: "Goal", value: userProfileVM.profile.fitnessGoal.rawValue)
                    ProfileRow(label: "Activity Level", value: userProfileVM.profile.activityLevel.rawValue)
                    ProfileRow(label: "Diet Preference", value: userProfileVM.profile.dietaryPreference.rawValue)
                }

                // Subscription
                Section("Subscription") {
                    if let tier = subscriptionService.currentTier {
                        HStack {
                            Label("Active Plan", systemImage: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Spacer()
                            Text(tier.rawValue)
                                .foregroundColor(.secondary)
                        }
                    }
                    Button(action: { showingSubscription = true }) {
                        Label("Manage Subscription", systemImage: "creditcard")
                    }
                    Button(action: {
                        Task { await subscriptionService.restorePurchases() }
                    }) {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                }

                // Appearance
                Section(header: Text(lm.isArabic ? "المظهر" : "Appearance"),
                        footer: Text(lm.isArabic
                                     ? "يتجاوز هذا الإعداد إعداد النظام."
                                     : "This overrides your system setting.")
                            .font(.caption)) {
                    HStack(spacing: 0) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            let isSelected = themeManager.current == theme
                            VStack(spacing: 5) {
                                Image(systemName: theme.icon)
                                    .font(.title3)
                                    .foregroundColor(isSelected ? theme.iconColor : .secondary)
                                Text(lm.isArabic ? theme.arabicName : theme.rawValue)
                                    .font(.caption2).bold()
                                    .foregroundColor(isSelected ? .primary : .secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isSelected ? Color(.systemBackground) : Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                themeManager.set(theme)
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                // Language
                Section(lm.t(.language)) {
                    HStack {
                        Label(lm.isArabic ? "اللغة الحالية" : "Current Language",
                              systemImage: "globe")
                        Spacer()
                        Text(lm.isArabic ? "العربية" : "English")
                            .foregroundColor(.secondary)
                    }
                    Button(action: { lm.toggle() }) {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right")
                                .foregroundColor(.green)
                            Text(lm.isArabic ? "Switch to English" : "التبديل إلى العربية")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(lm.isArabic ? "English" : "العربية")
                                .font(.subheadline).bold()
                                .foregroundColor(.green)
                        }
                    }
                }

                // Log Out / Switch User
                Section {
                    Button(role: .destructive, action: { showingLogoutConfirm = true }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out & Register New User")
                        }
                    }
                } footer: {
                    Text("This will clear your profile and workout history, and restart the setup screen so a new person can register.")
                        .font(.caption)
                }

                // App Info
                Section("App Info") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    Link(destination: URL(string: "https://yourapp.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                    Link(destination: URL(string: "https://yourapp.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle(lm.t(.profile))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isEditing = true }) {
                        Text(lm.t(.edit))
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                EditProfileView().environmentObject(userProfileVM).environmentObject(lm)
            }
            .sheet(isPresented: $showingSubscription) {
                PaywallView().environmentObject(subscriptionService)
            }
            .sheet(isPresented: $showingPhotoPicker) {
                ProfilePhotoPickerView(isPresented: $showingPhotoPicker)
                    .environmentObject(userProfileVM)
            }
            .alert(lm.t(.logOutTitle), isPresented: $showingLogoutConfirm) {
                Button(lm.t(.logOutConfirm), role: .destructive) {
                    userProfileVM.logout()
                }
                Button(lm.t(.cancel), role: .cancel) {}
            } message: {
                Text(lm.t(.logOutMessage))
            }
        }
        // layoutDirection is set at app root — do NOT override it locally
    }
}

struct ProfileRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State var name: String = ""
    @State var age: String = ""
    @State var weight: String = ""
    @State var height: String = ""
    @State var goal: FitnessGoal = .stayFit
    @State var activity: ActivityLevel = .moderatelyActive
    @State var diet: DietaryPreference = .standard

    var body: some View {
        NavigationView {
            Form {
                Section("Personal Info") {
                    TextField("Name", text: $name)
                    HStack {
                        TextField("Age", text: $age).keyboardType(.numberPad)
                        Text("years").foregroundColor(.secondary)
                    }
                    HStack {
                        TextField("Weight", text: $weight).keyboardType(.decimalPad)
                        Text("kg").foregroundColor(.secondary)
                    }
                    HStack {
                        TextField("Height", text: $height).keyboardType(.decimalPad)
                        Text("cm").foregroundColor(.secondary)
                    }
                }
                Section("Fitness Goals") {
                    Picker("Goal", selection: $goal) {
                        ForEach(FitnessGoal.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    Picker("Activity Level", selection: $activity) {
                        ForEach(ActivityLevel.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    Picker("Dietary Preference", selection: $diet) {
                        ForEach(DietaryPreference.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userProfileVM.profile.name = name
                        userProfileVM.profile.age = Int(age) ?? userProfileVM.profile.age
                        userProfileVM.profile.weightKg = Double(weight) ?? userProfileVM.profile.weightKg
                        userProfileVM.profile.heightCm = Double(height) ?? userProfileVM.profile.heightCm
                        userProfileVM.profile.fitnessGoal = goal
                        userProfileVM.profile.activityLevel = activity
                        userProfileVM.profile.dietaryPreference = diet
                        userProfileVM.saveProfile()
                        dismiss()
                    }
                    .font(.headline)
                }
            }
            .onAppear {
                name = userProfileVM.profile.name
                age = "\(userProfileVM.profile.age)"
                weight = String(format: "%.1f", userProfileVM.profile.weightKg)
                height = String(format: "%.0f", userProfileVM.profile.heightCm)
                goal = userProfileVM.profile.fitnessGoal
                activity = userProfileVM.profile.activityLevel
                diet = userProfileVM.profile.dietaryPreference
            }
        }
    }
}

// MARK: - Theme Option Cell
// Extracted to its own struct so the Swift type-checker
// doesn't time out on the conditional expressions inline.
struct ThemeOptionCell: View {
    let theme: AppTheme
    let isSelected: Bool
    let isArabic: Bool

    var label: String { isArabic ? theme.arabicName : theme.rawValue }
    var iconColor: Color { isSelected ? theme.iconColor : .secondary }
    var textColor: Color { isSelected ? .primary : .secondary }
    var bg: Color { isSelected ? Color(.systemBackground) : Color.clear }

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: theme.icon)
                .font(.title3)
                .foregroundColor(iconColor)
            Text(label)
                .font(.caption2)
                .bold()
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(bg)
        .cornerRadius(10)
    }
}
