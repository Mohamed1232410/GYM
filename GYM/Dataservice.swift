//
//  Dataservice.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.



import Foundation

class DataService {
    static let shared = DataService()

    // MARK: - Workout Plans
    var allWorkoutPlans: [WorkoutPlan] {
        [muscleBuilding4DayPlan, fatLoss3DayPlan, endurance5DayPlan, fullBodyBeginnerPlan]
    }

    var muscleBuilding4DayPlan: WorkoutPlan {
        WorkoutPlan(name: "Mass Builder Pro",
                    description: "A classic 4-day upper/lower split designed to maximize hypertrophy with progressive overload.",
                    goal: .buildMuscle, durationWeeks: 8, daysPerWeek: 4, difficulty: .intermediate,
                    weeks: buildMuscleWeeks())
    }
    var fatLoss3DayPlan: WorkoutPlan {
        WorkoutPlan(name: "Shred Circuit",
                    description: "High-intensity 3-day full-body circuit training to torch calories and preserve muscle.",
                    goal: .loseWeight, durationWeeks: 6, daysPerWeek: 3, difficulty: .intermediate,
                    weeks: fatLossWeeks())
    }
    var endurance5DayPlan: WorkoutPlan {
        WorkoutPlan(name: "Endurance Elite",
                    description: "5-day progressive cardio and strength endurance program for athletic performance.",
                    goal: .improveEndurance, durationWeeks: 10, daysPerWeek: 5, difficulty: .advanced,
                    weeks: enduranceWeeks())
    }
    var fullBodyBeginnerPlan: WorkoutPlan {
        WorkoutPlan(name: "Beginner Foundation",
                    description: "3-day full-body program covering all fundamentals — perfect for those just starting out.",
                    goal: .stayFit, durationWeeks: 8, daysPerWeek: 3, difficulty: .beginner,
                    weeks: beginnerWeeks())
    }

    // MARK: - Exercise Library
    var allExercises: [Exercise] {[
        Exercise(name: "Barbell Bench Press", category: .strength, muscleGroups: [.chest,.triceps,.shoulders], sets: 4, reps: "8-10", restSeconds: 90, instructions: ["Lie flat on bench","Grip bar slightly wider than shoulder-width","Lower bar to mid-chest","Press explosively back up","Keep feet flat, back slightly arched"], tips: "Focus on squeezing pecs at the top.", difficulty: .intermediate, equipmentNeeded: [.barbell,.bench], gifName: "bench_press"),
        Exercise(name: "Push-Up", category: .strength, muscleGroups: [.chest,.triceps,.core], sets: 3, reps: "12-15", restSeconds: 60, instructions: ["Start in high plank position","Lower body until chest nearly touches floor","Keep core tight and body straight","Push back up"], tips: "Scale by doing knee push-ups if needed.", difficulty: .beginner, equipmentNeeded: [.none], gifName: "pushup"),
        Exercise(name: "Dumbbell Flyes", category: .strength, muscleGroups: [.chest], sets: 3, reps: "12", restSeconds: 60, instructions: ["Lie on bench with dumbbells above chest","Lower arms out to sides","Feel chest stretch at bottom","Bring dumbbells back together"], tips: "Control the negative. Don't go too heavy.", difficulty: .intermediate, equipmentNeeded: [.dumbbells,.bench], gifName: "db_flye"),
        Exercise(name: "Pull-Up", category: .strength, muscleGroups: [.back,.biceps], sets: 4, reps: "6-10", restSeconds: 90, instructions: ["Hang from bar with overhand grip","Pull chest to bar","Hold briefly at top","Lower with control"], tips: "Focus on lat engagement.", difficulty: .intermediate, equipmentNeeded: [.pullUpBar], gifName: "pullup"),
        Exercise(name: "Barbell Row", category: .strength, muscleGroups: [.back,.biceps,.forearms], sets: 4, reps: "8-10", restSeconds: 90, instructions: ["Hinge at hips with flat back","Grip bar shoulder-width","Pull bar to lower chest","Squeeze shoulder blades"], tips: "Pull with your elbows, not your hands.", difficulty: .intermediate, equipmentNeeded: [.barbell], gifName: "barbell_row"),
        Exercise(name: "Barbell Back Squat", category: .strength, muscleGroups: [.quadriceps,.hamstrings,.glutes], sets: 4, reps: "6-8", restSeconds: 120, instructions: ["Position bar on upper traps","Stand with feet shoulder-width","Break at hips and knees","Lower until thighs parallel","Drive through heels"], tips: "Keep chest up and knees tracking over toes.", difficulty: .intermediate, equipmentNeeded: [.barbell], gifName: "squat"),
        Exercise(name: "Romanian Deadlift", category: .strength, muscleGroups: [.hamstrings,.glutes,.back], sets: 3, reps: "10-12", restSeconds: 90, instructions: ["Hold bar at hip level","Hinge at hips pushing back","Lower bar along thighs","Drive hips forward to return"], tips: "Keep slight bend in knees.", difficulty: .intermediate, equipmentNeeded: [.barbell], gifName: "rdl"),
        Exercise(name: "Goblet Squat", category: .strength, muscleGroups: [.quadriceps,.glutes,.core], sets: 3, reps: "12-15", restSeconds: 60, instructions: ["Hold dumbbell at chest","Feet slightly wider, toes out","Squat deep keeping chest up","Drive up through heels"], tips: "Great for beginners.", difficulty: .beginner, equipmentNeeded: [.dumbbells], gifName: "goblet_squat"),
        Exercise(name: "Overhead Press", category: .strength, muscleGroups: [.shoulders,.triceps], sets: 4, reps: "8-10", restSeconds: 90, instructions: ["Stand with bar at upper chest","Grip just outside shoulder-width","Press bar directly overhead","Lock out arms at top","Lower with control"], tips: "Engage your core and glutes.", difficulty: .intermediate, equipmentNeeded: [.barbell], gifName: "ohp"),
        Exercise(name: "Plank", category: .coreStability, muscleGroups: [.core], sets: 3, reps: "60 sec", restSeconds: 45, instructions: ["Start in forearm plank","Keep body in straight line","Engage core, squeeze glutes","Breathe steadily"], tips: "Quality over duration.", difficulty: .beginner, equipmentNeeded: [.mat], gifName: "plank"),
        Exercise(name: "Russian Twist", category: .coreStability, muscleGroups: [.core], sets: 3, reps: "20 total", restSeconds: 45, instructions: ["Sit with knees bent, lean back","Hold weight at chest","Rotate torso side to side","Touch weight to floor each side"], tips: "Lift feet for extra difficulty.", difficulty: .beginner, equipmentNeeded: [.dumbbells], gifName: "russian_twist"),
        Exercise(name: "Burpee", category: .hiit, muscleGroups: [.fullBody], sets: 4, reps: "10", restSeconds: 30, instructions: ["Stand, drop hands to floor","Jump feet back to push-up position","Perform push-up","Jump feet to hands","Explode up with arms overhead"], tips: "Maintain pace over perfection.", difficulty: .intermediate, equipmentNeeded: [.none], gifName: "burpee"),
        Exercise(name: "Mountain Climbers", category: .hiit, muscleGroups: [.core,.fullBody], sets: 3, reps: "40 sec", restSeconds: 20, instructions: ["Start in high plank","Drive alternate knees to chest","Keep hips level","Maintain strong plank"], tips: "Speed up over time.", difficulty: .beginner, equipmentNeeded: [.none], gifName: "mountain_climbers"),
    ]}

