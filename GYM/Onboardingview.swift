//
//  Onboardingview.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.
//



import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var lm: LanguageManager
    @State private var currentPage = 0
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var selectedGoal: FitnessGoal = .stayFit
    @State private var selectedActivity: ActivityLevel = .moderatelyActive
    @State private var selectedDiet: DietaryPreference = .standard

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? Color.green : Color.secondary.opacity(0.3))
                            .frame(width: i == currentPage ? 24 : 8, height: 8)
                    }
                }
                .padding(.top, 24)
                .animation(.spring(), value: currentPage)

                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    personalInfoPage.tag(1)
                    goalsPage.tag(2)
                    dietPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
            }
        }
    }

    // MARK: - Welcome Page with FitBody Logo
    var welcomePage: some View {
        VStack(spacing: 0) {
            // Language toggle
            HStack {
                if lm.isArabic { Spacer() }
                LanguageToggleButton().environmentObject(lm)
                if !lm.isArabic { Spacer() }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer()

            // FitBody Logo from Assets
            Image("fitbody_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
                .padding(.bottom, 24)

            VStack(spacing: 12) {
                Text(lm.t(.welcomeTitle))
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                Text(lm.t(.welcomeSubtitle))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            OnboardingButton(title: lm.t(.letsGetStarted)) {
                withAnimation { currentPage = 1 }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Personal Info
    var personalInfoPage: some View {
        ScrollView {
            VStack(spacing: 24) {
                OnboardingHeader(icon: "person.fill",
                                 title: lm.t(.aboutYou),
                                 subtitle: lm.t(.aboutYouSubtitle))
                VStack(spacing: 14) {
                    OnboardingTextField(placeholder: lm.t(.yourName), text: $name)
                    OnboardingNumberField(placeholder: lm.t(.age), text: $age, unit: lm.t(.years))
                    OnboardingNumberField(placeholder: lm.t(.weight), text: $weight, unit: "kg")
                    OnboardingNumberField(placeholder: lm.t(.height), text: $height, unit: "cm")
                }
                .padding(.horizontal)
                OnboardingButton(title: lm.t(.continueText)) {
                    withAnimation { currentPage = 2 }
                }
                .padding(.horizontal)
                .disabled(name.isEmpty)
                .opacity(name.isEmpty ? 0.5 : 1)
            }
            .padding(.vertical, 32)
        }
    }

    // MARK: - Goals
    var goalsPage: some View {
        VStack(spacing: 24) {
            OnboardingHeader(icon: "target",
                             title: lm.t(.yourGoal),
                             subtitle: lm.t(.whatToAchieve))
            VStack(spacing: 12) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    Button(action: { selectedGoal = goal }) {
                        HStack {
                            Image(systemName: goal.icon).font(.title3)
                                .foregroundColor(goal.color)
                                .frame(width: 40, height: 40)
                                .background(goal.color.opacity(0.12)).cornerRadius(10)
                            Text(goal.localizedName(lm)).font(.headline).foregroundColor(.primary)
                            Spacer()
                            if selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(14)
                        .overlay(selectedGoal == goal
                                 ? RoundedRectangle(cornerRadius: 14).stroke(Color.green, lineWidth: 2)
                                 : nil)
                    }
                }
            }
            .padding(.horizontal)
            OnboardingButton(title: lm.t(.continueText)) {
                withAnimation { currentPage = 3 }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Diet
    var dietPage: some View {
        VStack(spacing: 24) {
            OnboardingHeader(icon: "fork.knife",
                             title: lm.t(.dietaryPreference),
                             subtitle: lm.t(.customizeMealPlan))
            VStack(spacing: 10) {
                ForEach(DietaryPreference.allCases, id: \.self) { diet in
                    Button(action: { selectedDiet = diet }) {
                        HStack {
                            Text(diet.localizedName(lm)).font(.headline).foregroundColor(.primary)
                            Spacer()
                            if selectedDiet == diet {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(14)
                        .overlay(selectedDiet == diet
                                 ? RoundedRectangle(cornerRadius: 14).stroke(Color.green, lineWidth: 2)
                                 : nil)
                    }
                }
            }
            .padding(.horizontal)
            Spacer()
            OnboardingButton(title: lm.t(.letsGo)) { saveAndFinish() }
                .padding(.horizontal).padding(.bottom, 32)
        }
    }

    func saveAndFinish() {
        userProfileVM.profile.name = name
        userProfileVM.profile.age = Int(age) ?? 25
        userProfileVM.profile.weightKg = Double(weight) ?? 70
        userProfileVM.profile.heightCm = Double(height) ?? 175
        userProfileVM.profile.fitnessGoal = selectedGoal
        userProfileVM.profile.activityLevel = selectedActivity
        userProfileVM.profile.dietaryPreference = selectedDiet
        userProfileVM.completeOnboarding()
    }
}

// MARK: - Language Toggle Button
struct LanguageToggleButton: View {
    @EnvironmentObject var lm: LanguageManager
    var body: some View {
        Button(action: { lm.toggle() }) {
            HStack(spacing: 6) {
                Image(systemName: "globe").font(.subheadline)
                Text(lm.isArabic ? "English" : "العربية").font(.subheadline).bold()
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(Capsule().fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.08), radius: 4))
            .foregroundColor(.primary)
        }
    }
}

struct OnboardingHeader: View {
    let icon: String; let title: String; let subtitle: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 44)).foregroundColor(.green)
            Text(title).font(.largeTitle).bold().multilineTextAlignment(.center)
            Text(subtitle).font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
        }
        .padding(.top, 32)
    }
}

struct OnboardingButton: View {
    let title: String; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.headline).frame(maxWidth: .infinity).padding()
                .background(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white).cornerRadius(16)
        }
    }
}

struct OnboardingTextField: View {
    let placeholder: String; @Binding var text: String
    var body: some View {
        TextField(placeholder, text: $text).padding()
            .background(Color(.secondarySystemGroupedBackground)).cornerRadius(14)
            .autocorrectionDisabled()
    }
}

struct OnboardingNumberField: View {
    let placeholder: String; @Binding var text: String; let unit: String
    var body: some View {
        HStack {
            TextField(placeholder, text: $text).keyboardType(.decimalPad)
            Text(unit).foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground)).cornerRadius(14)
    }
}

extension FitnessGoal {
    func localizedName(_ lm: LanguageManager) -> String {
        switch self {
        case .loseWeight: return lm.t(.loseWeight)
        case .buildMuscle: return lm.t(.buildMuscle)
        case .improveEndurance: return lm.t(.improveEndurance)
        case .stayFit: return lm.t(.stayFit)
        }
    }
}

extension DietaryPreference {
    func localizedName(_ lm: LanguageManager) -> String {
        switch self {
        case .standard: return lm.t(.standard)
        case .vegetarian: return lm.t(.vegetarian)
        case .vegan: return lm.t(.vegan)
        case .keto: return lm.t(.keto)
        case .paleo: return lm.t(.paleo)
        }
    }
}
