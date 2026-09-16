//
//  Dataservice.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.
//

import Foundation

class DataService {
    static let shared = DataService()

    // MARK: - Workout Plans
    var allWorkoutPlans: [WorkoutPlan] {
        [muscleBuilding4DayPlan, fatLoss3DayPlan, endurance5DayPlan, fullBodyBeginnerPlan]
    }

    var muscleBuilding4DayPlan: WorkoutPlan {
        WorkoutPlan(
            name: "Mass Builder Pro",
            description: "A classic 4-day upper/lower split designed to maximize hypertrophy with progressive overload.",
            goal: .buildMuscle,
            durationWeeks: 8,
            daysPerWeek: 4,
            difficulty: .intermediate,
            weeks: buildMuscleWeeks()
        )
    }

    var fatLoss3DayPlan: WorkoutPlan {
        WorkoutPlan(
            name: "Shred Circuit",
            description: "High-intensity 3-day full-body circuit training to torch calories and preserve muscle.",
            goal: .loseWeight,
            durationWeeks: 6,
            daysPerWeek: 3,
            difficulty: .intermediate,
            weeks: fatLossWeeks()
        )
    }

    var endurance5DayPlan: WorkoutPlan {
        WorkoutPlan(
            name: "Endurance Elite",
            description: "5-day progressive cardio and strength endurance program for athletic performance.",
            goal: .improveEndurance,
            durationWeeks: 10,
            daysPerWeek: 5,
            difficulty: .advanced,
            weeks: enduranceWeeks()
        )
    }

    var fullBodyBeginnerPlan: WorkoutPlan {
        WorkoutPlan(
            name: "Beginner Foundation",
            description: "3-day full-body program covering all fundamentals — perfect for those just starting out.",
            goal: .stayFit,
            durationWeeks: 8,
            daysPerWeek: 3,
            difficulty: .beginner,
            weeks: beginnerWeeks()
        )
    }

