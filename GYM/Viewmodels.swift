//
//  Viewmodels.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.
//


import Foundation
import SwiftUI
import Combine

// MARK: - User Profile ViewModel
class UserProfileViewModel: ObservableObject {
    @Published var profile: UserProfile
    @Published var measurements: [BodyMeasurement] = []
    @Published var hasCompletedOnboarding: Bool = false
    @Published var profileImage: UIImage? = nil

    private let profileKey = "userProfile"
    private let measurementsKey = "bodyMeasurements"
    private let profileImageKey = "profileImageData"

    init() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = decoded
            self.hasCompletedOnboarding = decoded.hasCompletedOnboarding
        } else {
            self.profile = UserProfile(name: "", age: 25, weightKg: 70, heightCm: 175,
                                       fitnessGoal: .stayFit, activityLevel: .moderatelyActive,
                                       dietaryPreference: .standard)
            self.hasCompletedOnboarding = false
        }
        loadMeasurements()
        loadProfileImage()
    }

    func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
        hasCompletedOnboarding = profile.hasCompletedOnboarding
    }

    func saveProfileImage(_ image: UIImage) {
        profileImage = image
        // Compress and store in UserDefaults (fine for a profile photo)
        if let data = image.jpegData(compressionQuality: 0.7) {
            UserDefaults.standard.set(data, forKey: profileImageKey)
        }
    }

    func removeProfileImage() {
        profileImage = nil
        UserDefaults.standard.removeObject(forKey: profileImageKey)
    }

    private func loadProfileImage() {
        if let data = UserDefaults.standard.data(forKey: profileImageKey),
           let image = UIImage(data: data) {
            profileImage = image
        }
    }

    func completeOnboarding() {
        profile.hasCompletedOnboarding = true
        saveProfile()
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: profileKey)
        UserDefaults.standard.removeObject(forKey: measurementsKey)
        UserDefaults.standard.removeObject(forKey: "workoutSessions")
        UserDefaults.standard.removeObject(forKey: "currentPlan")
        UserDefaults.standard.removeObject(forKey: profileImageKey)
        profile = UserProfile(name: "", age: 25, weightKg: 70, heightCm: 175,
                              fitnessGoal: .stayFit, activityLevel: .moderatelyActive,
                              dietaryPreference: .standard)
        measurements = []
        profileImage = nil
        hasCompletedOnboarding = false
    }

    func addMeasurement(_ measurement: BodyMeasurement) {
        measurements.append(measurement)
        saveMeasurements()
    }

    func weightChange() -> Double? {
        guard measurements.count >= 2 else { return nil }
        let sorted = measurements.sorted { $0.date < $1.date }
        return sorted.last!.weightKg - sorted.first!.weightKg
    }

    private func saveMeasurements() {
        if let encoded = try? JSONEncoder().encode(measurements) {
            UserDefaults.standard.set(encoded, forKey: measurementsKey)
        }
    }

    private func loadMeasurements() {
        if let data = UserDefaults.standard.data(forKey: measurementsKey),
           let decoded = try? JSONDecoder().decode([BodyMeasurement].self, from: data) {
            measurements = decoded
        }
    }
}

// MARK: - Workout ViewModel
class WorkoutViewModel: ObservableObject {
    @Published var currentPlan: WorkoutPlan?
    @Published var sessions: [WorkoutSession] = []
    @Published var activeSession: WorkoutSession? = nil
    @Published var sessionTimer: Int = 0
    @Published var isWorkoutActive: Bool = false

    private var timerTask: Task<Void, Never>? = nil
    private let dataService = DataService.shared

    var allPlans: [WorkoutPlan] { dataService.allWorkoutPlans }
    var allExercises: [Exercise] { dataService.allExercises }

    var currentWeekSessions: [WorkoutSession] {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        return sessions.filter { $0.date >= weekStart }
    }

    var totalWorkoutsCompleted: Int { sessions.filter { $0.isCompleted }.count }
    var totalMinutesTrained: Int { sessions.reduce(0) { $0 + $1.durationSeconds / 60 } }
    var totalCaloriesBurned: Int { sessions.reduce(0) { $0 + $1.caloriesBurned } }