    // MARK: - Meal Plans
    var allMealPlans: [MealPlan] {
        [standardMealPlan, ketoDietPlan, vegetarianPlan, muscleGainPlan]
    }

    var standardMealPlan: MealPlan {
        MealPlan(name: "Balanced Performance", goal: .stayFit, dietaryPreference: .standard,
                 dailyCalorieTarget: 2200, proteinGrams: 165, carbGrams: 248, fatGrams: 61,
                 days: standardMealDays())
    }
    var ketoDietPlan: MealPlan {
        MealPlan(name: "Keto Fat Burn", goal: .loseWeight, dietaryPreference: .keto,
                 dailyCalorieTarget: 1800, proteinGrams: 135, carbGrams: 45, fatGrams: 120,
                 days: ketoMealDays())
    }
    var vegetarianPlan: MealPlan {
        MealPlan(name: "Plant Power", goal: .stayFit, dietaryPreference: .vegetarian,
                 dailyCalorieTarget: 2000, proteinGrams: 130, carbGrams: 250, fatGrams: 55,
                 days: vegetarianMealDays())
    }
    var muscleGainPlan: MealPlan {
        MealPlan(name: "Mass Fuel", goal: .buildMuscle, dietaryPreference: .standard,
                 dailyCalorieTarget: 3000, proteinGrams: 225, carbGrams: 338, fatGrams: 83,
                 days: muscleGainMealDays())
    }