    // MARK: - Exercise Library
    var allExercises: [Exercise] {
        [
            // Chest
            Exercise(name: "Barbell Bench Press", category: .strength, muscleGroups: [.chest, .triceps, .shoulders],
                     sets: 4, reps: "8-10", restSeconds: 90,
                     instructions: ["Lie flat on bench", "Grip bar slightly wider than shoulder-width", "Lower bar to mid-chest", "Press explosively back up", "Keep feet flat, back slightly arched"],
                     tips: "Focus on squeezing pecs at the top. Don't bounce the bar off your chest.",
                     difficulty: .intermediate, equipmentNeeded: [.barbell, .bench], gifName: "bench_press"),
            Exercise(name: "Push-Up", category: .strength, muscleGroups: [.chest, .triceps, .core],
                     sets: 3, reps: "12-15", restSeconds: 60,
                     instructions: ["Start in high plank position", "Lower body until chest nearly touches floor", "Keep core tight and body straight", "Push back up to starting position"],
                     tips: "Scale by doing knee push-ups if needed. Widen hands to target chest more.",
                     difficulty: .beginner, equipmentNeeded: [.none], gifName: "pushup"),
            Exercise(name: "Dumbbell Flyes", category: .strength, muscleGroups: [.chest],
                     sets: 3, reps: "12", restSeconds: 60,
                     instructions: ["Lie on bench with dumbbells above chest", "Lower arms out to sides with slight elbow bend", "Feel chest stretch at bottom", "Bring dumbbells back together in arc motion"],
                     tips: "Control the negative. This is a stretch exercise — don't go too heavy.",
                     difficulty: .intermediate, equipmentNeeded: [.dumbbells, .bench], gifName: "db_flye"),
            // Back
            Exercise(name: "Pull-Up", category: .strength, muscleGroups: [.back, .biceps],
                     sets: 4, reps: "6-10", restSeconds: 90,
                     instructions: ["Hang from bar with overhand grip", "Pull chest to bar by driving elbows down", "Hold briefly at top", "Lower with control"],
                     tips: "Use band assistance if needed. Focus on lat engagement, not bicep pull.",
                     difficulty: .intermediate, equipmentNeeded: [.pullUpBar], gifName: "pullup"),
            Exercise(name: "Barbell Row", category: .strength, muscleGroups: [.back, .biceps, .forearms],
                     sets: 4, reps: "8-10", restSeconds: 90,
                     instructions: ["Hinge at hips with flat back", "Grip bar shoulder-width", "Pull bar to lower chest/upper stomach", "Squeeze shoulder blades together at top", "Lower with control"],
                     tips: "Keep your back parallel to floor. Pull with your elbows, not your hands.",
                     difficulty: .intermediate, equipmentNeeded: [.barbell], gifName: "barbell_row"),
            // Legs
            Exercise(name: "Barbell Back Squat", category: .strength, muscleGroups: [.quadriceps, .hamstrings, .glutes],
                     sets: 4, reps: "6-8", restSeconds: 120,
                     instructions: ["Position bar on upper traps", "Stand with feet shoulder-width", "Break at hips and knees simultaneously", "Lower until thighs parallel to floor", "Drive through heels to stand"],
                     tips: "Keep chest up and knees tracking over toes. Breathe in on the way down.",
                     difficulty: .intermediate, equipmentNeeded: [.barbell], gifName: "squat"),
            Exercise(name: "Romanian Deadlift", category: .strength, muscleGroups: [.hamstrings, .glutes, .back],
                     sets: 3, reps: "10-12", restSeconds: 90,
                     instructions: ["Hold bar at hip level", "Hinge at hips pushing them back", "Lower bar along thighs feeling hamstring stretch", "Drive hips forward to return to start"],
                     tips: "Keep slight bend in knees. Focus on hip hinge, not bending over.",
                     difficulty: .intermediate, equipmentNeeded: [.barbell], gifName: "rdl"),
            Exercise(name: "Goblet Squat", category: .strength, muscleGroups: [.quadriceps, .glutes, .core],
                     sets: 3, reps: "12-15", restSeconds: 60,
                     instructions: ["Hold dumbbell or kettlebell at chest", "Feet slightly wider than shoulders, toes out", "Squat deep keeping chest up", "Drive up through heels"],
                     tips: "Great for beginners. The front load naturally keeps you upright.",
                     difficulty: .beginner, equipmentNeeded: [.dumbbells], gifName: "goblet_squat"),
            // Shoulders
            Exercise(name: "Overhead Press", category: .strength, muscleGroups: [.shoulders, .triceps],
                     sets: 4, reps: "8-10", restSeconds: 90,
                     instructions: ["Stand with bar at upper chest", "Grip just outside shoulder-width", "Press bar directly overhead", "Lock out arms at top", "Lower with control"],
                     tips: "Engage your core and glutes. Don't lean back excessively.",
                     difficulty: .intermediate, equipmentNeeded: [.barbell], gifName: "ohp"),
            // Core
            Exercise(name: "Plank", category: .coreStability, muscleGroups: [.core],
                     sets: 3, reps: "60 sec", restSeconds: 45,
                     instructions: ["Start in forearm plank position", "Keep body in straight line from head to heels", "Engage core, squeeze glutes", "Breathe steadily"],
                     tips: "Quality over duration. A 30-second perfect plank beats a 2-min sagging one.",
                     difficulty: .beginner, equipmentNeeded: [.mat], gifName: "plank"),
            Exercise(name: "Russian Twist", category: .coreStability, muscleGroups: [.core],
                     sets: 3, reps: "20 total", restSeconds: 45,
                     instructions: ["Sit with knees bent, lean back slightly", "Hold weight at chest", "Rotate torso side to side", "Touch weight to floor each side"],
                     tips: "Lift feet off floor for extra difficulty. Control the rotation.",
                     difficulty: .beginner, equipmentNeeded: [.dumbbells], gifName: "russian_twist"),
            // Cardio/HIIT
            Exercise(name: "Burpee", category: .hiit, muscleGroups: [.fullBody],
                     sets: 4, reps: "10", restSeconds: 30,
                     instructions: ["Stand, then drop hands to floor", "Jump feet back to push-up position", "Perform push-up", "Jump feet to hands", "Explode up with arms overhead"],
                     tips: "Modify by stepping instead of jumping. Maintain pace over perfection.",
                     difficulty: .intermediate, equipmentNeeded: [.none], gifName: "burpee"),
            Exercise(name: "Mountain Climbers", category: .hiit, muscleGroups: [.core, .fullBody],
                     sets: 3, reps: "40 sec", restSeconds: 20,
                     instructions: ["Start in high plank", "Drive alternate knees to chest rapidly", "Keep hips level", "Maintain strong plank throughout"],
                     tips: "Speed up over time. Keep core tight to avoid hip bouncing.",
                     difficulty: .beginner, equipmentNeeded: [.none], gifName: "mountain_climbers"),
        ]
    }

