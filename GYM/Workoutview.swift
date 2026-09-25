//
//  Workoutview.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.



import SwiftUI

// MARK: - Workout View
struct WorkoutView: View {
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @EnvironmentObject var lm: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedFilter: FitnessGoal? = nil
    @State private var showingExerciseLibrary = false

    var filteredPlans: [WorkoutPlan] {
        guard let filter = selectedFilter else { return workoutVM.allPlans }
        return workoutVM.allPlans.filter { $0.goal == filter }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let plan = workoutVM.currentPlan {
                        activePlanBanner(plan: plan)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(title: lm.isArabic ? "الكل" : "All",
                                       isSelected: selectedFilter == nil) { selectedFilter = nil }
                            ForEach(FitnessGoal.allCases, id: \.self) { goal in
                                FilterChip(title: goal.localizedName(lm),
                                           isSelected: selectedFilter == goal) {
                                    selectedFilter = selectedFilter == goal ? nil : goal
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    VStack(spacing: 16) {
                        ForEach(filteredPlans) { plan in
                            NavigationLink(destination:
                                WorkoutPlanDetailView(plan: plan)
                                    .environmentObject(workoutVM)
                                    .environmentObject(lm)
                                    .environmentObject(themeManager)
                            ) {
                                WorkoutPlanCard(plan: plan,
                                                isActive: workoutVM.currentPlan?.id == plan.id,
                                                lm: lm)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)

                    Button(action: { showingExerciseLibrary = true }) {
                        HStack {
                            Image(systemName: "books.vertical.fill")
                            Text(lm.t(.exerciseLibrary)).font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    .foregroundColor(.primary)
                    .sheet(isPresented: $showingExerciseLibrary) {
                        ExerciseLibraryView()
                            .environmentObject(workoutVM)
                            .environmentObject(lm)
                            .environmentObject(themeManager)
                    }
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(lm.t(.workouts))
        }

    }

    func activePlanBanner(plan: WorkoutPlan) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(lm.t(.activePlan), systemImage: "checkmark.seal.fill")
                    .font(.caption).foregroundColor(.green)
                Spacer()
                Text("\(plan.durationWeeks) \(lm.t(.weeks))")
                    .font(.caption).foregroundColor(.secondary)
            }
            Text(plan.name).font(.title2).bold()
            HStack {
                Label("\(plan.daysPerWeek) \(lm.t(.daysPerWeek))", systemImage: "calendar")
                Spacer()
                DifficultyBadge(difficulty: plan.difficulty)
            }
            .font(.subheadline).foregroundColor(.secondary)
        }
        .padding()
        .background(LinearGradient(colors: [.green.opacity(0.15), .mint.opacity(0.08)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.green.opacity(0.3), lineWidth: 1))
        .padding(.horizontal)
    }
}

// MARK: - Plan Card
struct WorkoutPlanCard: View {
    let plan: WorkoutPlan
    let isActive: Bool
    let lm: LanguageManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: plan.goal.icon)
                    .font(.title3).foregroundColor(plan.goal.color)
                    .frame(width: 40, height: 40)
                    .background(plan.goal.color.opacity(0.12)).cornerRadius(10)
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.name).font(.headline)
                    Text(plan.goal.localizedName(lm)).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                if isActive { Image(systemName: "checkmark.circle.fill").foregroundColor(.green) }
            }
            Text(plan.description).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
            HStack(spacing: 16) {
                Label("\(plan.daysPerWeek) \(lm.t(.daysPerWeek))", systemImage: "calendar")
                Label("\(plan.durationWeeks) \(lm.t(.weeks))", systemImage: "clock")
                Spacer()
                DifficultyBadge(difficulty: plan.difficulty)
            }
            .font(.caption).foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(isActive ? RoundedRectangle(cornerRadius: 16).stroke(Color.green, lineWidth: 2) : nil)
    }
}

