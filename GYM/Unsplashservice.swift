//
//  Unsplashservice.swift
//  GYM
//
//  Created by Mohamed ahmed on 19/09/2026.
//



import SwiftUI

// MARK: - Local Exercise Image Library
// Maps each exercise name to the correct local image asset name
// Images are stored in Assets.xcassets/ExerciseImages/

struct ExerciseImageLibrary {

    // exercise name → asset image name
    static let exerciseImages: [String: String] = [

        // ── CHEST ────────────────────────────────────────────────
        "Barbell Bench Press":  "pexels-olly-3837743",       // man barbell bench press
        "Push-Up":              "pexels-olly-3916762",       // man bench press barbell
        "Dumbbell Flyes":       "pexels-alesiakozik-7289232",// dumbbell flyes on bench
        "Chest Press":          "pexels-moralestorres98-34669288", // chest press machine

        // ── BACK ─────────────────────────────────────────────────
        "Pull-Up":              "pexels-hamidtajikph-17959560",   // hanging pull-up bar
        "Barbell Row":          "pexels-wolrider-17626053",       // cable row / seated row
        "Cable Row":            "pexels-wolrider-17626053",       // cable row

        // ── BICEPS ───────────────────────────────────────────────
        "Dumbbell Curl":        "pexels-olly-3926651",        // dumbbell curl seated
        "Barbell Curl":         "pexels-foadshariyati-32085341",  // barbell curl heavy
        "Preacher Curl":        "pexels-shotpot-4047160",     // preacher curl machine
        "Concentration Curl":   "pexels-olly-3931076",        // seated concentration curl

        // ── TRICEPS ──────────────────────────────────────────────
        "Tricep Pushdown":      "pexels-muharrem-aydin-921468-6243176", // cable tricep pushdown
        "Cable Pushdown":       "pexels-muharrem-aydin-921468-6243176",
        "Tricep Extension":     "pexels-wolrider-17626054",   // cable crossover / tricep
        "Overhead Tricep":      "pexels-wolrider-17626054",

        // ── SHOULDERS ────────────────────────────────────────────
        "Overhead Press":       "pexels-tima-miroshnichenko-5327478", // barbell curl / shoulder
        "Lateral Raise":        "pexels-foadshariyati-29850909",  // cable lateral / chest fly
        "Face Pull":            "pexels-foadshariyati-30672395",  // cable crossover

        // ── LEGS ─────────────────────────────────────────────────
        "Barbell Back Squat":   "pexels-tima-miroshnichenko-5327530", // squat rack
        "Romanian Deadlift":    "pexels-tima-miroshnichenko-5327530",
        "Goblet Squat":         "pexels-tima-miroshnichenko-5327530",
        "Leg Press":            "pexels-tima-miroshnichenko-5327530",

        // ── CORE / HIIT ──────────────────────────────────────────
        "Plank":                "pexels-hamidtajikph-17959560",   // hanging core / abs
        "Russian Twist":        "pexels-hamidtajikph-17959560",
        "Burpee":               "pexels-leonmart-1552104",    // sled push / HIIT
        "Mountain Climbers":    "pexels-leonmart-1552104",
        "Sled Push":            "pexels-leonmart-1552104",

        // ── EXTRA ────────────────────────────────────────────────
        "Dumbbell Bench Press": "pexels-foadshariyati-29526383",  // dumbbell bench press
        "Cable Crossover":      "pexels-foadshariyati-30672395",  // cable crossover chest
        "Chest Fly":            "pexels-foadshariyati-29850909",
    ]