    // MARK: - Standard Meal Days (7 different days)
    private func standardMealDays() -> [MealDay] {
        let days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        let breakfasts = [
            Meal(type: .breakfast, name: "Oats & Egg Whites", description: "High-protein power breakfast", calories: 420, proteinGrams: 35, carbGrams: 55, fatGrams: 8, ingredients: ["80g rolled oats","4 egg whites","1 tbsp honey","1 banana","250ml almond milk"], prepInstructions: ["Cook oats in almond milk for 5 mins","Scramble egg whites separately","Top oats with honey and banana"], prepTimeMinutes: 10, imageAsset: "oats"),
            Meal(type: .breakfast, name: "Avocado Toast & Eggs", description: "Healthy fats and protein", calories: 440, proteinGrams: 22, carbGrams: 38, fatGrams: 22, ingredients: ["2 slices whole grain bread","1 avocado","2 poached eggs","Chili flakes","Lemon juice"], prepInstructions: ["Toast bread","Mash avocado with lemon","Poach eggs 3 mins","Assemble and season"], prepTimeMinutes: 12, imageAsset: "avocado_toast"),
            Meal(type: .breakfast, name: "Greek Yogurt Parfait", description: "Probiotic-rich layered breakfast", calories: 380, proteinGrams: 28, carbGrams: 48, fatGrams: 8, ingredients: ["200g Greek yogurt","100g mixed berries","40g granola","1 tbsp honey","Chia seeds"], prepInstructions: ["Layer yogurt in glass","Add berries","Top with granola and honey"], prepTimeMinutes: 5, imageAsset: "yogurt_parfait"),
            Meal(type: .breakfast, name: "Protein Pancakes", description: "Fluffy high-protein pancakes", calories: 460, proteinGrams: 38, carbGrams: 42, fatGrams: 12, ingredients: ["2 scoops protein powder","2 eggs","1 banana","100ml oat milk","Blueberries"], prepInstructions: ["Blend all ingredients","Cook on medium heat 2 mins each side","Top with blueberries"], prepTimeMinutes: 15, imageAsset: "pancakes"),
            Meal(type: .breakfast, name: "Spinach Omelette", description: "Iron-rich veggie omelette", calories: 350, proteinGrams: 30, carbGrams: 8, fatGrams: 22, ingredients: ["3 whole eggs","Handful spinach","50g feta cheese","Cherry tomatoes","Olive oil"], prepInstructions: ["Whisk eggs","Sauté spinach","Pour eggs and add fillings","Fold and serve"], prepTimeMinutes: 10, imageAsset: "omelette"),
            Meal(type: .breakfast, name: "Overnight Oats", description: "Prep ahead nutritious breakfast", calories: 410, proteinGrams: 18, carbGrams: 58, fatGrams: 10, ingredients: ["80g oats","250ml oat milk","1 tbsp chia seeds","1 tbsp peanut butter","Sliced banana"], prepInstructions: ["Mix oats, milk, chia seeds","Add peanut butter","Refrigerate overnight","Top with banana before eating"], prepTimeMinutes: 5, imageAsset: "overnight_oats"),
            Meal(type: .breakfast, name: "Smoothie Bowl", description: "Vibrant antioxidant breakfast", calories: 390, proteinGrams: 20, carbGrams: 55, fatGrams: 9, ingredients: ["1 scoop protein powder","1 frozen banana","100g frozen berries","Coconut milk","Toppings: granola, seeds"], prepInstructions: ["Blend protein, banana, berries with coconut milk","Pour into bowl","Add toppings"], prepTimeMinutes: 8, imageAsset: "smoothie_bowl"),
        ]
        let lunches = [
            Meal(type: .lunch, name: "Chicken & Rice Bowl", description: "Classic muscle-building lunch", calories: 620, proteinGrams: 55, carbGrams: 75, fatGrams: 12, ingredients: ["180g chicken breast","150g cooked brown rice","1 cup broccoli","1 tbsp olive oil","Garlic, herbs"], prepInstructions: ["Season and grill chicken","Steam broccoli","Serve over rice"], prepTimeMinutes: 20, imageAsset: "chicken_rice"),
            Meal(type: .lunch, name: "Tuna Salad Wrap", description: "Light and protein-packed", calories: 480, proteinGrams: 42, carbGrams: 38, fatGrams: 14, ingredients: ["2 cans tuna","2 whole wheat wraps","Mixed salad leaves","Greek yogurt","Cucumber"], prepInstructions: ["Mix tuna with yogurt","Add salad to wrap","Roll and serve"], prepTimeMinutes: 8, imageAsset: "tuna_wrap"),
            Meal(type: .lunch, name: "Quinoa Power Bowl", description: "Complete amino acid lunch", calories: 540, proteinGrams: 28, carbGrams: 68, fatGrams: 16, ingredients: ["150g cooked quinoa","Roasted chickpeas","Avocado","Cherry tomatoes","Tahini dressing"], prepInstructions: ["Cook quinoa","Roast chickpeas 20 mins","Assemble bowl with dressing"], prepTimeMinutes: 25, imageAsset: "quinoa_bowl"),
            Meal(type: .lunch, name: "Turkey & Sweet Potato", description: "Lean protein with complex carbs", calories: 580, proteinGrams: 48, carbGrams: 55, fatGrams: 13, ingredients: ["200g turkey mince","1 large sweet potato","Green beans","Paprika","Olive oil"], prepInstructions: ["Roast sweet potato 25 mins","Cook turkey with spices","Steam green beans"], prepTimeMinutes: 30, imageAsset: "turkey_potato"),
            Meal(type: .lunch, name: "Salmon Sushi Bowl", description: "Japanese-inspired power bowl", calories: 560, proteinGrams: 44, carbGrams: 58, fatGrams: 16, ingredients: ["150g salmon","150g sushi rice","Edamame","Cucumber","Soy sauce, sesame"], prepInstructions: ["Cook sushi rice","Dice salmon","Assemble bowl with toppings"], prepTimeMinutes: 15, imageAsset: "sushi_bowl"),
            Meal(type: .lunch, name: "Beef Stir Fry", description: "High-protein Asian-style lunch", calories: 600, proteinGrams: 50, carbGrams: 52, fatGrams: 18, ingredients: ["200g lean beef strips","Noodles","Mixed vegetables","Soy sauce","Ginger, garlic"], prepInstructions: ["Cook noodles","Stir fry beef 3 mins","Add veg and sauce"], prepTimeMinutes: 15, imageAsset: "stir_fry"),
            Meal(type: .lunch, name: "Chicken Caesar Salad", description: "Classic protein-rich salad", calories: 490, proteinGrams: 46, carbGrams: 22, fatGrams: 24, ingredients: ["180g grilled chicken","Romaine lettuce","Parmesan","Croutons","Caesar dressing"], prepInstructions: ["Grill chicken","Toss lettuce with dressing","Add chicken and toppings"], prepTimeMinutes: 15, imageAsset: "caesar_salad"),
        ]
        let dinners = [
            Meal(type: .dinner, name: "Salmon & Sweet Potato", description: "Omega-3 rich recovery dinner", calories: 580, proteinGrams: 48, carbGrams: 52, fatGrams: 18, ingredients: ["200g salmon fillet","200g sweet potato","Mixed greens","Lemon","Dill"], prepInstructions: ["Roast sweet potato 25 mins","Pan-sear salmon 4 mins each side","Serve with salad"], prepTimeMinutes: 30, imageAsset: "salmon"),
            Meal(type: .dinner, name: "Grilled Chicken Thighs", description: "Juicy flavourful dinner", calories: 520, proteinGrams: 46, carbGrams: 28, fatGrams: 22, ingredients: ["4 chicken thighs","Roasted vegetables","Garlic","Rosemary","Olive oil"], prepInstructions: ["Marinate chicken 30 mins","Grill 6 mins each side","Serve with roasted veg"], prepTimeMinutes: 40, imageAsset: "chicken_thighs"),
            Meal(type: .dinner, name: "Beef & Vegetable Stew", description: "Hearty protein-rich stew", calories: 560, proteinGrams: 44, carbGrams: 42, fatGrams: 18, ingredients: ["250g beef chunks","Carrots, potatoes","Onion","Beef stock","Herbs"], prepInstructions: ["Brown beef","Add veg and stock","Simmer 45 mins"], prepTimeMinutes: 55, imageAsset: "beef_stew"),
            Meal(type: .dinner, name: "Baked Cod & Asparagus", description: "Light white fish dinner", calories: 420, proteinGrams: 50, carbGrams: 18, fatGrams: 14, ingredients: ["200g cod fillet","Asparagus bundle","Lemon","Olive oil","Capers"], prepInstructions: ["Bake cod at 200°C 15 mins","Roast asparagus 10 mins","Serve with lemon"], prepTimeMinutes: 20, imageAsset: "cod_asparagus"),
            Meal(type: .dinner, name: "Lamb Kofta & Rice", description: "Middle Eastern protein bowl", calories: 620, proteinGrams: 46, carbGrams: 58, fatGrams: 22, ingredients: ["250g lamb mince","Basmati rice","Yogurt sauce","Cucumber","Mint"], prepInstructions: ["Shape and grill kofta 10 mins","Cook rice","Serve with yogurt sauce"], prepTimeMinutes: 25, imageAsset: "lamb_kofta"),
            Meal(type: .dinner, name: "Shrimp Pasta", description: "Light and satisfying seafood pasta", calories: 540, proteinGrams: 42, carbGrams: 62, fatGrams: 14, ingredients: ["200g shrimp","180g linguine","Cherry tomatoes","Garlic","White wine sauce"], prepInstructions: ["Cook pasta","Sauté shrimp and tomatoes","Toss with pasta and sauce"], prepTimeMinutes: 20, imageAsset: "shrimp_pasta"),
            Meal(type: .dinner, name: "Pork Tenderloin & Veg", description: "Lean pork with seasonal vegetables", calories: 500, proteinGrams: 48, carbGrams: 32, fatGrams: 16, ingredients: ["220g pork tenderloin","Green beans","Mashed potato","Mustard sauce","Thyme"], prepInstructions: ["Roast pork 20 mins at 200°C","Prepare mash","Steam green beans"], prepTimeMinutes: 30, imageAsset: "pork_tenderloin"),
        ]
        let snacks = [
            Meal(type: .morningSnack, name: "Greek Yogurt & Berries", description: "Probiotic snack", calories: 180, proteinGrams: 15, carbGrams: 22, fatGrams: 3, ingredients: ["200g Greek yogurt","100g mixed berries","1 tsp honey"], prepInstructions: ["Layer yogurt and berries","Drizzle honey"], prepTimeMinutes: 2, imageAsset: "yogurt"),
            Meal(type: .morningSnack, name: "Apple & Almond Butter", description: "Natural energy snack", calories: 210, proteinGrams: 6, carbGrams: 28, fatGrams: 10, ingredients: ["1 large apple","2 tbsp almond butter","Cinnamon"], prepInstructions: ["Slice apple","Dip in almond butter"], prepTimeMinutes: 2, imageAsset: "apple_almond"),
            Meal(type: .morningSnack, name: "Boiled Eggs & Nuts", description: "Portable protein snack", calories: 220, proteinGrams: 14, carbGrams: 4, fatGrams: 16, ingredients: ["2 boiled eggs","30g mixed nuts","Salt, pepper"], prepInstructions: ["Boil eggs 8 mins","Season and serve with nuts"], prepTimeMinutes: 10, imageAsset: "eggs_nuts"),
            Meal(type: .morningSnack, name: "Protein Bar", description: "Quick on-the-go fuel", calories: 200, proteinGrams: 20, carbGrams: 22, fatGrams: 7, ingredients: ["1 protein bar (any brand)","Optional: piece of fruit"], prepInstructions: ["Ready to eat"], prepTimeMinutes: 0, imageAsset: "protein_bar"),
            Meal(type: .morningSnack, name: "Cottage Cheese & Pineapple", description: "High-protein fruity snack", calories: 190, proteinGrams: 18, carbGrams: 20, fatGrams: 4, ingredients: ["150g cottage cheese","100g pineapple chunks","Mint leaves"], prepInstructions: ["Combine and serve"], prepTimeMinutes: 2, imageAsset: "cottage_cheese"),
            Meal(type: .morningSnack, name: "Hummus & Veggie Sticks", description: "Fibre and protein snack", calories: 175, proteinGrams: 8, carbGrams: 18, fatGrams: 8, ingredients: ["80g hummus","Carrot sticks","Celery","Cucumber","Capsicum"], prepInstructions: ["Chop vegetables","Serve with hummus"], prepTimeMinutes: 5, imageAsset: "hummus_veg"),
            Meal(type: .morningSnack, name: "Rice Cakes & Peanut Butter", description: "Light carb and protein combo", calories: 195, proteinGrams: 7, carbGrams: 24, fatGrams: 8, ingredients: ["3 rice cakes","2 tbsp peanut butter","Sliced banana"], prepInstructions: ["Spread peanut butter","Top with banana"], prepTimeMinutes: 2, imageAsset: "rice_cakes"),
        ]
        return days.enumerated().map { i, day in
            MealDay(dayName: day, meals: [breakfasts[i], snacks[i], lunches[i], dinners[i]])
        }
    }