    // MARK: - Meal Plans
    var allMealPlans: [MealPlan] {
        [standardMealPlan, ketoDietPlan, vegetarianPlan, muscleGainPlan]
    }

    var standardMealPlan: MealPlan {
        MealPlan(
            name: "Balanced Performance",
            goal: .stayFit,
            dietaryPreference: .standard,
            dailyCalorieTarget: 2200,
            proteinGrams: 165,
            carbGrams: 248,
            fatGrams: 61,
            days: standardMealDays()
        )
    }

    var ketoDietPlan: MealPlan {
        MealPlan(
            name: "Keto Fat Burn",
            goal: .loseWeight,
            dietaryPreference: .keto,
            dailyCalorieTarget: 1800,
            proteinGrams: 135,
            carbGrams: 45,
            fatGrams: 120,
            days: ketoMealDays()
        )
    }

    var vegetarianPlan: MealPlan {
        MealPlan(
            name: "Plant Power",
            goal: .stayFit,
            dietaryPreference: .vegetarian,
            dailyCalorieTarget: 2000,
            proteinGrams: 130,
            carbGrams: 250,
            fatGrams: 55,
            days: vegetarianMealDays()
        )
    }

    var muscleGainPlan: MealPlan {
        MealPlan(
            name: "Mass Fuel",
            goal: .buildMuscle,
            dietaryPreference: .standard,
            dailyCalorieTarget: 3000,
            proteinGrams: 225,
            carbGrams: 338,
            fatGrams: 83,
            days: muscleGainMealDays()
        )
    }

