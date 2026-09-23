//
//  Untitled.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.





import SwiftUI

struct DietView: View {
    @EnvironmentObject var dietVM: DietViewModel
    @EnvironmentObject var lm: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingPlanPicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let plan = dietVM.currentMealPlan {
                        macrosSummaryCard(plan: plan)
                        daySelectorScroll(plan: plan)
                        if let day = dietVM.selectedDay {
                            VStack(spacing: 16) {
                                ForEach(day.meals) { meal in
                                    MealCard(meal: meal, isLogged: dietVM.isMealLogged(meal), lm: lm) {
                                        dietVM.toggleMealLogged(meal)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        Text(lm.isArabic ? "لم يتم اختيار خطة غذائية" : "No meal plan selected")
                            .foregroundColor(.secondary)
                    }
                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(lm.t(.diet))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingPlanPicker = true }) {
                        Image(systemName: "list.bullet.rectangle")
                    }
                }
            }
            .sheet(isPresented: $showingPlanPicker) {
                MealPlanPickerView(lm: lm).environmentObject(dietVM)
            }
        }
    }

    func macrosSummaryCard(plan: MealPlan) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text(plan.name).font(.headline)
                    Text(plan.dietaryPreference.localizedName(lm)).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(plan.dailyCalorieTarget)").font(.title2).bold()
                    Text(lm.t(.kcalDay)).font(.caption).foregroundColor(.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(lm.isArabic ? "اليوم: \(dietVM.todayCaloriesConsumed) سعرة" : "Today: \(dietVM.todayCaloriesConsumed) kcal")
                        .font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(dietVM.calorieProgress * 100))%").font(.caption).bold()
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6).fill(Color.green.opacity(0.2)).frame(height: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * dietVM.calorieProgress, height: 10)
                    }
                }.frame(height: 10)
            }
            HStack(spacing: 12) {
                MacroBar(label: lm.t(.protein), value: plan.proteinGrams, unit: "g", color: .red)
                MacroBar(label: lm.t(.carbs),   value: plan.carbGrams,    unit: "g", color: .orange)
                MacroBar(label: lm.t(.fats),    value: plan.fatGrams,     unit: "g", color: .yellow)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    func daySelectorScroll(plan: MealPlan) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(plan.days.enumerated()), id: \.element.id) { i, day in
                    Button(action: { dietVM.selectedDayIndex = i }) {
                        VStack(spacing: 4) {
                            Text(String(day.dayName.prefix(3))).font(.caption2).bold()
                            Text("\(day.totalCalories)").font(.caption)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(dietVM.selectedDayIndex == i ? Color.green : Color(.secondarySystemGroupedBackground))
                        .foregroundColor(dietVM.selectedDayIndex == i ? .white : .primary)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Macro Bar
struct MacroBar: View {
    let label: String; let value: Int; let unit: String; let color: Color
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(label).font(.caption2).foregroundColor(.secondary)
            }
            Text("\(value)\(unit)").font(.subheadline).bold()
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(color.opacity(0.1)).cornerRadius(10)
    }
}

// MARK: - Meal Card with Real Photo
struct MealCard: View {
    let meal: Meal
    let isLogged: Bool
    let lm: LanguageManager
    let onToggle: () -> Void
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {

            // ── Real Food Photo ──────────────────────────────────
            ZStack(alignment: .bottom) {
                MealImageView(mealName: meal.name, height: 200)
                    .frame(maxWidth: .infinity)

                // Dark gradient for text readability
                LinearGradient(
                    colors: [.clear, .black.opacity(0.75)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 200)

                // Meal info overlay
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        HStack(spacing: 5) {
                            Image(systemName: meal.type.icon)
                                .font(.caption2)
                                .foregroundColor(meal.type.color)
                            Text(meal.type.rawValue)
                                .font(.caption).bold()
                                .foregroundColor(meal.type.color)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.black.opacity(0.45))
                        .cornerRadius(8)

                        Spacer()

                        if isLogged {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                Text(lm.t(.logged)).font(.caption).bold().foregroundColor(.green)
                            }
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.black.opacity(0.45))
                            .cornerRadius(8)
                        }
                    }

                    Text(meal.name)
                        .font(.title3).bold().foregroundColor(.white)

                    HStack(spacing: 12) {
                        Label("\(meal.calories) kcal", systemImage: "flame.fill")
                            .font(.caption).foregroundColor(.orange)
                        Label("\(Int(meal.proteinGrams))g \(lm.t(.protein))", systemImage: "bolt.fill")
                            .font(.caption).foregroundColor(.yellow)
                        Label("\(meal.prepTimeMinutes) \(lm.t(.min))", systemImage: "clock.fill")
                            .font(.caption).foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 200)
            .cornerRadius(16, corners: isExpanded ? [.topLeft, .topRight] : .allCorners)
            .clipped()

            // ── Expand Button ────────────────────────────────────
            Button(action: { withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundColor(.green)
                    Text(isExpanded
                         ? (lm.isArabic ? "إخفاء التفاصيل" : "Hide details")
                         : (lm.isArabic ? "عرض الوصفة والمكونات" : "Show recipe & ingredients"))
                        .font(.subheadline).bold().foregroundColor(.green)
                    Spacer()
                    Text(lm.isArabic ? "\(meal.prepTimeMinutes) دقيقة تحضير" : "\(meal.prepTimeMinutes) min prep")
                        .font(.caption).foregroundColor(.secondary)
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color(.secondarySystemGroupedBackground))
            }

            // ── Expanded Recipe Section ──────────────────────────
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {

                    // Macro chips
                    HStack(spacing: 10) {
                        MacroChip(icon: "flame.fill",  color: .orange, label: lm.t(.carbs),   value: "\(Int(meal.carbGrams))g")
                        MacroChip(icon: "drop.fill",   color: .yellow, label: lm.t(.fats),    value: "\(Int(meal.fatGrams))g")
                        MacroChip(icon: "bolt.fill",   color: .red,    label: lm.t(.protein), value: "\(Int(meal.proteinGrams))g")
                    }

                    Divider()

                    // Ingredients
                    VStack(alignment: .leading, spacing: 8) {
                        Label(lm.t(.ingredients), systemImage: "cart.fill")
                            .font(.headline).foregroundColor(.primary)
                        ForEach(meal.ingredients, id: \.self) { ing in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle")
                                    .font(.caption).foregroundColor(.green).padding(.top, 2)
                                Text(ing).font(.subheadline).foregroundColor(.secondary)
                            }
                        }
                    }

                    Divider()

                    // Prep steps
                    VStack(alignment: .leading, spacing: 10) {
                        Label(lm.t(.preparation), systemImage: "flame.fill")
                            .font(.headline).foregroundColor(.primary)
                        ForEach(Array(meal.prepInstructions.enumerated()), id: \.offset) { i, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(i+1)")
                                    .font(.caption2).bold()
                                    .frame(width: 24, height: 24)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                Text(step).font(.subheadline).foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    // Log button
                    Button(action: onToggle) {
                        HStack {
                            Image(systemName: isLogged ? "checkmark.circle.fill" : "plus.circle.fill")
                                .font(.title3)
                            Text(isLogged ? lm.t(.logged) : lm.t(.markAsEaten))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity).padding(14)
                        .background(isLogged
                            ? LinearGradient(colors: [.green.opacity(0.2), .mint.opacity(0.15)], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(isLogged ? .green : .white)
                        .cornerRadius(14)
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
            }
        }
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Macro Chip
struct MacroChip: View {
    let icon: String; let color: Color; let label: String; let value: String
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.caption).foregroundColor(color)
            Text(value).font(.subheadline).bold()
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(color.opacity(0.1)).cornerRadius(12)
    }
}

// MARK: - Mini Macro
struct MiniMacro: View {
    let label: String; let value: String; let color: Color
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.caption).bold()
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 8)
        .background(color.opacity(0.12)).cornerRadius(8)
    }
}

// MARK: - Meal Plan Picker
struct MealPlanPickerView: View {
    let lm: LanguageManager
    @EnvironmentObject var dietVM: DietViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            List(dietVM.allMealPlans) { plan in
                Button(action: { dietVM.selectPlan(plan); dismiss() }) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(plan.name).font(.headline).foregroundColor(.primary)
                            Spacer()
                            if dietVM.currentMealPlan?.id == plan.id {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            }
                        }
                        HStack {
                            Text(plan.dietaryPreference.localizedName(lm)).font(.caption).foregroundColor(.secondary)
                            Text("·")
                            Text("\(plan.dailyCalorieTarget) \(lm.t(.kcalDay))").font(.caption).foregroundColor(.secondary)
                            Text("·")
                            Text(plan.goal.localizedName(lm)).font(.caption).foregroundColor(plan.goal.color)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(lm.t(.chooseMealPlan))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(lm.isArabic ? "تم" : "Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Corner Radius Helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