    // MARK: - Keto Meal Days (7 different days)
    private func ketoMealDays() -> [MealDay] {
        let days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        let breakfasts = [
            Meal(type: .breakfast, name: "Avocado Egg Bowl", description: "Keto-perfect breakfast", calories: 480, proteinGrams: 28, carbGrams: 8, fatGrams: 40, ingredients: ["2 whole eggs","1 avocado","4 bacon strips","Cherry tomatoes","Salt, pepper"], prepInstructions: ["Fry eggs and bacon","Halve avocado","Serve together"], prepTimeMinutes: 12, imageAsset: "avocado_egg"),
            Meal(type: .breakfast, name: "Smoked Salmon & Cream Cheese", description: "Luxurious keto breakfast", calories: 420, proteinGrams: 30, carbGrams: 4, fatGrams: 34, ingredients: ["150g smoked salmon","60g cream cheese","Cucumber","Capers","Dill"], prepInstructions: ["Arrange salmon","Spread cream cheese","Top with capers"], prepTimeMinutes: 5, imageAsset: "smoked_salmon"),
            Meal(type: .breakfast, name: "Keto Omelette", description: "Cheesy low-carb omelette", calories: 460, proteinGrams: 32, carbGrams: 5, fatGrams: 36, ingredients: ["3 eggs","50g cheddar","Spinach","Mushrooms","Butter"], prepInstructions: ["Whisk eggs","Cook in butter","Add fillings and fold"], prepTimeMinutes: 10, imageAsset: "keto_omelette"),
            Meal(type: .breakfast, name: "Chia Seed Pudding", description: "Keto-friendly overnight pudding", calories: 380, proteinGrams: 14, carbGrams: 10, fatGrams: 32, ingredients: ["4 tbsp chia seeds","250ml coconut milk","Stevia","Vanilla extract","Berries"], prepInstructions: ["Mix chia and coconut milk","Add stevia","Refrigerate overnight"], prepTimeMinutes: 5, imageAsset: "chia_pudding"),
            Meal(type: .breakfast, name: "Bacon & Egg Cups", description: "Easy keto breakfast cups", calories: 440, proteinGrams: 26, carbGrams: 2, fatGrams: 38, ingredients: ["6 bacon strips","4 eggs","Cheese","Chives","Pepper"], prepInstructions: ["Line muffin tin with bacon","Crack egg inside","Bake 15 mins at 180°C"], prepTimeMinutes: 20, imageAsset: "egg_cups"),
            Meal(type: .breakfast, name: "Almond Flour Pancakes", description: "Fluffy keto pancakes", calories: 420, proteinGrams: 18, carbGrams: 8, fatGrams: 36, ingredients: ["100g almond flour","2 eggs","60ml almond milk","Butter","Sugar-free syrup"], prepInstructions: ["Mix all ingredients","Cook 2 mins each side","Serve with syrup"], prepTimeMinutes: 15, imageAsset: "almond_pancakes"),
            Meal(type: .breakfast, name: "Greek Yogurt & Nuts", description: "Simple high-fat breakfast", calories: 390, proteinGrams: 22, carbGrams: 10, fatGrams: 30, ingredients: ["150g full-fat Greek yogurt","40g mixed nuts","Seeds","Cinnamon","Coconut flakes"], prepInstructions: ["Combine yogurt and nuts","Sprinkle cinnamon"], prepTimeMinutes: 3, imageAsset: "yogurt_nuts"),
        ]
        let lunches = [
            Meal(type: .lunch, name: "Zucchini Noodle Bolognese", description: "Low-carb pasta alternative", calories: 520, proteinGrams: 42, carbGrams: 14, fatGrams: 32, ingredients: ["200g ground beef","2 zucchinis spiralized","Tomato sauce (no sugar)","Parmesan","Olive oil"], prepInstructions: ["Brown beef","Sauté zucchini 2 mins","Combine with sauce"], prepTimeMinutes: 20, imageAsset: "bolognese"),
            Meal(type: .lunch, name: "Cobb Salad", description: "Classic American keto salad", calories: 560, proteinGrams: 44, carbGrams: 8, fatGrams: 40, ingredients: ["Grilled chicken","Bacon","Hard boiled eggs","Avocado","Blue cheese dressing"], prepInstructions: ["Arrange all ingredients on lettuce","Drizzle dressing"], prepTimeMinutes: 15, imageAsset: "cobb_salad"),
            Meal(type: .lunch, name: "Tuna Lettuce Wraps", description: "Fresh keto wraps", calories: 380, proteinGrams: 40, carbGrams: 6, fatGrams: 22, ingredients: ["2 cans tuna","Lettuce leaves","Mayo","Celery","Lemon"], prepInstructions: ["Mix tuna with mayo","Fill lettuce cups","Serve with lemon"], prepTimeMinutes: 8, imageAsset: "lettuce_wraps"),
            Meal(type: .lunch, name: "Chicken Avocado Bowl", description: "Creamy keto power bowl", calories: 540, proteinGrams: 46, carbGrams: 10, fatGrams: 36, ingredients: ["180g chicken","1 avocado","Cauliflower rice","Lime","Coriander"], prepInstructions: ["Cook cauliflower rice","Grill chicken","Assemble bowl"], prepTimeMinutes: 20, imageAsset: "chicken_avocado"),
            Meal(type: .lunch, name: "Egg Salad", description: "Simple high-fat lunch", calories: 420, proteinGrams: 22, carbGrams: 4, fatGrams: 36, ingredients: ["4 boiled eggs","3 tbsp mayo","Mustard","Celery","Paprika"], prepInstructions: ["Chop eggs","Mix with mayo and mustard","Season and serve"], prepTimeMinutes: 10, imageAsset: "egg_salad"),
            Meal(type: .lunch, name: "Steak & Asparagus", description: "Keto-perfect protein lunch", calories: 580, proteinGrams: 52, carbGrams: 6, fatGrams: 38, ingredients: ["200g sirloin steak","Asparagus","Butter","Garlic","Lemon"], prepInstructions: ["Sear steak 4 mins each side","Roast asparagus 10 mins","Serve with garlic butter"], prepTimeMinutes: 20, imageAsset: "steak_asparagus"),
            Meal(type: .lunch, name: "Salmon Salad", description: "Omega-rich keto salad", calories: 500, proteinGrams: 42, carbGrams: 8, fatGrams: 34, ingredients: ["180g salmon","Spinach","Avocado","Cucumber","Olive oil dressing"], prepInstructions: ["Sear salmon","Toss salad","Serve together"], prepTimeMinutes: 15, imageAsset: "salmon_salad"),
        ]
        let dinners = [
            Meal(type: .dinner, name: "Butter Chicken Thighs", description: "Juicy keto dinner", calories: 580, proteinGrams: 45, carbGrams: 6, fatGrams: 44, ingredients: ["4 chicken thighs","3 tbsp butter","Heavy cream","Garlic","Paprika"], prepInstructions: ["Sear thighs in butter","Add cream and garlic","Simmer 10 mins"], prepTimeMinutes: 25, imageAsset: "chicken_thigh"),
            Meal(type: .dinner, name: "Pork Belly & Coleslaw", description: "Rich keto comfort dinner", calories: 620, proteinGrams: 38, carbGrams: 8, fatGrams: 50, ingredients: ["250g pork belly","Cabbage coleslaw","Apple cider vinegar","Fennel seeds","Salt"], prepInstructions: ["Roast pork belly 30 mins","Make coleslaw","Serve together"], prepTimeMinutes: 35, imageAsset: "pork_belly"),
            Meal(type: .dinner, name: "Garlic Butter Shrimp", description: "Quick keto seafood dinner", calories: 420, proteinGrams: 46, carbGrams: 4, fatGrams: 24, ingredients: ["300g shrimp","4 tbsp butter","Garlic","Parsley","Lemon"], prepInstructions: ["Melt butter with garlic","Cook shrimp 2 mins each side","Add parsley and lemon"], prepTimeMinutes: 12, imageAsset: "garlic_shrimp"),
            Meal(type: .dinner, name: "Ribeye Steak & Spinach", description: "Premium keto dinner", calories: 640, proteinGrams: 52, carbGrams: 4, fatGrams: 46, ingredients: ["250g ribeye","Spinach","Compound butter","Garlic","Thyme"], prepInstructions: ["Season steak","Sear 4 mins each side","Rest 5 mins","Sauté spinach"], prepTimeMinutes: 20, imageAsset: "ribeye"),
            Meal(type: .dinner, name: "Lamb Chops & Cauliflower", description: "Elegant keto dinner", calories: 580, proteinGrams: 44, carbGrams: 8, fatGrams: 42, ingredients: ["3 lamb chops","Cauliflower mash","Rosemary","Garlic","Olive oil"], prepInstructions: ["Grill lamb 3 mins each side","Make cauliflower mash","Serve together"], prepTimeMinutes: 25, imageAsset: "lamb_chops"),
            Meal(type: .dinner, name: "Baked Salmon & Broccoli", description: "Easy weeknight keto", calories: 520, proteinGrams: 48, carbGrams: 10, fatGrams: 32, ingredients: ["200g salmon","Broccoli florets","Lemon butter sauce","Dill","Capers"], prepInstructions: ["Bake salmon 15 mins","Steam broccoli","Make lemon butter sauce"], prepTimeMinutes: 20, imageAsset: "salmon_broccoli"),
            Meal(type: .dinner, name: "Turkey Meatballs & Zoodles", description: "Light keto pasta night", calories: 480, proteinGrams: 44, carbGrams: 10, fatGrams: 28, ingredients: ["250g turkey mince","2 zucchinis spiralized","Tomato sauce","Parmesan","Italian herbs"], prepInstructions: ["Shape and bake meatballs 20 mins","Sauté zoodles","Serve with sauce"], prepTimeMinutes: 30, imageAsset: "turkey_meatballs"),
        ]
        return days.enumerated().map { i, day in
            MealDay(dayName: day, meals: [breakfasts[i], lunches[i], dinners[i]])
        }
    }