// MARK: - Plan Detail
struct WorkoutPlanDetailView: View {
    let plan: WorkoutPlan
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @EnvironmentObject var lm: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedWeek: Int = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: plan.goal.icon).font(.title).foregroundColor(plan.goal.color)
                        Text(plan.goal.localizedName(lm)).foregroundColor(plan.goal.color).font(.headline)
                        Spacer()
                        DifficultyBadge(difficulty: plan.difficulty)
                    }
                    Text(plan.description).font(.body).foregroundColor(.secondary)
                    HStack(spacing: 24) {
                        VStack {
                            Text("\(plan.durationWeeks)").font(.title2).bold()
                            Text(lm.t(.weeks)).font(.caption).foregroundColor(.secondary)
                        }
                        Divider().frame(height: 36)
                        VStack {
                            Text("\(plan.daysPerWeek)").font(.title2).bold()
                            Text(lm.t(.daysPerWeek)).font(.caption).foregroundColor(.secondary)
                        }
                        Divider().frame(height: 36)
                        VStack {
                            Text("\(plan.weeks.first?.days.filter { !$0.isRestDay }.flatMap { $0.exercises }.count ?? 0)").font(.title2).bold()
                            Text(lm.t(.exercises)).font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<plan.weeks.count, id: \.self) { i in
                            Button(lm.isArabic ? "الأسبوع \(i+1)" : "Week \(i+1)") { selectedWeek = i }
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(selectedWeek == i ? Color.green : Color(.secondarySystemGroupedBackground))
                                .foregroundColor(selectedWeek == i ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(spacing: 12) {
                    ForEach(plan.weeks[safe: selectedWeek]?.days ?? []) { day in
                        if day.isRestDay {
                            RestDayRow(day: day, lm: lm)
                        } else {
                            NavigationLink(destination:
                                WorkoutDayDetailView(day: day, planName: plan.name, planGoal: plan.goal)
                                    .environmentObject(workoutVM)
                                    .environmentObject(lm)
                                    .environmentObject(themeManager)
                            ) {
                                WorkoutDayRow(day: day, lm: lm, planGoal: plan.goal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    workoutVM.selectPlan(plan)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: workoutVM.currentPlan?.id == plan.id ? "checkmark.circle.fill" : "plus.circle.fill")
                        Text(workoutVM.currentPlan?.id == plan.id ? lm.t(.currentPlan) : lm.t(.startThisPlan))
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(workoutVM.currentPlan?.id == plan.id ? Color.green.opacity(0.15) : Color.green)
                    .foregroundColor(workoutVM.currentPlan?.id == plan.id ? .green : .white)
                    .cornerRadius(16)
                }
                .padding(.horizontal).padding(.bottom, 30)
            }
            .padding(.top)
        }
        .navigationTitle(plan.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Day Detail
struct WorkoutDayDetailView: View {
    let day: WorkoutDay
    let planName: String
    let planGoal: FitnessGoal          // ← new: determines exercise photos
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @EnvironmentObject var lm: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingActiveWorkout = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(day.dayName).font(.subheadline).foregroundColor(.secondary)
                        Text(day.focus).font(.title2).bold()
                    }
                    Spacer()
                    Label("\(day.estimatedMinutes) \(lm.t(.min))", systemImage: "clock")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.horizontal)

                VStack(spacing: 12) {
                    ForEach(Array(day.exercises.enumerated()), id: \.element.id) { index, exercise in
                        NavigationLink(destination:
                            ExerciseDetailView(exercise: exercise, planGoal: planGoal)
                                .environmentObject(lm)
                                .environmentObject(themeManager)
                        ) {
                            ExerciseRowCard(exercise: exercise, index: index + 1, lm: lm, planGoal: planGoal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    workoutVM.startWorkout(day: day, workoutName: "\(planName) - \(day.focus)")
                    showingActiveWorkout = true
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text(lm.t(.startWorkout)).font(.headline)
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.green).foregroundColor(.white).cornerRadius(16)
                }
                .padding(.horizontal).padding(.bottom, 30)
            }
            .padding(.top)
        }
        .navigationTitle(day.focus)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingActiveWorkout) {
            ActiveWorkoutView()
                .environmentObject(workoutVM)
                .environmentObject(lm)
        }
    }
}

// MARK: - Active Workout
struct ActiveWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @EnvironmentObject var lm: LanguageManager
    @Environment(\.presentationMode) var presentationMode
    @State private var currentExerciseIndex: Int = 0
    @State private var showingFinishAlert = false
    var session: WorkoutSession? { workoutVM.activeSession }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text(workoutVM.timerString())
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                    Text(session?.workoutName ?? lm.t(.startWorkout))
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity).padding()
                .background(Color(.systemGroupedBackground))

                Divider()

                if let session = session, !session.completedExercises.isEmpty {
                    let exercises = session.completedExercises
                    ScrollView {
                        VStack(spacing: 20) {
                            HStack {
                                Text(lm.isArabic
                                     ? "تمرين \(currentExerciseIndex + 1) من \(exercises.count)"
                                     : "Exercise \(currentExerciseIndex + 1) of \(exercises.count)")
                                    .font(.subheadline).foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)

                            if let ex = exercises[safe: currentExerciseIndex] {
                                Text(ex.exerciseName).font(.title2).bold()
                                    .padding(.horizontal).frame(maxWidth: .infinity, alignment: .leading)
                                VStack(spacing: 8) {
                                    ForEach(Array(ex.sets.enumerated()), id: \.element.id) { i, set in
                                        SetRow(set: set, setIndex: i, exerciseIndex: currentExerciseIndex, lm: lm)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }

                    HStack(spacing: 16) {
                        if currentExerciseIndex > 0 {
                            Button(action: { currentExerciseIndex -= 1 }) {
                                Label(lm.t(.previous), systemImage: "chevron.left")
                                    .frame(maxWidth: .infinity).padding()
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(14)
                            }
                            .foregroundColor(.primary)
                        }
                        if currentExerciseIndex < exercises.count - 1 {
                            Button(action: { currentExerciseIndex += 1 }) {
                                Label(lm.t(.next), systemImage: "chevron.right")
                                    .frame(maxWidth: .infinity).padding()
                                    .background(Color.green).foregroundColor(.white).cornerRadius(14)
                            }
                        } else {
                            Button(action: { showingFinishAlert = true }) {
                                Label(lm.t(.finish), systemImage: "checkmark.circle.fill")
                                    .frame(maxWidth: .infinity).padding()
                                    .background(Color.green).foregroundColor(.white).cornerRadius(14)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(lm.t(.startWorkout))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(lm.t(.cancel)) {
                        workoutVM.cancelWorkout()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .alert(lm.t(.finishWorkoutQ), isPresented: $showingFinishAlert) {
                Button(lm.t(.finish), role: .none) { workoutVM.finishWorkout() }
                Button(lm.t(.cancel), role: .cancel) {}
            } message: {
                Text(lm.t(.greatWork))
            }
        }
    }
}

// MARK: - Set Row
struct SetRow: View {
    let set: CompletedSet
    let setIndex: Int
    let exerciseIndex: Int
    let lm: LanguageManager
    @State private var reps: String = ""
    @State private var weight: String = ""
    @EnvironmentObject var workoutVM: WorkoutViewModel

    var body: some View {
        HStack {
            Text(lm.isArabic ? "مج \(set.setNumber)" : "Set \(set.setNumber)")
                .font(.subheadline).bold().frame(width: 50)
            TextField(lm.t(.reps), text: $reps)
                .keyboardType(.numberPad).padding(10)
                .background(Color(.systemBackground)).cornerRadius(10).frame(maxWidth: .infinity)
            TextField("kg", text: $weight)
                .keyboardType(.decimalPad).padding(10)
                .background(Color(.systemBackground)).cornerRadius(10).frame(maxWidth: .infinity)
            Button(action: {
                workoutVM.completeSet(exerciseIndex: exerciseIndex, setIndex: setIndex,
                                      reps: Int(reps) ?? 0, weight: Double(weight) ?? 0)
            }) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3).foregroundColor(set.isCompleted ? .green : .gray)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .onAppear {
            if set.reps > 0 { reps = "\(set.reps)" }
            if set.weightKg > 0 { weight = "\(set.weightKg)" }
        }
    }
}

// MARK: - Exercise Library
struct ExerciseLibraryView: View {
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @EnvironmentObject var lm: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var filterCategory: ExerciseCategory? = nil

    var filtered: [Exercise] {
        var exercises = workoutVM.allExercises
        if let cat = filterCategory { exercises = exercises.filter { $0.category == cat } }
        if !searchText.isEmpty {
            exercises = exercises.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.muscleGroups.map { $0.rawValue }.joined().localizedCaseInsensitiveContains(searchText)
            }
        }
        return exercises
    }

    var body: some View {
        NavigationView {
            List {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        FilterChip(title: lm.isArabic ? "الكل" : "All",
                                   isSelected: filterCategory == nil) { filterCategory = nil }
                        ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                            FilterChip(title: cat.rawValue, isSelected: filterCategory == cat) {
                                filterCategory = filterCategory == cat ? nil : cat
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                .listRowSeparator(.hidden)

                ForEach(filtered) { exercise in
                    NavigationLink(destination:
                        ExerciseDetailView(exercise: exercise, planGoal: nil)
                            .environmentObject(lm)
                            .environmentObject(themeManager)
                    ) {
                        ExerciseLibraryRow(exercise: exercise)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText,
                        prompt: lm.isArabic ? "ابحث عن تمرين أو عضلة" : "Search exercises or muscles")
            .navigationTitle(lm.t(.exerciseLibrary))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(lm.isArabic ? "تم" : "Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Exercise Detail
struct ExerciseDetailView: View {
    let exercise: Exercise
    var planGoal: FitnessGoal? = nil
    @EnvironmentObject var lm: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── Hero Fitness Photo (plan-specific) ───────────
                ZStack(alignment: .bottom) {
                    ExerciseHeroImageView(
                        exerciseName: exercise.name,
                        height: 260,
                        goal: planGoal,
                        photoID: exercise.photoID
                    )
                    .frame(maxWidth: .infinity)

                    LinearGradient(colors: [.clear, .black.opacity(0.82)],
                                   startPoint: .center, endPoint: .bottom)
                        .frame(height: 260)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(exercise.category.rawValue)
                                .font(.caption).bold()
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(Color.green.opacity(0.85))
                                .foregroundColor(.white).cornerRadius(8)
                            Spacer()
                            DifficultyBadge(difficulty: exercise.difficulty)
                        }
                        Text(exercise.name)
                            .font(.largeTitle).bold().foregroundColor(.white)
                        HStack(spacing: 16) {
                            Label("\(exercise.sets) \(lm.t(.sets))", systemImage: "square.stack.3d.up.fill")
                            Label(exercise.reps, systemImage: "arrow.counterclockwise")
                            Label("\(exercise.restSeconds)s", systemImage: "timer")
                        }
                        .font(.caption).foregroundColor(.white.opacity(0.9))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 260)
                .clipped()

                // ── Content ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 20) {

                    // Stats bar
                    HStack(spacing: 0) {
                        StatBox(title: lm.t(.sets), value: "\(exercise.sets)")
                        Divider()
                        StatBox(title: lm.t(.reps), value: exercise.reps)
                        Divider()
                        StatBox(title: lm.t(.rest), value: "\(exercise.restSeconds)s")
                    }
                    .frame(height: 70)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(14)

                    // Diagram
                    ExerciseDiagramView(exercise: exercise)

                    // Equipment
                    VStack(alignment: .leading, spacing: 8) {
                        Text(lm.t(.equipment)).font(.headline)
                        FlowLayout(items: exercise.equipmentNeeded.map { $0.rawValue })
                    }

                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text(lm.t(.howToPerform)).font(.headline)
                        ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { i, instruction in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(i + 1)").font(.caption).bold()
                                    .frame(width: 24, height: 24)
                                    .background(Color.green).foregroundColor(.white).clipShape(Circle())
                                Text(instruction).font(.body)
                            }
                        }
                    }

                    // Pro tip
                    VStack(alignment: .leading, spacing: 8) {
                        Label(lm.t(.proTip), systemImage: "lightbulb.fill")
                            .font(.headline).foregroundColor(.orange)
                        Text(exercise.tips).font(.body).padding()
                            .background(Color.orange.opacity(0.1)).cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper Views

struct WorkoutDayRow: View {
    let day: WorkoutDay
    let lm: LanguageManager
    var planGoal: FitnessGoal? = nil

    var body: some View {
        VStack(spacing: 0) {
            if !day.exercises.isEmpty {
                HStack(spacing: 2) {
                    ForEach(day.exercises.prefix(3)) { exercise in
                        ExerciseHeroImageView(exerciseName: exercise.name, height: 80, goal: planGoal)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    }
                    if day.exercises.count < 3 {
                        ForEach(0..<(3 - min(day.exercises.count, 3)), id: \.self) { _ in
                            LinearGradient(colors: [.green.opacity(0.3), .mint.opacity(0.2)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                                .frame(maxWidth: .infinity, maxHeight: 80)
                        }
                    }
                }
                .frame(height: 80)
                .cornerRadius(14, corners: [.topLeft, .topRight])
                .clipped()
            }
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(day.dayName).font(.caption).foregroundColor(.secondary)
                    Text(day.focus).font(.headline)
                    Text(lm.isArabic
                         ? "\(day.exercises.count) تمرين · \(day.estimatedMinutes) دقيقة"
                         : "\(day.exercises.count) exercises · \(day.estimatedMinutes) min")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.green).font(.subheadline)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(14, corners: [.bottomLeft, .bottomRight])
        }
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
    }
}

struct RestDayRow: View {
    let day: WorkoutDay
    let lm: LanguageManager
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(day.dayName).font(.caption).foregroundColor(.secondary)
                Text(lm.t(.restDay)).font(.headline)
            }
            Spacer()
            Image(systemName: "bed.double.fill").foregroundColor(.purple)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14).opacity(0.7)
    }
}

struct ExerciseRowCard: View {
    let exercise: Exercise
    let index: Int
    let lm: LanguageManager
    var planGoal: FitnessGoal? = nil

    var body: some View {
        HStack(spacing: 0) {
            ExerciseHeroImageView(exerciseName: exercise.name, height: 80, goal: planGoal, photoID: exercise.photoID)
                .frame(width: 90, height: 80)
                .cornerRadius(12, corners: [.topLeft, .bottomLeft])
                .clipped()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("\(index)")
                            .font(.caption2).bold()
                            .frame(width: 20, height: 20)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                        Text(exercise.name).font(.headline).lineLimit(1)
                    }
                    Text(lm.isArabic
                         ? "\(exercise.sets) مجموعات × \(exercise.reps)"
                         : "\(exercise.sets) sets × \(exercise.reps)")
                        .font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 6) {
                        ForEach(exercise.muscleGroups.prefix(2), id: \.self) { mg in
                            Text(mg.rawValue)
                                .font(.caption2)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.blue.opacity(0.12))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary).font(.caption)
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 80)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}

struct ExerciseLibraryRow: View {
    let exercise: Exercise
    var body: some View {
        HStack(spacing: 12) {
            ExerciseHeroImageView(exerciseName: exercise.name, height: 60)
                .frame(width: 70, height: 60)
                .cornerRadius(10)
                .clipped()
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name).font(.headline)
                Text(exercise.muscleGroups.prefix(2).map { $0.rawValue }.joined(separator: ", "))
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            DifficultyBadge(difficulty: exercise.difficulty)
        }
        .padding(.vertical, 4)
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty
    var body: some View {
        Text(difficulty.rawValue).font(.caption2).bold()
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(difficulty.color.opacity(0.15)).foregroundColor(difficulty.color)
            .cornerRadius(8)
    }
}

struct FilterChip: View {
    let title: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(isSelected ? Color.green : Color(.secondarySystemGroupedBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct StatBox: View {
    let title: String; let value: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.title3).bold()
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FlowLayout: View {
    let items: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                ForEach(items, id: \.self) { item in
                    Text(item).font(.caption)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1)).foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
        }
    }
}