    // MARK: - Week Builders
    private func buildMuscleWeeks() -> [WorkoutWeek] {
        (1...8).map { week in
            WorkoutWeek(weekNumber: week, days: [
                WorkoutDay(dayNumber: 1, dayName: "Monday", focus: "Upper Body Push", isRestDay: false,
                           exercises: [exercise("Barbell Bench Press"), exercise("Overhead Press"), exercise("Dumbbell Flyes"), exercise("Push-Up")], estimatedMinutes: 55),
                WorkoutDay(dayNumber: 2, dayName: "Tuesday", focus: "Lower Body", isRestDay: false,
                           exercises: [exercise("Barbell Back Squat"), exercise("Romanian Deadlift"), exercise("Goblet Squat")], estimatedMinutes: 50),
                WorkoutDay(dayNumber: 3, dayName: "Wednesday", focus: "Rest & Recovery", isRestDay: true, exercises: [], estimatedMinutes: 0),
                WorkoutDay(dayNumber: 4, dayName: "Thursday", focus: "Upper Body Pull", isRestDay: false,
                           exercises: [exercise("Pull-Up"), exercise("Barbell Row"), exercise("Russian Twist")], estimatedMinutes: 50),
                WorkoutDay(dayNumber: 5, dayName: "Friday", focus: "Lower Body + Core", isRestDay: false,
                           exercises: [exercise("Barbell Back Squat"), exercise("Romanian Deadlift"), exercise("Plank")], estimatedMinutes: 55),
                WorkoutDay(dayNumber: 6, dayName: "Saturday", focus: "Active Recovery", isRestDay: true, exercises: [], estimatedMinutes: 30),
                WorkoutDay(dayNumber: 7, dayName: "Sunday", focus: "Full Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
            ])
        }
    }

    private func fatLossWeeks() -> [WorkoutWeek] {
        (1...6).map { week in
            WorkoutWeek(weekNumber: week, days: [
                WorkoutDay(dayNumber: 1, dayName: "Monday", focus: "Full Body Circuit", isRestDay: false,
                           exercises: [exercise("Burpee"), exercise("Goblet Squat"), exercise("Push-Up"), exercise("Mountain Climbers"), exercise("Plank")], estimatedMinutes: 45),
                WorkoutDay(dayNumber: 2, dayName: "Tuesday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
                WorkoutDay(dayNumber: 3, dayName: "Wednesday", focus: "HIIT + Strength", isRestDay: false,
                           exercises: [exercise("Mountain Climbers"), exercise("Barbell Back Squat"), exercise("Burpee"), exercise("Pull-Up")], estimatedMinutes: 40),
                WorkoutDay(dayNumber: 4, dayName: "Thursday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
                WorkoutDay(dayNumber: 5, dayName: "Friday", focus: "Full Body + Core", isRestDay: false,
                           exercises: [exercise("Push-Up"), exercise("Romanian Deadlift"), exercise("Russian Twist"), exercise("Burpee")], estimatedMinutes: 45),
                WorkoutDay(dayNumber: 6, dayName: "Saturday", focus: "Light Cardio / Walk", isRestDay: true, exercises: [], estimatedMinutes: 30),
                WorkoutDay(dayNumber: 7, dayName: "Sunday", focus: "Full Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
            ])
        }
    }

    private func enduranceWeeks() -> [WorkoutWeek] {
        (1...10).map { week in
            WorkoutWeek(weekNumber: week, days: [
                WorkoutDay(dayNumber: 1, dayName: "Monday", focus: "Cardio + Core", isRestDay: false,
                           exercises: [exercise("Mountain Climbers"), exercise("Plank"), exercise("Burpee")], estimatedMinutes: 60),
                WorkoutDay(dayNumber: 2, dayName: "Tuesday", focus: "Strength Endurance", isRestDay: false,
                           exercises: [exercise("Push-Up"), exercise("Pull-Up"), exercise("Goblet Squat")], estimatedMinutes: 50),
                WorkoutDay(dayNumber: 3, dayName: "Wednesday", focus: "Active Recovery", isRestDay: true, exercises: [], estimatedMinutes: 30),
                WorkoutDay(dayNumber: 4, dayName: "Thursday", focus: "HIIT Intervals", isRestDay: false,
                           exercises: [exercise("Burpee"), exercise("Mountain Climbers"), exercise("Russian Twist")], estimatedMinutes: 45),
                WorkoutDay(dayNumber: 5, dayName: "Friday", focus: "Long Cardio", isRestDay: false,
                           exercises: [exercise("Mountain Climbers"), exercise("Plank")], estimatedMinutes: 70),
                WorkoutDay(dayNumber: 6, dayName: "Saturday", focus: "Full Body Circuit", isRestDay: false,
                           exercises: [exercise("Pull-Up"), exercise("Barbell Back Squat"), exercise("Push-Up"), exercise("Plank")], estimatedMinutes: 55),
                WorkoutDay(dayNumber: 7, dayName: "Sunday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
            ])
        }
    }

    private func beginnerWeeks() -> [WorkoutWeek] {
        (1...8).map { week in
            WorkoutWeek(weekNumber: week, days: [
                WorkoutDay(dayNumber: 1, dayName: "Monday", focus: "Full Body A", isRestDay: false,
                           exercises: [exercise("Push-Up"), exercise("Goblet Squat"), exercise("Plank")], estimatedMinutes: 35),
                WorkoutDay(dayNumber: 2, dayName: "Tuesday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
                WorkoutDay(dayNumber: 3, dayName: "Wednesday", focus: "Full Body B", isRestDay: false,
                           exercises: [exercise("Mountain Climbers"), exercise("Romanian Deadlift"), exercise("Russian Twist")], estimatedMinutes: 35),
                WorkoutDay(dayNumber: 4, dayName: "Thursday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
                WorkoutDay(dayNumber: 5, dayName: "Friday", focus: "Full Body A", isRestDay: false,
                           exercises: [exercise("Push-Up"), exercise("Goblet Squat"), exercise("Plank")], estimatedMinutes: 35),
                WorkoutDay(dayNumber: 6, dayName: "Saturday", focus: "Light Activity", isRestDay: true, exercises: [], estimatedMinutes: 20),
                WorkoutDay(dayNumber: 7, dayName: "Sunday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
            ])
        }
    }

    private func exercise(_ name: String) -> Exercise {
        allExercises.first(where: { $0.name == name }) ?? allExercises[0]
    }

    // MARK: - Meal Day Builders
    private func standardMealDays() -> [MealDay] {
        let breakfastOptions = [
            Meal(type: .breakfast, name: "Oats & Egg Whites", description: "High-protein power breakfast",
                 calories: 420, proteinGrams: 35, carbGrams: 55, fatGrams: 8,
                 ingredients: ["80g rolled oats", "4 egg whites", "1 tbsp honey", "1 banana", "250ml almond milk"],
                 prepInstructions: ["Cook oats in almond milk for 5 mins", "Scramble egg whites separately", "Top oats with honey and sliced banana"],
                 prepTimeMinutes: 10, imageAsset: "oats"),
        ]
        let lunchOptions = [
            Meal(type: .lunch, name: "Chicken & Rice Bowl", description: "Classic muscle-building lunch",
                 calories: 620, proteinGrams: 55, carbGrams: 75, fatGrams: 12,
                 ingredients: ["180g chicken breast", "150g cooked brown rice", "1 cup broccoli", "1 tbsp olive oil", "Garlic, herbs to taste"],
                 prepInstructions: ["Season and grill chicken", "Steam broccoli", "Serve over rice, drizzle with olive oil"],
                 prepTimeMinutes: 20, imageAsset: "chicken_rice"),
        ]
        let dinnerOptions = [
            Meal(type: .dinner, name: "Salmon & Sweet Potato", description: "Omega-3 rich recovery dinner",
                 calories: 580, proteinGrams: 48, carbGrams: 52, fatGrams: 18,
                 ingredients: ["200g salmon fillet", "200g sweet potato", "Mixed greens", "Lemon", "Dill"],
                 prepInstructions: ["Roast sweet potato at 200°C for 25 mins", "Pan-sear salmon 4 mins each side", "Serve with salad and lemon"],
                 prepTimeMinutes: 30, imageAsset: "salmon"),
        ]
        let snackOptions = [
            Meal(type: .morningSnack, name: "Greek Yogurt & Berries", description: "Probiotic-rich snack",
                 calories: 180, proteinGrams: 15, carbGrams: 22, fatGrams: 3,
                 ingredients: ["200g Greek yogurt (0%)", "100g mixed berries", "1 tsp honey"],
                 prepInstructions: ["Layer yogurt and berries", "Drizzle honey on top"],
                 prepTimeMinutes: 2, imageAsset: "yogurt"),
        ]
        return ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"].map { day in
            MealDay(dayName: day, meals: [breakfastOptions[0], snackOptions[0], lunchOptions[0], dinnerOptions[0]])
        }
    }

    private func ketoMealDays() -> [MealDay] {
        let breakfast = Meal(type: .breakfast, name: "Avocado Egg Bowl", description: "Keto-perfect breakfast",
                             calories: 480, proteinGrams: 28, carbGrams: 8, fatGrams: 40,
                             ingredients: ["2 whole eggs", "1 avocado", "4 bacon strips", "Cherry tomatoes", "Salt, pepper"],
                             prepInstructions: ["Fry eggs and bacon", "Halve and pit avocado", "Serve together with tomatoes"],
                             prepTimeMinutes: 12, imageAsset: "avocado_egg")
        let lunch = Meal(type: .lunch, name: "Zucchini Noodle Bolognese", description: "Low-carb pasta alternative",
                         calories: 520, proteinGrams: 42, carbGrams: 14, fatGrams: 32,
                         ingredients: ["200g ground beef", "2 zucchinis spiralized", "Tomato sauce (no sugar)", "Parmesan", "Olive oil"],
                         prepInstructions: ["Brown beef, add sauce", "Sauté zucchini noodles 2 mins", "Combine and top with parmesan"],
                         prepTimeMinutes: 20, imageAsset: "bolognese")
        let dinner = Meal(type: .dinner, name: "Butter Chicken Thighs", description: "Juicy keto-friendly dinner",
                          calories: 580, proteinGrams: 45, carbGrams: 6, fatGrams: 44,
                          ingredients: ["4 chicken thighs", "3 tbsp butter", "Heavy cream", "Garlic", "Paprika, herbs"],
                          prepInstructions: ["Sear thighs in butter 5 mins each side", "Add cream and garlic, simmer 10 mins", "Season to taste"],
                          prepTimeMinutes: 25, imageAsset: "chicken_thigh")
        return ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"].map { day in
            MealDay(dayName: day, meals: [breakfast, lunch, dinner])
        }
    }

    private func vegetarianMealDays() -> [MealDay] {
        let breakfast = Meal(type: .breakfast, name: "Tofu Scramble", description: "Protein-packed veg breakfast",
                             calories: 380, proteinGrams: 28, carbGrams: 32, fatGrams: 14,
                             ingredients: ["200g firm tofu", "Spinach", "Bell pepper", "Turmeric", "Nutritional yeast"],
                             prepInstructions: ["Crumble tofu in pan", "Add veggies and spices", "Cook 8 mins, stirring frequently"],
                             prepTimeMinutes: 10, imageAsset: "tofu_scramble")
        let lunch = Meal(type: .lunch, name: "Lentil Buddha Bowl", description: "Complete protein vegetarian bowl",
                         calories: 560, proteinGrams: 32, carbGrams: 78, fatGrams: 12,
                         ingredients: ["150g cooked lentils", "Quinoa", "Roasted chickpeas", "Tahini dressing", "Kale"],
                         prepInstructions: ["Cook lentils and quinoa", "Roast chickpeas 20 mins", "Assemble bowl with dressing"],
                         prepTimeMinutes: 25, imageAsset: "buddha_bowl")
        let dinner = Meal(type: .dinner, name: "Paneer Tikka Masala", description: "Creamy Indian classic",
                          calories: 520, proteinGrams: 30, carbGrams: 42, fatGrams: 22,
                          ingredients: ["200g paneer", "Tomato-cream sauce", "Basmati rice", "Spices", "Cilantro"],
                          prepInstructions: ["Grill paneer cubes", "Simmer in spiced tomato-cream sauce", "Serve over rice"],
                          prepTimeMinutes: 30, imageAsset: "paneer")
        return ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"].map { day in
            MealDay(dayName: day, meals: [breakfast, lunch, dinner])
        }
    }

    private func muscleGainMealDays() -> [MealDay] {
        let breakfast = Meal(type: .breakfast, name: "Mass Builder Omelette", description: "Anabolic breakfast",
                             calories: 700, proteinGrams: 58, carbGrams: 60, fatGrams: 24,
                             ingredients: ["4 whole eggs + 2 whites", "3 slices whole grain toast", "100g cottage cheese", "1 banana", "250ml whole milk"],
                             prepInstructions: ["Make full omelette with eggs", "Serve with toast and cottage cheese", "Drink milk on side"],
                             prepTimeMinutes: 15, imageAsset: "omelette")
        let lunch = Meal(type: .lunch, name: "Tuna Pasta Power", description: "Carb + protein powerhouse",
                         calories: 780, proteinGrams: 68, carbGrams: 92, fatGrams: 14,
                         ingredients: ["2 cans tuna in water", "200g cooked pasta", "Low-fat mayo", "Sweetcorn", "Olive oil"],
                         prepInstructions: ["Cook pasta al dente", "Mix tuna, corn, mayo", "Combine, drizzle oil"],
                         prepTimeMinutes: 15, imageAsset: "tuna_pasta")
        let dinner = Meal(type: .dinner, name: "Beef & Quinoa Bowl", description: "Complete amino acid profile",
                          calories: 820, proteinGrams: 72, carbGrams: 78, fatGrams: 26,
                          ingredients: ["250g lean ground beef", "200g cooked quinoa", "Spinach", "Sweet potato", "Salsa"],
                          prepInstructions: ["Brown beef with spices", "Cook quinoa", "Roast sweet potato", "Assemble bowl"],
                          prepTimeMinutes: 30, imageAsset: "beef_bowl")
        return ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"].map { day in
            MealDay(dayName: day, meals: [breakfast, lunch, dinner])
        }
    }
}