    // MARK: - Vegetarian Meal Days (7 different days)
    private func vegetarianMealDays() -> [MealDay] {
        let days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        let meals: [(Meal, Meal, Meal)] = [
            (Meal(type: .breakfast, name: "Tofu Scramble", description: "Protein-packed veg breakfast", calories: 380, proteinGrams: 28, carbGrams: 32, fatGrams: 14, ingredients: ["200g firm tofu","Spinach","Bell pepper","Turmeric","Nutritional yeast"], prepInstructions: ["Crumble tofu","Add veg and spices","Cook 8 mins"], prepTimeMinutes: 10, imageAsset: "tofu_scramble"),
             Meal(type: .lunch, name: "Lentil Buddha Bowl", description: "Complete protein bowl", calories: 560, proteinGrams: 32, carbGrams: 78, fatGrams: 12, ingredients: ["150g cooked lentils","Quinoa","Roasted chickpeas","Tahini dressing","Kale"], prepInstructions: ["Cook lentils and quinoa","Roast chickpeas 20 mins","Assemble"], prepTimeMinutes: 25, imageAsset: "buddha_bowl"),
             Meal(type: .dinner, name: "Paneer Tikka Masala", description: "Creamy Indian classic", calories: 520, proteinGrams: 30, carbGrams: 42, fatGrams: 22, ingredients: ["200g paneer","Tomato-cream sauce","Basmati rice","Spices","Cilantro"], prepInstructions: ["Grill paneer","Simmer in sauce","Serve over rice"], prepTimeMinutes: 30, imageAsset: "paneer")),
            (Meal(type: .breakfast, name: "Berry Smoothie Bowl", description: "Vibrant antioxidant breakfast", calories: 360, proteinGrams: 16, carbGrams: 55, fatGrams: 8, ingredients: ["Frozen berries","Banana","Plant protein","Almond milk","Granola toppings"], prepInstructions: ["Blend fruits with milk","Pour thick into bowl","Add toppings"], prepTimeMinutes: 8, imageAsset: "smoothie_bowl"),
             Meal(type: .lunch, name: "Chickpea Curry", description: "Hearty protein-rich curry", calories: 540, proteinGrams: 22, carbGrams: 72, fatGrams: 14, ingredients: ["400g chickpeas","Coconut milk","Tomatoes","Curry spices","Basmati rice"], prepInstructions: ["Sauté spices","Add chickpeas and coconut milk","Simmer 20 mins"], prepTimeMinutes: 25, imageAsset: "chickpea_curry"),
             Meal(type: .dinner, name: "Mushroom Risotto", description: "Creamy Italian comfort food", calories: 500, proteinGrams: 16, carbGrams: 68, fatGrams: 18, ingredients: ["300g mixed mushrooms","Arborio rice","Vegetable stock","Parmesan","White wine"], prepInstructions: ["Sauté mushrooms","Add rice and wine","Add stock gradually"], prepTimeMinutes: 35, imageAsset: "mushroom_risotto")),
            (Meal(type: .breakfast, name: "Overnight Oats", description: "Prep-ahead protein breakfast", calories: 400, proteinGrams: 18, carbGrams: 58, fatGrams: 10, ingredients: ["80g oats","Oat milk","Chia seeds","Peanut butter","Banana"], prepInstructions: ["Mix oats and milk","Add chia and PB","Refrigerate overnight"], prepTimeMinutes: 5, imageAsset: "overnight_oats"),
             Meal(type: .lunch, name: "Falafel Wrap", description: "Middle Eastern veggie wrap", calories: 520, proteinGrams: 18, carbGrams: 68, fatGrams: 18, ingredients: ["6 falafel balls","Whole wheat wrap","Hummus","Tomato","Tzatziki"], prepInstructions: ["Warm falafel","Spread hummus on wrap","Add fillings and roll"], prepTimeMinutes: 10, imageAsset: "falafel_wrap"),
             Meal(type: .dinner, name: "Veggie Stuffed Peppers", description: "Colourful baked peppers", calories: 460, proteinGrams: 18, carbGrams: 58, fatGrams: 14, ingredients: ["4 bell peppers","Quinoa","Black beans","Corn","Tomato sauce"], prepInstructions: ["Halve peppers","Mix quinoa filling","Stuff and bake 30 mins"], prepTimeMinutes: 40, imageAsset: "stuffed_peppers")),
            (Meal(type: .breakfast, name: "Avocado Toast", description: "Trendy nutritious breakfast", calories: 420, proteinGrams: 14, carbGrams: 42, fatGrams: 24, ingredients: ["2 slices sourdough","1 avocado","Poached eggs","Chili flakes","Microgreens"], prepInstructions: ["Toast bread","Mash avocado","Poach eggs","Assemble"], prepTimeMinutes: 12, imageAsset: "avocado_toast"),
             Meal(type: .lunch, name: "Caprese Pasta Salad", description: "Italian summer salad", calories: 500, proteinGrams: 20, carbGrams: 62, fatGrams: 18, ingredients: ["200g pasta","Fresh mozzarella","Cherry tomatoes","Basil","Balsamic glaze"], prepInstructions: ["Cook pasta","Combine with cheese and tomatoes","Drizzle balsamic"], prepTimeMinutes: 15, imageAsset: "caprese_pasta"),
             Meal(type: .dinner, name: "Eggplant Parmigiana", description: "Classic Italian baked dish", calories: 480, proteinGrams: 22, carbGrams: 46, fatGrams: 22, ingredients: ["2 eggplants","Tomato sauce","Mozzarella","Parmesan","Basil"], prepInstructions: ["Slice and salt eggplant","Layer with sauce and cheese","Bake 30 mins"], prepTimeMinutes: 45, imageAsset: "eggplant_parm")),
            (Meal(type: .breakfast, name: "Protein Waffles", description: "High-protein crispy waffles", calories: 440, proteinGrams: 30, carbGrams: 45, fatGrams: 14, ingredients: ["1 scoop vanilla protein","80g oat flour","2 eggs","Almond milk","Mixed berries"], prepInstructions: ["Mix batter","Cook in waffle iron 4 mins","Top with berries"], prepTimeMinutes: 15, imageAsset: "protein_waffles"),
             Meal(type: .lunch, name: "Black Bean Tacos", description: "Mexican plant-based tacos", calories: 520, proteinGrams: 22, carbGrams: 70, fatGrams: 14, ingredients: ["400g black beans","Corn tortillas","Avocado","Salsa","Lime"], prepInstructions: ["Heat beans with spices","Warm tortillas","Assemble tacos"], prepTimeMinutes: 15, imageAsset: "bean_tacos"),
             Meal(type: .dinner, name: "Thai Green Curry", description: "Aromatic coconut curry", calories: 520, proteinGrams: 18, carbGrams: 62, fatGrams: 22, ingredients: ["Green curry paste","Coconut milk","Tofu","Thai vegetables","Jasmine rice"], prepInstructions: ["Fry curry paste","Add coconut milk","Add tofu and veg","Serve over rice"], prepTimeMinutes: 25, imageAsset: "green_curry")),
            (Meal(type: .breakfast, name: "Mango Chia Pudding", description: "Tropical breakfast pudding", calories: 360, proteinGrams: 12, carbGrams: 52, fatGrams: 12, ingredients: ["4 tbsp chia seeds","Coconut milk","Mango","Passion fruit","Mint"], prepInstructions: ["Mix chia and milk","Refrigerate overnight","Top with mango"], prepTimeMinutes: 5, imageAsset: "chia_pudding"),
             Meal(type: .lunch, name: "Spinach & Ricotta Pasta", description: "Italian vegetarian pasta", calories: 540, proteinGrams: 24, carbGrams: 68, fatGrams: 16, ingredients: ["200g pasta","200g ricotta","Spinach","Garlic","Lemon zest"], prepInstructions: ["Cook pasta","Mix ricotta with spinach","Toss with pasta"], prepTimeMinutes: 15, imageAsset: "ricotta_pasta"),
             Meal(type: .dinner, name: "Vegetable Tagine", description: "Moroccan slow-cooked stew", calories: 460, proteinGrams: 14, carbGrams: 70, fatGrams: 12, ingredients: ["Mixed vegetables","Chickpeas","Couscous","Ras el hanout","Preserved lemon"], prepInstructions: ["Brown veg","Add spices and water","Simmer 30 mins","Serve over couscous"], prepTimeMinutes: 40, imageAsset: "tagine")),
            (Meal(type: .breakfast, name: "Acai Bowl", description: "Antioxidant superfood bowl", calories: 400, proteinGrams: 14, carbGrams: 60, fatGrams: 12, ingredients: ["Acai packets","Banana","Granola","Coconut flakes","Mixed berries"], prepInstructions: ["Blend acai with banana","Pour into bowl","Add toppings"], prepTimeMinutes: 8, imageAsset: "acai_bowl"),
             Meal(type: .lunch, name: "Halloumi & Quinoa Salad", description: "Mediterranean protein salad", calories: 560, proteinGrams: 28, carbGrams: 48, fatGrams: 26, ingredients: ["200g halloumi","150g quinoa","Roasted peppers","Olives","Lemon dressing"], prepInstructions: ["Grill halloumi 2 mins each side","Cook quinoa","Assemble salad"], prepTimeMinutes: 20, imageAsset: "halloumi_salad"),
             Meal(type: .dinner, name: "Sweet Potato Dal", description: "Indian lentil comfort dish", calories: 480, proteinGrams: 20, carbGrams: 72, fatGrams: 10, ingredients: ["200g red lentils","1 sweet potato","Coconut milk","Curry leaves","Basmati rice"], prepInstructions: ["Cook lentils and sweet potato","Add coconut milk","Simmer 20 mins","Serve over rice"], prepTimeMinutes: 30, imageAsset: "sweet_potato_dal")),
        ]
        return days.enumerated().map { i, day in
            MealDay(dayName: day, meals: [meals[i].0, meals[i].1, meals[i].2])
        }
    }

