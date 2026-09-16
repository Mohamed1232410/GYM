//
//  Progressview.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.



import SwiftUI
import Charts

struct GymProgressView: View {
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var lm: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddMeasurement = false

    var last7DaysSessions: [(String, Int)] {
        let cal = Calendar.current
        return (0..<7).reversed().map { offset in
            let date = cal.date(byAdding: .day, value: -offset, to: Date())!
            let label = offset == 0
                ? (lm.isArabic ? "اليوم" : "Today")
                : cal.shortWeekdaySymbols[cal.component(.weekday, from: date) - 1]
            let count = workoutVM.sessions.filter { cal.isDate($0.date, inSameDayAs: date) && $0.isCompleted }.count
            return (label, count)
        }
    }

    var weightHistory: [BodyMeasurement] {
        userProfileVM.measurements.sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCards
                    weeklyChart
                    weightChart
                    recentSessionsList
                    Button(action: { showingAddMeasurement = true }) {
                        Label(lm.t(.logBodyMeasurement), systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.green.opacity(0.15)).foregroundColor(.green)
                            .cornerRadius(16).padding(.horizontal)
                    }
                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(lm.t(.progress))
            .sheet(isPresented: $showingAddMeasurement) {
                AddMeasurementView(lm: lm).environmentObject(userProfileVM)
            }
        }

    }

    var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ProgressStatCard(title: lm.t(.totalWorkouts),  value: "\(workoutVM.totalWorkoutsCompleted)", subtitle: lm.t(.sessions), icon: "dumbbell.fill",               color: .blue)
            ProgressStatCard(title: lm.t(.hoursTrained),   value: String(format: "%.1f", Double(workoutVM.totalMinutesTrained)/60), subtitle: lm.t(.hours), icon: "clock.fill", color: .orange)
            ProgressStatCard(title: lm.t(.caloriesBurned), value: "\(workoutVM.totalCaloriesBurned)", subtitle: "kcal", icon: "flame.fill",                                 color: .red)
            ProgressStatCard(title: lm.t(.weeklyStreak),   value: "\(workoutVM.weeklyStreak)",         subtitle: lm.t(.weeks), icon: "bolt.fill",                           color: .yellow)
        }
        .padding(.horizontal)
    }

    var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lm.t(.last7Days)).font(.headline)
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(last7DaysSessions, id: \.0) { item in
                        BarMark(x: .value("Day", item.0), y: .value("Workouts", item.1))
                            .foregroundStyle(Color.green.gradient).cornerRadius(6)
                    }
                }
                .frame(height: 160)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(last7DaysSessions, id: \.0) { item in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 6).fill(Color.green)
                                .frame(height: CGFloat(item.1) * 40 + 4)
                            Text(item.0).font(.caption2).foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 100)
            }
        }
        .padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(16).padding(.horizontal)
    }

    var weightChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(lm.t(.weightProgress)).font(.headline)
                Spacer()
                if let change = userProfileVM.weightChange() {
                    Text(change >= 0 ? "+\(String(format: "%.1f", change)) kg" : "\(String(format: "%.1f", change)) kg")
                        .font(.subheadline).bold().foregroundColor(change >= 0 ? .red : .green)
                }
            }
            if weightHistory.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis").font(.largeTitle).foregroundColor(.secondary.opacity(0.4))
                    Text(lm.isArabic ? "سجّل قياسك الأول لتتبع وزنك" : "Log your first measurement to track weight")
                        .font(.caption).foregroundColor(.secondary).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 30)
            } else if #available(iOS 16.0, *) {
                Chart {
                    ForEach(weightHistory) { m in
                        LineMark(x: .value("Date", m.date), y: .value("Weight", m.weightKg))
                            .foregroundStyle(Color.blue.gradient)
                        PointMark(x: .value("Date", m.date), y: .value("Weight", m.weightKg))
                            .foregroundStyle(Color.blue)
                    }
                }
                .frame(height: 160)
            }
        }
        .padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(16).padding(.horizontal)
    }

    var recentSessionsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lm.t(.recentSessions)).font(.headline)
            if workoutVM.sessions.isEmpty {
                Text(lm.t(.noSessionsYet)).font(.caption).foregroundColor(.secondary).padding(.vertical, 8)
            } else {
                ForEach(workoutVM.sessions.suffix(5).reversed()) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.workoutName).font(.subheadline).bold()
                            Text(session.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(lm.isArabic ? "\(session.durationSeconds/60) دقيقة" : "\(session.durationSeconds/60) min")
                                .font(.caption).bold()
                            Text("\(session.caloriesBurned) kcal").font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                    Divider()
                }
            }
        }
        .padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(16).padding(.horizontal)
    }
}

struct ProgressStatCard: View {
    let title: String; let value: String; let subtitle: String; let icon: String; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack { Image(systemName: icon).foregroundColor(color); Spacer() }
            Text(value).font(.system(size: 28, weight: .bold, design: .rounded))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).bold()
                Text(subtitle).font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding().background(Color(.secondarySystemGroupedBackground)).cornerRadius(16)
    }
}

struct AddMeasurementView: View {
    let lm: LanguageManager
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var weight: String = ""
    @State private var bodyFat: String = ""
    @State private var waist: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(lm.t(.bodyWeight)) {
                    HStack {
                        TextField(lm.t(.weight), text: $weight).keyboardType(.decimalPad)
                        Text("kg").foregroundColor(.secondary)
                    }
                }
                Section(lm.t(.optional)) {
                    HStack {
                        TextField(lm.isArabic ? "نسبة الدهون ٪" : "Body fat %", text: $bodyFat).keyboardType(.decimalPad)
                        Text("%").foregroundColor(.secondary)
                    }
                    HStack {
                        TextField(lm.isArabic ? "محيط الخصر سم" : "Waist cm", text: $waist).keyboardType(.decimalPad)
                        Text("cm").foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(lm.t(.logMeasurement))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button(lm.t(.cancel)) { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(lm.t(.save)) {
                        guard let w = Double(weight) else { return }
                        userProfileVM.addMeasurement(BodyMeasurement(
                            date: Date(), weightKg: w,
                            bodyFatPercent: Double(bodyFat), waistCm: Double(waist)
                        ))
                        dismiss()
                    }
                    .font(.headline).disabled(weight.isEmpty)
                }
            }
        }
    }
}
