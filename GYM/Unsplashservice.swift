//
//  Unsplashservice.swift
//  GYM
//
//  Created by Mohamed ahmed on 19/09/2026.
//



import SwiftUI

// MARK: - Exercise Image Library
// Each exercise name maps to the EXACT correct photo for that movement

struct ExerciseImageLibrary {

    static let exerciseImages: [String: String] = [

        // ── CHEST / PUSH ─────────────────────────────────────────
        // Barbell Bench Press → man lying on bench pressing barbell
        "Barbell Bench Press":  "pexels-olly-3837743",
        // Dumbbell Bench Press → man lying pressing dumbbells
        "Dumbbell Bench Press": "pexels-foadshariyati-29526383",
        // Dumbbell Flyes → man doing flyes on bench
        "Dumbbell Flyes":       "pexels-alesiakozik-7289232",
        // Push-Up → man doing push-up on gym floor
        "Push-Up":              "pexels-fernando-capetillo-94107723-38167587",
        // Chest Press Machine → man on chest press machine
        "Chest Press":          "pexels-barbara-reis-458096869-16492018",
        // Cable Crossover → man doing cable crossover
        "Cable Crossover":      "pexels-foadshariyati-30672395",
        // Chest Fly → cable chest fly
        "Chest Fly":            "pexels-foadshariyati-29850909",

        // ── BACK / PULL ──────────────────────────────────────────
        // Pull-Up → man doing lat pulldown (back muscles)
       "Pull-Up":              "pexels-foadshariyati-30165244",

        // Lat Pulldown → man doing lat pulldown machine
        "Lat Pulldown":         "pexels-damian-rocafela-1227503006-31843008",
        // Barbell Row → man doing barbell row bent over
        "Barbell Row":          "pexels-omar-abozeid-155326595-35540077",
        // Cable Row → man doing seated cable row
        "Cable Row":            "pexels-shots-by-kevin-2152128897-34137915",

        // ── BICEPS ───────────────────────────────────────────────
        // Dumbbell Curl → man doing seated dumbbell curl
        "Dumbbell Curl":        "pexels-olly-3926651",
        // Barbell Curl → man doing heavy barbell curl
        "Barbell Curl":         "pexels-foadshariyati-32085341",
        // Preacher Curl → man on preacher curl machine
        "Preacher Curl":        "pexels-shotpot-4047160",
        // Hammer Curl → man doing seated dumbbell curl
        "Hammer Curl":          "pexels-olly-3931076",
        // Concentration Curl → man doing concentration curl
        "Concentration Curl":   "pexels-shotpot-4047105",

        // ── TRICEPS ──────────────────────────────────────────────
        // Tricep Pushdown → man doing cable pushdown
        "Tricep Pushdown":      "pexels-muharrem-aydin-921468-6243176",
        "Cable Pushdown":       "pexels-muharrem-aydin-921468-6243176",
        // Tricep Extension → cable extension
        "Tricep Extension":     "pexels-foadshariyati-29778851",
        "Overhead Tricep":      "pexels-wolrider-17626054",

        // ── SHOULDERS ────────────────────────────────────────────
        // Overhead Press → man doing overhead press
//        "Overhead Press":       "pexels-mart-production-8032893",
        "Overhead Press":       "pexels-bulat843-1243575272-37785326",
        // Lateral Raise → lat pulldown back view (shoulder focus)
        "Lateral Raise":        "pexels-foadshariyati-30165244",

        // ── LEGS ─────────────────────────────────────────────────
        // Barbell Back Squat → man squatting with barbell
        "Barbell Back Squat":   "pexels-tima-miroshnichenko-5327530",
        // Goblet Squat → man doing squat position
        "Goblet Squat":         "pexels-mart-production-8032893",
        // Romanian Deadlift → man doing barbell row hinge position
        "Romanian Deadlift":    "pexels-omar-abozeid-155326595-35540077",
        // Deadlift → man lifting heavy barbell from floor
        "Deadlift":             "pexels-ardit-mbrati-216809103-16966285",
        // Calf Raise / Lunge → standing exercises
        "Lunge":                "pexels-katya-wolf-8728632",
        "Calf Raise":           "pexels-keiji-yoshiki-31563-176782",
        "Leg Press":            "pexels-tima-miroshnichenko-5327530",

        // ── CORE ─────────────────────────────────────────────────
        // Plank → man doing forearm plank on mat
        "Plank":                "pexels-shotpot-4047105",
        // Russian Twist → man hanging/core exercise
        "Russian Twist":        "pexels-hamidtajikph-17959560",
        // Hanging Leg Raise → man hanging from bar raising legs
        "Hanging Leg Raise":    "pexels-hamidtajikph-17959560",

        // ── HIIT / CARDIO ─────────────────────────────────────────
        // Mountain Climbers → man doing push-up position (plank base)
        "Mountain Climbers":    "pexels-fernando-capetillo-94107723-38167587",
        // Burpee → sled push / full body explosive
        "Burpee":               "pexels-leonmart-1552104",
    ]