    // MARK: - Muscle Gain Meal Days (7 different days)
    private func muscleGainMealDays() -> [MealDay] {
        let days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        let breakfasts = [
            Meal(type: .breakfast, name: "Mass Builder Omelette", description: "Anabolic breakfast", calories: 700, proteinGrams: 58, carbGrams: 60, fatGrams: 24, ingredients: ["4 whole eggs + 2 whites","3 slices whole grain toast","100g cottage cheese","1 banana","250ml whole milk"], prepInstructions: ["Make full omelette","Serve with toast","Drink milk on side"], prepTimeMinutes: 15, imageAsset: "omelette"),
            Meal(type: .breakfast, name: "Beef & Egg Hash", description: "High-calorie muscle breakfast", calories: 680, proteinGrams: 55, carbGrams: 50, fatGrams: 28, ingredients: ["150g lean beef mince","3 eggs","Diced potatoes","Peppers","Olive oil"], prepInstructions: ["Fry potatoes","Add beef and veg","Make wells for eggs","Cook eggs in pan"], prepTimeMinutes: 20, imageAsset: "beef_hash"),
            Meal(type: .breakfast, name: "Salmon Bagel", description: "Omega-3 loaded breakfast", calories: 650, proteinGrams: 48, carbGrams: 58, fatGrams: 22, ingredients: ["200g smoked salmon","2 bagels","100g cream cheese","Capers","Red onion"], prepInstructions: ["Toast bagels","Spread cream cheese","Top with salmon and capers"], prepTimeMinutes: 8, imageAsset: "salmon_bagel"),
            Meal(type: .breakfast, name: "Muscle Smoothie", description: "Liquid muscle fuel", calories: 720, proteinGrams: 60, carbGrams: 72, fatGrams: 18, ingredients: ["2 scoops protein powder","2 bananas","3 tbsp peanut butter","500ml whole milk","Oats"], prepInstructions: ["Blend all ingredients until smooth","Drink immediately"], prepTimeMinutes: 5, imageAsset: "muscle_smoothie"),
            Meal(type: .breakfast, name: "French Toast & Turkey", description: "Sweet and savoury power breakfast", calories: 690, proteinGrams: 52, carbGrams: 65, fatGrams: 22, ingredients: ["3 slices brioche","3 eggs","200g turkey rashers","Maple syrup","Berries"], prepInstructions: ["Dip brioche in egg mix","Pan fry 2 mins each side","Serve with turkey and syrup"], prepTimeMinutes: 15, imageAsset: "french_toast"),
            Meal(type: .breakfast, name: "Steak & Eggs", description: "Classic mass breakfast", calories: 740, proteinGrams: 65, carbGrams: 42, fatGrams: 30, ingredients: ["200g sirloin steak","3 fried eggs","Sourdough toast","Grilled tomatoes","Butter"], prepInstructions: ["Sear steak 3 mins each side","Fry eggs in butter","Toast bread","Serve with tomatoes"], prepTimeMinutes: 15, imageAsset: "steak_eggs"),
            Meal(type: .breakfast, name: "Peanut Butter Waffles", description: "High-calorie weekend breakfast", calories: 680, proteinGrams: 44, carbGrams: 75, fatGrams: 24, ingredients: ["Whole wheat waffle batter","4 tbsp peanut butter","Banana","Honey","Protein powder"], prepInstructions: ["Mix protein into batter","Cook waffles","Top generously with PB and banana"], prepTimeMinutes: 15, imageAsset: "pb_waffles"),
        ]
        let lunches = [
            Meal(type: .lunch, name: "Tuna Pasta Power", description: "Carb + protein powerhouse", calories: 780, proteinGrams: 68, carbGrams: 92, fatGrams: 14, ingredients: ["2 cans tuna","200g cooked pasta","Low-fat mayo","Sweetcorn","Olive oil"], prepInstructions: ["Cook pasta","Mix tuna, corn, mayo","Combine with olive oil"], prepTimeMinutes: 15, imageAsset: "tuna_pasta"),
            Meal(type: .lunch, name: "Double Chicken Wrap", description: "Maximum protein wrap", calories: 820, proteinGrams: 72, carbGrams: 68, fatGrams: 24, ingredients: ["360g chicken breast","2 large wraps","Avocado","Greek yogurt sauce","Spinach"], prepInstructions: ["Grill and slice chicken","Spread yogurt sauce","Fill wraps generously"], prepTimeMinutes: 20, imageAsset: "chicken_wrap"),
            Meal(type: .lunch, name: "Salmon & Rice Power Bowl", description: "Complete muscle meal", calories: 760, proteinGrams: 62, carbGrams: 78, fatGrams: 22, ingredients: ["200g salmon","200g rice","Edamame","Avocado","Teriyaki sauce"], prepInstructions: ["Cook rice","Sear salmon","Assemble bowl with toppings"], prepTimeMinutes: 20, imageAsset: "salmon_bowl"),
            Meal(type: .lunch, name: "Beef Burrito Bowl", description: "Mexican muscle bowl", calories: 840, proteinGrams: 65, carbGrams: 85, fatGrams: 26, ingredients: ["250g lean beef mince","Brown rice","Black beans","Cheese","Salsa, guac"], prepInstructions: ["Cook beef with Mexican spices","Cook rice","Layer bowl with all toppings"], prepTimeMinutes: 25, imageAsset: "burrito_bowl"),
            Meal(type: .lunch, name: "Chicken & Lentil Soup", description: "Hearty protein soup", calories: 720, proteinGrams: 62, carbGrams: 72, fatGrams: 16, ingredients: ["300g chicken","200g lentils","Vegetables","Chicken stock","Crusty bread"], prepInstructions: ["Cook chicken in stock","Add lentils and veg","Simmer 25 mins","Serve with bread"], prepTimeMinutes: 35, imageAsset: "chicken_soup"),
            Meal(type: .lunch, name: "Prawn Fried Rice", description: "Protein-packed Asian bowl", calories: 760, proteinGrams: 56, carbGrams: 88, fatGrams: 18, ingredients: ["250g prawns","300g cooked rice","3 eggs","Mixed veg","Soy sauce"], prepInstructions: ["Scramble eggs","Add rice and prawns","Stir fry with soy sauce"], prepTimeMinutes: 15, imageAsset: "fried_rice"),
            Meal(type: .lunch, name: "Turkey & Quinoa Bowl", description: "Lean protein mega bowl", calories: 780, proteinGrams: 70, carbGrams: 75, fatGrams: 18, ingredients: ["280g turkey breast","200g quinoa","Roasted sweet potato","Spinach","Tahini"], prepInstructions: ["Cook quinoa","Roast turkey and potato","Assemble bowl"], prepTimeMinutes: 30, imageAsset: "turkey_quinoa"),
        ]
        let dinners = [
            Meal(type: .dinner, name: "Beef & Quinoa Bowl", description: "Complete amino acid profile", calories: 820, proteinGrams: 72, carbGrams: 78, fatGrams: 26, ingredients: ["250g lean ground beef","200g cooked quinoa","Spinach","Sweet potato","Salsa"], prepInstructions: ["Brown beef","Cook quinoa","Roast sweet potato","Assemble bowl"], prepTimeMinutes: 30, imageAsset: "beef_bowl"),
            Meal(type: .dinner, name: "Chicken Pasta Bake", description: "Comforting mass builder", calories: 860, proteinGrams: 68, carbGrams: 88, fatGrams: 24, ingredients: ["300g chicken","250g penne","Tomato sauce","Mozzarella","Basil"], prepInstructions: ["Cook pasta","Layer with chicken and sauce","Top with cheese","Bake 20 mins"], prepTimeMinutes: 35, imageAsset: "pasta_bake"),
            Meal(type: .dinner, name: "Steak & Mashed Potato", description: "Classic mass dinner", calories: 880, proteinGrams: 74, carbGrams: 72, fatGrams: 32, ingredients: ["280g sirloin","400g mashed potato","Green beans","Gravy","Butter"], prepInstructions: ["Sear steak","Make creamy mash","Steam green beans","Make gravy"], prepTimeMinutes: 30, imageAsset: "steak_mash"),
            Meal(type: .dinner, name: "Salmon Pasta", description: "Omega-3 carb dinner", calories: 800, proteinGrams: 62, carbGrams: 82, fatGrams: 24, ingredients: ["220g salmon","200g pasta","Cream sauce","Capers","Dill"], prepInstructions: ["Cook pasta","Pan-fry salmon","Make cream sauce","Toss together"], prepTimeMinutes: 25, imageAsset: "salmon_pasta"),
            Meal(type: .dinner, name: "Pork & Sweet Potato Curry", description: "Calorie-dense curry", calories: 840, proteinGrams: 66, carbGrams: 80, fatGrams: 28, ingredients: ["280g pork loin","Sweet potato","Coconut milk","Curry paste","Basmati rice"], prepInstructions: ["Cook pork","Add curry paste and coconut milk","Add sweet potato","Serve over rice"], prepTimeMinutes: 30, imageAsset: "pork_curry"),
            Meal(type: .dinner, name: "Chicken Burgers", description: "High-protein burger night", calories: 820, proteinGrams: 68, carbGrams: 75, fatGrams: 26, ingredients: ["2 large chicken burgers","Brioche buns","Avocado","Sweet potato fries","Aioli"], prepInstructions: ["Grill chicken burgers","Bake sweet potato fries","Assemble burgers"], prepTimeMinutes: 25, imageAsset: "chicken_burger"),
            Meal(type: .dinner, name: "Lamb & Couscous", description: "Middle Eastern mass dinner", calories: 860, proteinGrams: 70, carbGrams: 80, fatGrams: 28, ingredients: ["280g lamb leg","Couscous","Roasted veg","Harissa","Greek yogurt"], prepInstructions: ["Roast lamb 25 mins","Cook couscous","Serve with yogurt and harissa"], prepTimeMinutes: 35, imageAsset: "lamb_couscous"),
        ]
        return days.enumerated().map { i, day in
            MealDay(dayName: day, meals: [breakfasts[i], lunches[i], dinners[i]])
        }
    }

