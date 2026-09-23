//
//  Models.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.



import Foundation
import SwiftUI

// MARK: - User Profile
struct UserProfile: Codable {
    var name: String
    var age: Int
    var weightKg: Double
    var heightCm: Double
    var fitnessGoal: FitnessGoal
    var activityLevel: ActivityLevel
    var dietaryPreference: DietaryPreference
    var hasCompletedOnboarding: Bool = false

    var bmi: Double { weightKg / ((heightCm / 100) * (heightCm / 100)) }

    var bmrCalories: Int {
        let bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
        return Int(bmr * activityLevel.multiplier)
    }
}

enum FitnessGoal: String, CaseIterable, Codable {
    case loseWeight = "Lose Weight"
    case buildMuscle = "Build Muscle"
    case improveEndurance = "Improve Endurance"
    case stayFit = "Stay Fit"

    var icon: String {
        switch self {
        case .loseWeight: return "flame.fill"
        case .buildMuscle: return "figure.strengthtraining.traditional"
        case .improveEndurance: return "figure.run"
        case .stayFit: return "heart.fill"
        }
    }
    var color: Color {
        switch self {
        case .loseWeight: return .orange
        case .buildMuscle: return .blue
        case .improveEndurance: return .green
        case .stayFit: return .red
        }
    }
}

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extraActive = "Extra Active"

    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extraActive: return 1.9
        }
    }
}

enum DietaryPreference: String, CaseIterable, Codable {
    case standard = "Standard"
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case keto = "Keto"
    case paleo = "Paleo"
}

// MARK: - Exercise
struct Exercise: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var category: ExerciseCategory
    var muscleGroups: [MuscleGroup]
    var sets: Int
    var reps: String
    var restSeconds: Int
    var instructions: [String]
    var tips: String
    var difficulty: Difficulty
    var equipmentNeeded: [Equipment]
    var gifName: String
    var videoURL: String? = nil
    var photoID: String? = nil  // Unique Pexels photo ID per exercise per plan
}

enum ExerciseCategory: String, CaseIterable, Codable {
    case strength = "Strength"
    case cardio = "Cardio"
    case flexibility = "Flexibility"
    case hiit = "HIIT"
    case coreStability = "Core & Stability"
}

enum MuscleGroup: String, CaseIterable, Codable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case forearms = "Forearms"
    case quadriceps = "Quadriceps"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case calves = "Calves"
    case core = "Core"
    case fullBody = "Full Body"
}

enum Difficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

enum Equipment: String, CaseIterable, Codable {
    case none = "No Equipment"
    case dumbbells = "Dumbbells"
    case barbell = "Barbell"
    case resistanceBands = "Resistance Bands"
    case pullUpBar = "Pull-Up Bar"
    case bench = "Bench"
    case kettlebell = "Kettlebell"
    case cableMachine = "Cable Machine"
    case treadmill = "Treadmill"
    case mat = "Mat"
}

// MARK: - Workout
struct WorkoutPlan: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var goal: FitnessGoal
    var durationWeeks: Int
    var daysPerWeek: Int
    var difficulty: Difficulty
    var weeks: [WorkoutWeek]
}

struct WorkoutWeek: Identifiable, Codable {
    var id: UUID = UUID()
    var weekNumber: Int
    var days: [WorkoutDay]
}

struct WorkoutDay: Identifiable, Codable {
    var id: UUID = UUID()
    var dayNumber: Int
    var dayName: String
    var focus: String
    var isRestDay: Bool
    var exercises: [Exercise]
    var estimatedMinutes: Int
}

// MARK: - Workout Session (Tracking)
struct WorkoutSession: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var workoutDayId: UUID
    var workoutName: String
    var completedExercises: [CompletedExercise]
    var durationSeconds: Int
    var caloriesBurned: Int
    var notes: String
    var isCompleted: Bool
}

struct CompletedExercise: Identifiable, Codable {
    var id: UUID = UUID()
    var exerciseId: UUID
    var exerciseName: String
    var sets: [CompletedSet]
}

struct CompletedSet: Identifiable, Codable {
    var id: UUID = UUID()
    var setNumber: Int
    var reps: Int
    var weightKg: Double
    var durationSeconds: Int?
    var isCompleted: Bool
}

// MARK: - Diet & Nutrition
struct MealPlan: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var goal: FitnessGoal
    var dietaryPreference: DietaryPreference
    var dailyCalorieTarget: Int
    var proteinGrams: Int
    var carbGrams: Int
    var fatGrams: Int
    var days: [MealDay]
}

struct MealDay: Identifiable, Codable {
    var id: UUID = UUID()
    var dayName: String
    var meals: [Meal]

    var totalCalories: Int { meals.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double { meals.reduce(0) { $0 + $1.proteinGrams } }
    var totalCarbs: Double { meals.reduce(0) { $0 + $1.carbGrams } }
    var totalFat: Double { meals.reduce(0) { $0 + $1.fatGrams } }
}

struct Meal: Identifiable, Codable {
    var id: UUID = UUID()
    var type: MealType
    var name: String
    var description: String
    var calories: Int
    var proteinGrams: Double
    var carbGrams: Double
    var fatGrams: Double
    var ingredients: [String]
    var prepInstructions: [String]
    var prepTimeMinutes: Int
    var imageAsset: String
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case morningSnack = "Morning Snack"
    case lunch = "Lunch"
    case afternoonSnack = "Afternoon Snack"
    case dinner = "Dinner"
    case postWorkout = "Post-Workout"

    var icon: String {
        switch self {
        case .breakfast: return "sun.rise.fill"
        case .morningSnack: return "apple.logo"
        case .lunch: return "fork.knife"
        case .afternoonSnack: return "cup.and.saucer.fill"
        case .dinner: return "moon.stars.fill"
        case .postWorkout: return "bolt.fill"
        }
    }
    var color: Color {
        switch self {
        case .breakfast: return .orange
        case .morningSnack: return .yellow
        case .lunch: return .green
        case .afternoonSnack: return .blue
        case .dinner: return .purple
        case .postWorkout: return .red
        }
    }
}

// MARK: - Progress Tracking
struct BodyMeasurement: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var weightKg: Double
    var bodyFatPercent: Double?
    var chestCm: Double?
    var waistCm: Double?
    var hipsCm: Double?
    var armCm: Double?
    var thighCm: Double?
}

// MARK: - Subscription
enum SubscriptionTier: String, CaseIterable {
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case annual = "Annual"

    var productId: String {
        switch self {
        case .monthly: return "com.gymapp.subscription.monthly"
        case .quarterly: return "com.gymapp.subscription.quarterly"
        case .annual: return "com.gymapp.subscription.annual"
        }
    }
    var price: String {
        switch self {
        case .monthly: return "$9.99"
        case .quarterly: return "$24.99"
        case .annual: return "$59.99"
        }
    }
    var pricePerMonth: String {
        switch self {
        case .monthly: return "$9.99/mo"
        case .quarterly: return "$8.33/mo"
        case .annual: return "$5.00/mo"
        }
    }
    var savings: String? {
        switch self {
        case .monthly: return nil
        case .quarterly: return "Save 17%"
        case .annual: return "Save 50%"
        }
    }
    var description: String {
        switch self {
        case .monthly: return "Billed monthly"
        case .quarterly: return "Billed every 3 months"
        case .annual: return "Billed annually"
        }
    }
}