    // Per-plan: different photo for same exercise → different plans show different photos
    static let planVariations: [String: [String: String]] = [

        "buildMuscle": [
            "Barbell Bench Press": "pexels-olly-3837743",
            "Push-Up":             "pexels-keiji-yoshiki-31563-176782",
            "Dumbbell Flyes":      "pexels-alesiakozik-7289232",
            "Pull-Up":             "pexels-foadshariyati-30165244",
            "Barbell Row":         "pexels-omar-abozeid-155326595-35540077",
            "Barbell Back Squat":  "pexels-tima-miroshnichenko-5327530",
            "Romanian Deadlift":   "pexels-ardit-mbrati-216809103-16966285",
            "Goblet Squat":        "pexels-mart-production-8032893",
            "Overhead Press":      "pexels-mart-production-8032893",
            "Plank":               "pexels-shotpot-4047105",
            "Russian Twist":       "pexels-hamidtajikph-17959560",
            "Burpee":              "pexels-leonmart-1552104",
            "Mountain Climbers":   "pexels-fernando-capetillo-94107723-38167587",
        ],

        "loseWeight": [
            "Barbell Bench Press": "pexels-barbara-reis-458096869-16492018",
            "Push-Up":             "pexels-fernando-capetillo-94107723-38167587",
            "Dumbbell Flyes":      "pexels-foadshariyati-29850909",
            "Pull-Up":             "pexels-damian-rocafela-1227503006-31843008",
            "Barbell Row":         "pexels-shots-by-kevin-2152128897-34137915",
            "Barbell Back Squat":  "pexels-tima-miroshnichenko-5327530",
            "Romanian Deadlift":   "pexels-omar-abozeid-155326595-35540077",
            "Goblet Squat":        "pexels-mart-production-8032893",
            "Overhead Press":      "pexels-foadshariyati-30165244",
            "Plank":               "pexels-shotpot-4047105",
            "Russian Twist":       "pexels-hamidtajikph-17959560",
            "Burpee":              "pexels-leonmart-1552104",
            "Mountain Climbers":   "pexels-fernando-capetillo-94107723-38167587",
        ],

        "improveEndurance": [
            "Barbell Bench Press": "pexels-foadshariyati-29526383",
            "Push-Up":             "pexels-keiji-yoshiki-31563-176782",
            "Dumbbell Flyes":      "pexels-foadshariyati-30672395",
            "Pull-Up":             "pexels-foadshariyati-30165244",
            "Barbell Row":         "pexels-omar-abozeid-155326595-35540077",
            "Barbell Back Squat":  "pexels-ardit-mbrati-216809103-16966285",
            "Romanian Deadlift":   "pexels-omar-abozeid-155326595-35540077",
            "Goblet Squat":        "pexels-mart-production-8032893",
            "Overhead Press":      "pexels-mart-production-8032893",
            "Plank":               "pexels-shotpot-4047105",
            "Russian Twist":       "pexels-hamidtajikph-17959560",
            "Burpee":              "pexels-leonmart-1552104",
            "Mountain Climbers":   "pexels-fernando-capetillo-94107723-38167587",
        ],

        "stayFit": [
            "Barbell Bench Press": "pexels-olly-3837743",
            "Push-Up":             "pexels-keiji-yoshiki-31563-176782",
            "Dumbbell Flyes":      "pexels-alesiakozik-7289232",
            "Pull-Up":             "pexels-damian-rocafela-1227503006-31843008",
            "Barbell Row":         "pexels-shots-by-kevin-2152128897-34137915",
            "Barbell Back Squat":  "pexels-tima-miroshnichenko-5327530",
            "Romanian Deadlift":   "pexels-ardit-mbrati-216809103-16966285",
            "Goblet Squat":        "pexels-mart-production-8032893",
            "Overhead Press":      "pexels-mart-production-8032893",
            "Plank":               "pexels-shotpot-4047105",
            "Russian Twist":       "pexels-hamidtajikph-17959560",
            "Burpee":              "pexels-leonmart-1552104",
            "Mountain Climbers":   "pexels-fernando-capetillo-94107723-38167587",
        ],
    ]