    // MARK: - Workout Week Builders
    private func buildMuscleWeeks() -> [WorkoutWeek] {
        (1...8).map { week in
            WorkoutWeek(weekNumber: week, days: [
                WorkoutDay(dayNumber: 1, dayName: "Monday", focus: "Upper Body Push", isRestDay: false, exercises: [exercise("Barbell Bench Press"), exercise("Overhead Press"), exercise("Dumbbell Flyes"), exercise("Push-Up")], estimatedMinutes: 55),
                WorkoutDay(dayNumber: 2, dayName: "Tuesday", focus: "Lower Body", isRestDay: false, exercises: [exercise("Barbell Back Squat"), exercise("Romanian Deadlift"), exercise("Goblet Squat")], estimatedMinutes: 50),
                WorkoutDay(dayNumber: 3, dayName: "Wednesday", focus: "Rest & Recovery", isRestDay: true, exercises: [], estimatedMinutes: 0),
                WorkoutDay(dayNumber: 4, dayName: "Thursday", focus: "Upper Body Pull", isRestDay: false, exercises: [exercise("Pull-Up"), exercise("Barbell Row"), exercise("Russian Twist")], estimatedMinutes: 50),
                WorkoutDay(dayNumber: 5, dayName: "Friday", focus: "Lower Body + Core", isRestDay: false, exercises: [exercise("Barbell Back Squat"), exercise("Romanian Deadlift"), exercise("Plank")], estimatedMinutes: 55),
                WorkoutDay(dayNumber: 6, dayName: "Saturday", focus: "Active Recovery", isRestDay: true, exercises: [], estimatedMinutes: 30),
                WorkoutDay(dayNumber: 7, dayName: "Sunday", focus: "Full Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
            ])
        }
    }

    private func fatLossWeeks() -> [WorkoutWeek] {
        (1...6).map { week in
            WorkoutWeek(weekNumber: week, days: [
                WorkoutDay(dayNumber: 1, dayName: "Monday", focus: "Full Body Circuit", isRestDay: false, exercises: [exercise("Burpee"), exercise("Goblet Squat"), exercise("Push-Up"), exercise("Mountain Climbers"), exercise("Plank")], estimatedMinutes: 45),
                WorkoutDay(dayNumber: 2, dayName: "Tuesday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
                WorkoutDay(dayNumber: 3, dayName: "Wednesday", focus: "HIIT + Strength", isRestDay: false, exercises: [exercise("Mountain Climbers"), exercise("Barbell Back Squat"), exercise("Burpee"), exercise("Pull-Up")], estimatedMinutes: 40),
                WorkoutDay(dayNumber: 4, dayName: "Thursday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
                WorkoutDay(dayNumber: 5, dayName: "Friday", focus: "Full Body + Core", isRestDay: false, exercises: [exercise("Push-Up"), exercise("Romanian Deadlift"), exercise("Russian Twist"), exercise("Burpee")], estimatedMinutes: 45),
                WorkoutDay(dayNumber: 6, dayName: "Saturday", focus: "Light Cardio / Walk", isRestDay: true, exercises: [], estimatedMinutes: 30),
                WorkoutDay(dayNumber: 7, dayName: "Sunday", focus: "Full Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
            ])
        }
    }

    private func enduranceWeeks() -> [WorkoutWeek] {
        (1...10).map { week in
            WorkoutWeek(weekNumber: week, days: [
                WorkoutDay(dayNumber: 1, dayName: "Monday", focus: "Cardio + Core", isRestDay: false, exercises: [exercise("Mountain Climbers"), exercise("Plank"), exercise("Burpee")], estimatedMinutes: 60),
                WorkoutDay(dayNumber: 2, dayName: "Tuesday", focus: "Strength Endurance", isRestDay: false, exercises: [exercise("Push-Up"), exercise("Pull-Up"), exercise("Goblet Squat")], estimatedMinutes: 50),
                WorkoutDay(dayNumber: 3, dayName: "Wednesday", focus: "Active Recovery", isRestDay: true, exercises: [], estimatedMinutes: 30),
                WorkoutDay(dayNumber: 4, dayName: "Thursday", focus: "HIIT Intervals", isRestDay: false, exercises: [exercise("Burpee"), exercise("Mountain Climbers"), exercise("Russian Twist")], estimatedMinutes: 45),
                WorkoutDay(dayNumber: 5, dayName: "Friday", focus: "Long Cardio", isRestDay: false, exercises: [exercise("Mountain Climbers"), exercise("Plank")], estimatedMinutes: 70),
                WorkoutDay(dayNumber: 6, dayName: "Saturday", focus: "Full Body Circuit", isRestDay: false, exercises: [exercise("Pull-Up"), exercise("Barbell Back Squat"), exercise("Push-Up"), exercise("Plank")], estimatedMinutes: 55),
                WorkoutDay(dayNumber: 7, dayName: "Sunday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
            ])
        }
    }

    private func beginnerWeeks() -> [WorkoutWeek] {
        (1...8).map { week in
            WorkoutWeek(weekNumber: week, days: [
                WorkoutDay(dayNumber: 1, dayName: "Monday", focus: "Full Body A", isRestDay: false, exercises: [exercise("Push-Up"), exercise("Goblet Squat"), exercise("Plank")], estimatedMinutes: 35),
                WorkoutDay(dayNumber: 2, dayName: "Tuesday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
                WorkoutDay(dayNumber: 3, dayName: "Wednesday", focus: "Full Body B", isRestDay: false, exercises: [exercise("Mountain Climbers"), exercise("Romanian Deadlift"), exercise("Russian Twist")], estimatedMinutes: 35),
                WorkoutDay(dayNumber: 4, dayName: "Thursday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
                WorkoutDay(dayNumber: 5, dayName: "Friday", focus: "Full Body A", isRestDay: false, exercises: [exercise("Push-Up"), exercise("Goblet Squat"), exercise("Plank")], estimatedMinutes: 35),
                WorkoutDay(dayNumber: 6, dayName: "Saturday", focus: "Light Activity", isRestDay: true, exercises: [], estimatedMinutes: 20),
                WorkoutDay(dayNumber: 7, dayName: "Sunday", focus: "Rest", isRestDay: true, exercises: [], estimatedMinutes: 0),
            ])
        }
    }

    private func exercise(_ name: String) -> Exercise {
        allExercises.first(where: { $0.name == name }) ?? allExercises[0]
    }
}