    // Per-plan variations — different photo for same exercise in different plans
    static let planVariations: [String: [String: String]] = [
        "buildMuscle": [
            "Barbell Bench Press": "pexels-olly-3837743",
            "Push-Up":             "pexels-foadshariyati-29526383",
            "Dumbbell Flyes":      "pexels-alesiakozik-7289232",
            "Pull-Up":             "pexels-hamidtajikph-17959560",
            "Barbell Row":         "pexels-wolrider-17626053",
            "Barbell Back Squat":  "pexels-tima-miroshnichenko-5327530",
            "Romanian Deadlift":   "pexels-tima-miroshnichenko-5327530",
            "Goblet Squat":        "pexels-tima-miroshnichenko-5327530",
            "Overhead Press":      "pexels-tima-miroshnichenko-5327478",
            "Plank":               "pexels-hamidtajikph-17959560",
            "Russian Twist":       "pexels-hamidtajikph-17959560",
            "Burpee":              "pexels-leonmart-1552104",
            "Mountain Climbers":   "pexels-leonmart-1552104",
        ],
        "loseWeight": [
            "Barbell Bench Press": "pexels-olly-3916762",
            "Push-Up":             "pexels-moralestorres98-34669288",
            "Dumbbell Flyes":      "pexels-foadshariyati-29850909",
            "Pull-Up":             "pexels-hamidtajikph-17959560",
            "Barbell Row":         "pexels-wolrider-17626054",
            "Barbell Back Squat":  "pexels-tima-miroshnichenko-5327530",
            "Romanian Deadlift":   "pexels-tima-miroshnichenko-5327530",
            "Goblet Squat":        "pexels-tima-miroshnichenko-5327530",
            "Overhead Press":      "pexels-foadshariyati-32085341",
            "Plank":               "pexels-leonmart-1552104",
            "Russian Twist":       "pexels-leonmart-1552104",
            "Burpee":              "pexels-leonmart-1552104",
            "Mountain Climbers":   "pexels-hamidtajikph-17959560",
        ],
        "improveEndurance": [
            "Barbell Bench Press": "pexels-foadshariyati-29526383",
            "Push-Up":             "pexels-olly-3916762",
            "Dumbbell Flyes":      "pexels-foadshariyati-30672395",
            "Pull-Up":             "pexels-hamidtajikph-17959560",
            "Barbell Row":         "pexels-wolrider-17626053",
            "Barbell Back Squat":  "pexels-tima-miroshnichenko-5327530",
            "Romanian Deadlift":   "pexels-tima-miroshnichenko-5327530",
            "Goblet Squat":        "pexels-tima-miroshnichenko-5327530",
            "Overhead Press":      "pexels-muharrem-aydin-921468-6243176",
            "Plank":               "pexels-leonmart-1552104",
            "Russian Twist":       "pexels-hamidtajikph-17959560",
            "Burpee":              "pexels-leonmart-1552104",
            "Mountain Climbers":   "pexels-leonmart-1552104",
        ],
        "stayFit": [
            "Barbell Bench Press": "pexels-olly-3837743",
            "Push-Up":             "pexels-moralestorres98-34669288",
            "Dumbbell Flyes":      "pexels-alesiakozik-7289232",
            "Pull-Up":             "pexels-hamidtajikph-17959560",
            "Barbell Row":         "pexels-wolrider-17626054",
            "Barbell Back Squat":  "pexels-tima-miroshnichenko-5327530",
            "Romanian Deadlift":   "pexels-tima-miroshnichenko-5327530",
            "Goblet Squat":        "pexels-tima-miroshnichenko-5327530",
            "Overhead Press":      "pexels-tima-miroshnichenko-5327478",
            "Plank":               "pexels-hamidtajikph-17959560",
            "Russian Twist":       "pexels-leonmart-1552104",
            "Burpee":              "pexels-leonmart-1552104",
            "Mountain Climbers":   "pexels-leonmart-1552104",
        ],
    ]

    static func imageName(for exerciseName: String, goal: FitnessGoal? = nil) -> String? {
        // 1. Plan-specific variation
        if let goal = goal {
            let key = goalKey(goal)
            if let name = planVariations[key]?[exerciseName] { return name }
        }
        // 2. Default mapping
        return exerciseImages[exerciseName]
    }

    static func goalKey(_ goal: FitnessGoal) -> String {
        switch goal {
        case .buildMuscle:      return "buildMuscle"
        case .loseWeight:       return "loseWeight"
        case .improveEndurance: return "improveEndurance"
        case .stayFit:          return "stayFit"
        }
    }
}