    var weeklyStreak: Int {
        var streak = 0
        var checkDate = Date()
        let cal = Calendar.current
        for _ in 0..<52 {
            let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: checkDate))!
            let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart)!
            let hasWorkout = sessions.contains { $0.date >= weekStart && $0.date < weekEnd && $0.isCompleted }
            if hasWorkout { streak += 1 }
            else { break }
            checkDate = cal.date(byAdding: .weekOfYear, value: -1, to: checkDate)!
        }
        return streak
    }

    init() {
        loadData()
    }

    func selectPlan(_ plan: WorkoutPlan) {
        currentPlan = plan
        savePlan()
    }

    func startWorkout(day: WorkoutDay, workoutName: String) {
        let exerciseLogs = day.exercises.map { exercise in
            CompletedExercise(
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                sets: (1...exercise.sets).map { i in
                    CompletedSet(setNumber: i, reps: 0, weightKg: 0, isCompleted: false)
                }
            )
        }
        activeSession = WorkoutSession(
            date: Date(),
            workoutDayId: day.id,
            workoutName: workoutName,
            completedExercises: exerciseLogs,
            durationSeconds: 0,
            caloriesBurned: 0,
            notes: "",
            isCompleted: false
        )
        isWorkoutActive = true
        sessionTimer = 0
        startTimer()
    }

    func completeSet(exerciseIndex: Int, setIndex: Int, reps: Int, weight: Double) {
        activeSession?.completedExercises[exerciseIndex].sets[setIndex].reps = reps
        activeSession?.completedExercises[exerciseIndex].sets[setIndex].weightKg = weight
        activeSession?.completedExercises[exerciseIndex].sets[setIndex].isCompleted = true
    }

    func finishWorkout() {
        guard var session = activeSession else { return }
        session.durationSeconds = sessionTimer
        session.isCompleted = true
        session.caloriesBurned = estimateCalories(durationSeconds: sessionTimer)
        sessions.append(session)
        activeSession = nil
        isWorkoutActive = false
        stopTimer()
        saveData()
    }

    func cancelWorkout() {
        activeSession = nil
        isWorkoutActive = false
        stopTimer()
    }

    private func estimateCalories(durationSeconds: Int) -> Int {
        let minutes = Double(durationSeconds) / 60.0
        return Int(minutes * 8.0) // rough MET estimate
    }

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run { self.sessionTimer += 1 }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
        sessionTimer = 0
    }

    func timerString() -> String {
        let h = sessionTimer / 3600
        let m = (sessionTimer % 3600) / 60
        let s = sessionTimer % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Persistence
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "workoutSessions")
        }
    }

    private func savePlan() {
        if let plan = currentPlan, let encoded = try? JSONEncoder().encode(plan) {
            UserDefaults.standard.set(encoded, forKey: "currentPlan")
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "workoutSessions"),
           let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            sessions = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "currentPlan"),
           let decoded = try? JSONDecoder().decode(WorkoutPlan.self, from: data) {
            currentPlan = decoded
        }
    }
}

// MARK: - Diet ViewModel
class DietViewModel: ObservableObject {
    @Published var currentMealPlan: MealPlan?
    @Published var selectedDayIndex: Int = 0
    @Published var loggedMeals: [Date: [UUID]] = [:]

    private let dataService = DataService.shared

    var allMealPlans: [MealPlan] { dataService.allMealPlans }

    var selectedDay: MealDay? {
        guard let plan = currentMealPlan,
              selectedDayIndex < plan.days.count else { return nil }
        return plan.days[selectedDayIndex]
    }

    var todayCaloriesConsumed: Int {
        guard let day = selectedDay else { return 0 }
        let today = Calendar.current.startOfDay(for: Date())
        let logged = loggedMeals[today] ?? []
        return day.meals.filter { logged.contains($0.id) }.reduce(0) { $0 + $1.calories }
    }

    var calorieProgress: Double {
        guard let plan = currentMealPlan, plan.dailyCalorieTarget > 0 else { return 0 }
        return min(Double(todayCaloriesConsumed) / Double(plan.dailyCalorieTarget), 1.0)
    }

    init() {
        currentMealPlan = dataService.allMealPlans.first
    }

    func selectPlan(_ plan: MealPlan) {
        currentMealPlan = plan
    }

    func toggleMealLogged(_ meal: Meal) {
        let today = Calendar.current.startOfDay(for: Date())
        var todayLog = loggedMeals[today] ?? []
        if todayLog.contains(meal.id) {
            todayLog.removeAll { $0 == meal.id }
        } else {
            todayLog.append(meal.id)
        }
        loggedMeals[today] = todayLog
    }

    func isMealLogged(_ meal: Meal) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return loggedMeals[today]?.contains(meal.id) ?? false
    }
}


