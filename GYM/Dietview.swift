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
                            VStack(spacing: 12) {
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
                    Text(lm.isArabic
                         ? "اليوم: \(dietVM.todayCaloriesConsumed) سعرة"
                         : "Today: \(dietVM.todayCaloriesConsumed) kcal")
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
                }
                .frame(height: 10)
            }
            HStack(spacing: 12) {
                MacroBar(label: lm.t(.protein), value: plan.proteinGrams, unit: "g", color: .red)
                MacroBar(label: lm.t(.carbs),   value: plan.carbGrams,    unit: "g", color: .orange)
                MacroBar(label: lm.t(.fats),    value: plan.fatGrams,     unit: "g", color: .yellow)
            }
        }
        .padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(16).padding(.horizontal)
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
        .frame(maxWidth: .infinity).padding(.vertical, 10).background(color.opacity(0.1)).cornerRadius(10)
    }
}

struct MealCard: View {
    let meal: Meal; let isLogged: Bool; let lm: LanguageManager; let onToggle: () -> Void
    @State private var isExpanded = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                HStack(spacing: 12) {
                    Image(systemName: meal.type.icon).font(.title3).foregroundColor(meal.type.color)
                        .frame(width: 36, height: 36).background(meal.type.color.opacity(0.12)).cornerRadius(10)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(meal.type.rawValue).font(.caption).foregroundColor(.secondary)
                        Text(meal.name).font(.headline).foregroundColor(.primary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(meal.calories) kcal").font(.subheadline).bold()
                        Text("\(Int(meal.proteinGrams))g \(lm.t(.protein))").font(.caption).foregroundColor(.secondary)
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down").foregroundColor(.secondary).font(.caption)
                }
                .padding()
            }
            if isExpanded {
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    Text(meal.description).font(.subheadline).foregroundColor(.secondary)
                    HStack(spacing: 16) {
                        MiniMacro(label: lm.t(.carbs), value: "\(Int(meal.carbGrams))g", color: .orange)
                        MiniMacro(label: lm.t(.fats),  value: "\(Int(meal.fatGrams))g",  color: .yellow)
                        MiniMacro(label: lm.t(.prepTime), value: "\(meal.prepTimeMinutes) \(lm.t(.min))", color: .blue)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lm.t(.ingredients)).font(.subheadline).bold()
                        ForEach(meal.ingredients, id: \.self) { ing in
                            HStack { Circle().fill(Color.green).frame(width: 5, height: 5); Text(ing).font(.caption) }
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lm.t(.preparation)).font(.subheadline).bold()
                        ForEach(Array(meal.prepInstructions.enumerated()), id: \.offset) { i, step in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(i+1).").font(.caption).bold().foregroundColor(.green)
                                Text(step).font(.caption)
                            }
                        }
                    }
                    Button(action: onToggle) {
                        HStack {
                            Image(systemName: isLogged ? "checkmark.circle.fill" : "circle")
                            Text(isLogged ? lm.t(.logged) : lm.t(.markAsEaten)).font(.subheadline)
                        }
                        .frame(maxWidth: .infinity).padding(10)
                        .background(isLogged ? Color.green.opacity(0.15) : Color.green)
                        .foregroundColor(isLogged ? .green : .white).cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .background(Color(.secondarySystemGroupedBackground)).cornerRadius(16)
        .overlay(isLogged ? RoundedRectangle(cornerRadius: 16).stroke(Color.green.opacity(0.4), lineWidth: 1) : nil)
    }
}

struct MiniMacro: View {
    let label: String; let value: String; let color: Color
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.caption).bold()
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .padding(.horizontal, 10).padding(.vertical, 6).background(color.opacity(0.12)).cornerRadius(8)
    }
}

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



