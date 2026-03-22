// GoalsView.swift
// SpeedLabJr

import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var context
    @Query private var allGoals: [UserGoal]
    @Query private var earnedAchievements: [AchievementRecord]
    
    @State private var weeklyGoalValue: Double = 4.0
    
    // For adding exercise goals
    @State private var showingAddExerciseGoal = false
    @State private var newExerciseName: String = ""
    @State private var newExerciseTarget: Double = 10.0
    
    // Get distinct logged exercises to pick from
    @Query private var allLogs: [ExerciseLog]
    private var loggedExerciseNames: [String] {
        Array(Set(allLogs.map { $0.exerciseName })).sorted()
    }
    
    private var weeklyGoal: UserGoal? {
        allGoals.first(where: { $0.typeRaw == "weeklyWorkouts" })
    }
    
    private var exerciseGoals: [UserGoal] {
        allGoals.filter { $0.typeRaw == "exerciseTarget" }
    }
    
    private var achievementCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for r in earnedAchievements {
            counts[r.achievementID, default: 0] += 1
        }
        return counts
    }
    
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 16)]
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Weekly Consistency")) {
                    HStack {
                        Text("Workouts per week")
                        Spacer()
                        Stepper("\(Int(weeklyGoalValue))", value: $weeklyGoalValue, in: 1...7)
                            .onChange(of: weeklyGoalValue) { _, newValue in
                                saveWeeklyGoal(newValue)
                            }
                    }
                }
                
                Section(header: Text("Exercise Targets")) {
                    ForEach(exerciseGoals) { goal in
                        HStack {
                            Text(goal.exerciseName ?? "Unknown")
                            Spacer()
                            Text("\(Int(goal.targetValue))")
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: deleteExerciseGoals)
                    
                    if !loggedExerciseNames.isEmpty {
                        Button {
                            showingAddExerciseGoal = true
                        } label: {
                            Label("Add Exercise Target", systemImage: "plus")
                        }
                    } else {
                        Text("Log an exercise first to set a target for it.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Trophy Case").font(.headline)) {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(AchievementEngine.allAchievements) { def in
                            let count = achievementCounts[def.id] ?? 0
                            AchievementBadgeView(def: def, count: count)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("Goals & Trophies")
            .onAppear {
                if let wg = weeklyGoal {
                    weeklyGoalValue = wg.targetValue
                } else {
                    saveWeeklyGoal(4.0)
                }
            }
            .sheet(isPresented: $showingAddExerciseGoal) {
                NavigationStack {
                    Form {
                        Picker("Exercise", selection: $newExerciseName) {
                            Text("Select Exercise").tag("")
                            ForEach(loggedExerciseNames, id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }
                        HStack {
                            Text("Target Value")
                            Spacer()
                            TextField("Amount", value: $newExerciseTarget, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .navigationTitle("New Target")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingAddExerciseGoal = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                if !newExerciseName.isEmpty {
                                    let newGoal = UserGoal(typeRaw: "exerciseTarget", targetValue: newExerciseTarget, exerciseName: newExerciseName)
                                    context.insert(newGoal)
                                }
                                showingAddExerciseGoal = false
                            }
                            .disabled(newExerciseName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func saveWeeklyGoal(_ value: Double) {
        if let wg = weeklyGoal {
            wg.targetValue = value
        } else {
            let newWg = UserGoal(typeRaw: "weeklyWorkouts", targetValue: value)
            context.insert(newWg)
        }
        try? context.save()
    }
    
    private func deleteExerciseGoals(offsets: IndexSet) {
        for index in offsets {
            let goal = exerciseGoals[index]
            context.delete(goal)
        }
    }
}

// MARK: - AchievementBadgeView

struct AchievementBadgeView: View {
    let def: AchievementDefinition
    let count: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(badgeGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: shadowColor, radius: count >= 20 ? 12 : 5, y: 4)
                
                Text(def.emoji)
                    .font(.system(size: 36))
                
                if count > 0 {
                    Text("x\(count)")
                        .font(.caption2.weight(.black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.65))
                        .clipShape(Capsule())
                        .offset(y: 40)
                }
            }
            .grayscale(count == 0 ? 0.99 : 0.0)
            .opacity(count == 0 ? 0.3 : 1.0)
            
            Text(def.name)
                .font(.caption2.weight(.bold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
    
    private var badgeGradient: LinearGradient {
        let colors: [Color]
        if count == 0 { 
            colors = [Color.gray.opacity(0.3), Color.gray.opacity(0.4)]
        } else if count >= 20 { 
            colors = [Color.cyan, Color.blue] // Diamond
        } else if count >= 10 { 
            colors = [Color.yellow, Color.orange] // Gold
        } else if count >= 5 { 
            colors = [Color(white: 0.8), Color(white: 0.6)]    // Silver
        } else { 
            colors = [Color.brown.opacity(0.8), Color.brown.opacity(0.6)] // Bronze
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var shadowColor: Color {
        count >= 20 ? Color.cyan.opacity(0.8) : Color.black.opacity(0.15)
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: [UserGoal.self, ExerciseLog.self], inMemory: true)
}