// MARK: - Exercise Hero Image View (uses local assets first, Pexels fallback)
struct ExerciseHeroImageView: View {
    let exerciseName: String
    let height: CGFloat
    var goal: FitnessGoal? = nil
    var photoID: String? = nil

    var body: some View {
        // Try local asset first
        if let assetName = ExerciseImageLibrary.imageName(for: exerciseName, goal: goal),
           UIImage(named: assetName) != nil {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(height: height)
                .clipped()
        } else {
            // Fallback gradient with icon
            ZStack {
                LinearGradient(
                    colors: gradientColors(for: exerciseName),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                VStack(spacing: 10) {
                    Image(systemName: fitnessIcon(for: exerciseName))
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.9))
                    Text(exerciseName)
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
            }
            .frame(height: height)
        }
    }

    func gradientColors(for name: String) -> [Color] {
        let n = name.lowercased()
        if n.contains("bench") || n.contains("flye") || n.contains("push") {
            return [Color(red:0.1, green:0.3, blue:0.6), Color(red:0.2, green:0.5, blue:0.8)]
        }
        if n.contains("pull") || n.contains("row") {
            return [Color(red:0.1, green:0.4, blue:0.3), Color(red:0.2, green:0.6, blue:0.4)]
        }
        if n.contains("squat") || n.contains("deadlift") || n.contains("leg") {
            return [Color(red:0.5, green:0.1, blue:0.2), Color(red:0.7, green:0.2, blue:0.3)]
        }
        if n.contains("press") || n.contains("shoulder") || n.contains("lateral") {
            return [Color(red:0.5, green:0.3, blue:0.1), Color(red:0.7, green:0.5, blue:0.1)]
        }
        if n.contains("curl") || n.contains("bicep") {
            return [Color(red:0.3, green:0.1, blue:0.5), Color(red:0.5, green:0.2, blue:0.7)]
        }
        if n.contains("tricep") || n.contains("pushdown") {
            return [Color(red:0.4, green:0.1, blue:0.4), Color(red:0.6, green:0.2, blue:0.6)]
        }
        if n.contains("plank") || n.contains("twist") || n.contains("core") {
            return [Color(red:0.1, green:0.3, blue:0.4), Color(red:0.2, green:0.5, blue:0.6)]
        }
        if n.contains("burpee") || n.contains("mountain") || n.contains("hiit") {
            return [Color(red:0.6, green:0.2, blue:0.1), Color(red:0.8, green:0.4, blue:0.1)]
        }
        return [Color(red:0.1, green:0.4, blue:0.2), Color(red:0.2, green:0.6, blue:0.3)]
    }

    func fitnessIcon(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("bench") || n.contains("flye") || n.contains("push") { return "figure.strengthtraining.traditional" }
        if n.contains("pull") || n.contains("row")   { return "figure.pull.up" }
        if n.contains("squat") || n.contains("deadlift") { return "figure.squat" }
        if n.contains("press")  { return "figure.strengthtraining.traditional" }
        if n.contains("plank") || n.contains("twist") { return "figure.core.training" }
        if n.contains("burpee") || n.contains("mountain") { return "figure.hiit.training" }
        if n.contains("curl")   { return "figure.arms.open" }
        return "figure.mixed.cardio"
    }

    static func fallbackPhotoID(for name: String) -> String { "1552106" }
}