    static func imageName(for exerciseName: String, goal: FitnessGoal? = nil) -> String? {
        if let goal = goal {
            if let name = planVariations[goalKey(goal)]?[exerciseName] { return name }
        }
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

// MARK: - Exercise Hero Image View
struct ExerciseHeroImageView: View {
    let exerciseName: String
    let height: CGFloat
    var goal: FitnessGoal? = nil
    var photoID: String? = nil

    var body: some View {
        let assetName = ExerciseImageLibrary.imageName(for: exerciseName, goal: goal)
        Group {
            if let name = assetName, UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: gradientColors(for: exerciseName),
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    VStack(spacing: 10) {
                        Image(systemName: fitnessIcon(for: exerciseName))
                            .font(.system(size: 50)).foregroundColor(.white.opacity(0.9))
                        Text(exerciseName)
                            .font(.subheadline).bold().foregroundColor(.white)
                            .multilineTextAlignment(.center).padding(.horizontal, 12)
                    }
                }
            }
        }
        .frame(height: height)
        .clipped()
    }

    func gradientColors(for name: String) -> [Color] {
        let n = name.lowercased()
        if n.contains("bench") || n.contains("flye") || n.contains("push") || n.contains("chest") {
            return [Color(red:0.1,green:0.3,blue:0.6), Color(red:0.2,green:0.5,blue:0.8)]
        }
        if n.contains("pull") || n.contains("row") || n.contains("lat") {
            return [Color(red:0.1,green:0.4,blue:0.3), Color(red:0.2,green:0.6,blue:0.4)]
        }
        if n.contains("squat") || n.contains("deadlift") || n.contains("lunge") || n.contains("leg") {
            return [Color(red:0.5,green:0.1,blue:0.2), Color(red:0.7,green:0.2,blue:0.3)]
        }
        if n.contains("press") || n.contains("shoulder") || n.contains("lateral") {
            return [Color(red:0.5,green:0.3,blue:0.1), Color(red:0.7,green:0.5,blue:0.1)]
        }
        if n.contains("curl") || n.contains("bicep") {
            return [Color(red:0.3,green:0.1,blue:0.5), Color(red:0.5,green:0.2,blue:0.7)]
        }
        if n.contains("tricep") || n.contains("pushdown") {
            return [Color(red:0.4,green:0.1,blue:0.4), Color(red:0.6,green:0.2,blue:0.6)]
        }
        if n.contains("plank") || n.contains("twist") || n.contains("core") || n.contains("crunch") {
            return [Color(red:0.1,green:0.3,blue:0.4), Color(red:0.2,green:0.5,blue:0.6)]
        }
        if n.contains("burpee") || n.contains("mountain") || n.contains("jump") {
            return [Color(red:0.6,green:0.2,blue:0.1), Color(red:0.8,green:0.4,blue:0.1)]
        }
        return [Color(red:0.1,green:0.4,blue:0.2), Color(red:0.2,green:0.6,blue:0.3)]
    }

