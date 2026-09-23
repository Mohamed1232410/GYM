//
//  Homeview.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.
//




import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @EnvironmentObject var dietVM: DietViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var lm: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return lm.t(.goodMorning)
        case 12..<17: return lm.t(.goodAfternoon)
        default:      return lm.t(.goodEvening)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    statsGrid
                    if let plan = workoutVM.currentPlan {
                        todaysWorkoutCard(plan: plan)
                    } else {
                        noWorkoutCard
                    }
                    caloriesCard
                    streakCard
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }

    }

    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting).font(.subheadline).foregroundColor(.secondary)
                Text(userProfileVM.profile.name.isEmpty ? lm.t(.athlete) : userProfileVM.profile.name)
                    .font(.largeTitle).bold()
            }
            Spacer()
            ProfileAvatarView(size: 52).environmentObject(userProfileVM)
        }
    }

    var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: lm.t(.workouts),      value: "\(workoutVM.totalWorkoutsCompleted)", icon: "figure.strengthtraining.traditional", color: .blue)
            StatCard(title: lm.t(.hoursTrained),  value: "\(workoutVM.totalMinutesTrained)",    icon: "clock.fill",  color: .orange)
            StatCard(title: lm.t(.caloriesBurned),value: "\(workoutVM.totalCaloriesBurned)",    icon: "flame.fill",  color: .red)
        }
    }

    func todaysWorkoutCard(plan: WorkoutPlan) -> some View {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let dayIndex = (weekday + 5) % 7
        let todayDay = plan.weeks.first?.days[safe: dayIndex]
        return VStack(alignment: .leading, spacing: 12) {
            Text(lm.t(.todaysWorkout)).font(.headline).foregroundColor(.secondary)
            if let day = todayDay {
                if day.isRestDay {
                    HStack {
                        Image(systemName: "bed.double.fill").font(.title2).foregroundColor(.purple)
                        VStack(alignment: .leading) {
                            Text(lm.t(.restDay)).font(.title3).bold()
                            Text(lm.t(.recoveryKey)).font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                    .padding().frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground)).cornerRadius(16)
                } else {
                    NavigationLink(destination:
                        WorkoutDayDetailView(day: day, planName: plan.name, planGoal: plan.goal)
                            .environmentObject(workoutVM)
                            .environmentObject(lm)
                            .environmentObject(themeManager)
                    ) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(day.focus).font(.title3).bold().foregroundColor(.primary)
                                Text(lm.isArabic
                                     ? "\(day.exercises.count) تمرين · ~\(day.estimatedMinutes) دقيقة"
                                     : "\(day.exercises.count) exercises · ~\(day.estimatedMinutes) min")
                                    .font(.subheadline).foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right.circle.fill").font(.title2).foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground)).cornerRadius(16)
                    }
                }
            }
        }
    }

    var noWorkoutCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run.circle").font(.system(size: 44)).foregroundColor(.green)
            Text(lm.isArabic ? "لا توجد خطة محددة" : "No Plan Selected").font(.headline)
            Text(lm.isArabic ? "اختر خطة تمرين للبدء" : "Choose a workout plan to get started")
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
        }
        .padding().frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground)).cornerRadius(16)
    }

    var caloriesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lm.t(.todaysCalories)).font(.headline).foregroundColor(.secondary)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(dietVM.todayCaloriesConsumed)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    if let target = dietVM.currentMealPlan?.dailyCalorieTarget {
                        Text(lm.isArabic ? "من \(target) سعرة" : "of \(target) kcal")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                }
                Spacer()
                ZStack {
                    Circle().stroke(Color.green.opacity(0.2), lineWidth: 8).frame(width: 70, height: 70)
                    Circle()
                        .trim(from: 0, to: dietVM.calorieProgress)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 70, height: 70).rotationEffect(.degrees(-90))
                    Text("\(Int(dietVM.calorieProgress * 100))%").font(.caption).bold()
                }
            }
        }
        .padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(16)
    }

    var streakCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill").font(.system(size: 36))
                .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
            VStack(alignment: .leading) {
                Text(lm.isArabic
                     ? "\(workoutVM.weeklyStreak) \(lm.t(.weekStreak))"
                     : "\(workoutVM.weeklyStreak) \(lm.t(.weekStreak))")
                    .font(.title3).bold()
                Text(lm.t(.keepItUp)).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(16)
    }
}

struct StatCard: View {
    let title: String; let value: String; let icon: String; let color: Color
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundColor(color)
            Text(value).font(.title3).bold()
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground)).cornerRadius(14)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