// MARK: - Food Image Service (unchanged)
struct FoodImageService {
    static let photoMap: [(keywords: [String], ids: [String])] = [
        (["oat","overnight","oatmeal"],             ["3756523","1092730","704569"]),
        (["egg","omelette","scramble","hash"],       ["566566","824635","1132047"]),
        (["avocado"],                               ["1656663","2097090","1143754"]),
        (["pancake","waffle"],                      ["376464","3434523","1099680"]),
        (["smoothie","acai","bowl"],                ["1346347","775031","1099680"]),
        (["yogurt","parfait"],                      ["1092730","3184183","1499908"]),
        (["salmon bagel","bagel","smoked salmon"],  ["3763847","1640777","3184183"]),
        (["chia"],                                  ["1640774","3184183","1499908"]),
        (["chicken rice","chicken & rice"],         ["2338407","1410235","769289"]),
        (["tuna"],                                  ["1279330","3184183","1640777"]),
        (["quinoa"],                                ["1640777","1213710","2097090"]),
        (["salmon"],                                ["3763847","1640777","1516415"]),
        (["beef","steak"],                          ["1251208","3535383","675951"]),
        (["pasta","noodle"],                        ["1279330","1438672","769563"]),
        (["chicken"],                               ["2338407","1410235","769289"]),
        (["lamb","kofta"],                          ["2474661","1640774","675951"]),
        (["shrimp","prawn"],                        ["769289","1640777","3184183"]),
        (["pork"],                                  ["1251208","675951","3535383"]),
        (["salad"],                                 ["1213710","1640777","3184183"]),
        (["curry","lentil","chickpea"],             ["2474661","1640774","1143754"]),
        (["burrito","taco","wrap"],                 ["1640777","2097090","1213710"]),
        (["bowl"],                                  ["1640777","1213710","2097090"]),
        (["soup","stew"],                           ["1640777","2097090","3184183"]),
        (["risotto","mushroom"],                    ["1557673","1640777","3184183"]),
        (["rice"],                                  ["769289","1640777","3184183"]),
        (["berry","berries","fruit"],               ["1132047","918327","1499908"]),
        (["nut","almond"],                          ["1143754","1640777","3184183"]),
        (["protein"],                               ["1640777","1092730","3184183"]),
    ]

    static func imageURL(for mealName: String) -> String {
        let name = mealName.lowercased()
        for entry in photoMap {
            if entry.keywords.contains(where: { name.contains($0) }) {
                let idx = abs(mealName.hashValue) % entry.ids.count
                return pexelsURL(entry.ids[idx])
            }
        }
        let fallback = ["1640777","1213710","1143754","769289","2097090"]
        return pexelsURL(fallback[abs(mealName.hashValue) % fallback.count])
    }

    static func pexelsURL(_ id: String) -> String {
        "https://images.pexels.com/photos/\(id)/pexels-photo-\(id).jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop"
    }
}

// MARK: - Meal Image View
struct MealImageView: View {
    let mealName: String
    let height: CGFloat

    var body: some View {
        AsyncImage(url: URL(string: FoodImageService.imageURL(for: mealName))) { phase in
            switch phase {
            case .empty:
                ZStack {
                    LinearGradient(colors: [.green.opacity(0.35), .mint.opacity(0.2)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    VStack(spacing: 8) {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(1.3)
                        Text(mealName).font(.caption).foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center).padding(.horizontal, 12)
                    }
                }
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                ZStack {
                    LinearGradient(colors: [.green.opacity(0.5), .mint.opacity(0.3)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    VStack(spacing: 10) {
                        Text(foodEmoji(for: mealName)).font(.system(size: 52))
                        Text(mealName).font(.subheadline).bold().foregroundColor(.white)
                            .multilineTextAlignment(.center).padding(.horizontal, 16)
                    }
                }
            @unknown default:
                Color(.systemGray5)
            }
        }
        .frame(height: height).clipped()
    }

    func foodEmoji(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("chicken")  { return "🍗" }
        if n.contains("salmon") || n.contains("fish") { return "🐟" }
        if n.contains("beef") || n.contains("steak") || n.contains("lamb") { return "🥩" }
        if n.contains("pork")     { return "🥓" }
        if n.contains("shrimp") || n.contains("prawn") { return "🦐" }
        if n.contains("egg")      { return "🍳" }
        if n.contains("avocado")  { return "🥑" }
        if n.contains("salad")    { return "🥗" }
        if n.contains("pasta")    { return "🍝" }
        if n.contains("smoothie") || n.contains("shake") { return "🥤" }
        if n.contains("yogurt")   { return "🥛" }
        if n.contains("oat") || n.contains("waffle") || n.contains("pancake") { return "🥣" }
        if n.contains("bowl")     { return "🥗" }
        if n.contains("rice")     { return "🍚" }
        if n.contains("soup") || n.contains("stew") || n.contains("curry") { return "🍲" }
        if n.contains("berry")    { return "🍓" }
        return "🍽️"
    }
}