    func fitnessIcon(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("bench") || n.contains("flye") || n.contains("chest") { return "figure.strengthtraining.traditional" }
        if n.contains("push")   { return "figure.strengthtraining.traditional" }
        if n.contains("pull") || n.contains("row") || n.contains("lat") { return "figure.pull.up" }
        if n.contains("squat") || n.contains("deadlift") || n.contains("lunge") { return "figure.squat" }
        if n.contains("press")  { return "figure.strengthtraining.traditional" }
        if n.contains("plank") || n.contains("twist") || n.contains("crunch") { return "figure.core.training" }
        if n.contains("burpee") || n.contains("mountain") { return "figure.hiit.training" }
        if n.contains("curl")   { return "figure.arms.open" }
        return "figure.mixed.cardio"
    }

    static func fallbackPhotoID(for name: String) -> String { "1552106" }
}

// MARK: - Food Image Service
struct FoodImageService {
    static let photoMap: [(keywords: [String], ids: [String])] = [
        (["oat","overnight","oatmeal"],             ["3756523","1092730","704569"]),
        (["egg","omelette","scramble","hash"],       ["566566","824635","1132047"]),
        (["avocado"],                               ["1656663","2097090","1143754"]),
        (["pancake","waffle"],                      ["376464","3434523","1099680"]),
        (["smoothie","acai","bowl"],                ["1346347","775031","1099680"]),
        (["yogurt","parfait"],                      ["1092730","3184183","1499908"]),
        (["salmon bagel","smoked salmon"],          ["3763847","1640777","3184183"]),
        (["chia"],                                  ["1640774","3184183","1499908"]),
        (["chicken rice","chicken & rice"],         ["2338407","1410235","769289"]),
        (["tuna"],                                  ["1279330","3184183","1640777"]),
        (["quinoa"],                                ["1640777","1213710","2097090"]),
        (["salmon"],                                ["3763847","1640777","1516415"]),
        (["beef","steak"],                          ["1251208","3535383","675951"]),
        (["pasta","noodle","bolognese"],            ["1279330","1438672","769563"]),
        (["chicken"],                               ["2338407","1410235","769289"]),
        (["lamb","kofta"],                          ["2474661","1640774","675951"]),
        (["shrimp","prawn"],                        ["769289","1640777","3184183"]),
        (["pork"],                                  ["1251208","675951","3535383"]),
        (["salad"],                                 ["1213710","1640777","3184183"]),
        (["curry","lentil","chickpea","dal"],       ["2474661","1640774","1143754"]),
        (["burrito","taco","wrap","falafel"],       ["1640777","2097090","1213710"]),
        (["bowl"],                                  ["1640777","1213710","2097090"]),
        (["soup","stew","tagine"],                  ["1640777","2097090","3184183"]),
        (["risotto","mushroom"],                    ["1557673","1640777","3184183"]),
        (["rice"],                                  ["769289","1640777","3184183"]),
        (["berry","berries","fruit","mango"],       ["1132047","918327","1499908"]),
        (["nut","almond"],                          ["1143754","1640777","3184183"]),
        (["protein"],                               ["1640777","1092730","3184183"]),
        (["hummus"],                                ["1640774","3184183","1499908"]),
        (["bread","toast","bagel"],                 ["1132047","1640777","3184183"]),
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
        if n.contains("salmon") || n.contains("fish") || n.contains("cod") { return "🐟" }
        if n.contains("beef") || n.contains("steak") || n.contains("lamb") { return "🥩" }
        if n.contains("pork")     { return "🥓" }
        if n.contains("shrimp") || n.contains("prawn") { return "🦐" }
        if n.contains("egg")      { return "🍳" }
        if n.contains("avocado")  { return "🥑" }
        if n.contains("salad")    { return "🥗" }
        if n.contains("pasta") || n.contains("noodle") { return "🍝" }
        if n.contains("smoothie") || n.contains("shake") { return "🥤" }
        if n.contains("yogurt")   { return "🥛" }
        if n.contains("oat") || n.contains("waffle") || n.contains("pancake") { return "🥣" }
        if n.contains("bowl")     { return "🥗" }
        if n.contains("rice")     { return "🍚" }
        if n.contains("soup") || n.contains("stew") || n.contains("curry") { return "🍲" }
        if n.contains("berry") || n.contains("mango") { return "🍓" }
        return "🍽️"
    }
}
