// GoalsView.swift
// SpeedLabJr

import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var context
    @Query private var allGoals: [UserGoal]
    
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
            }
            .navigationTitle("Goals")
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

#Preview {
    GoalsView()
        .modelContainer(for: [UserGoal.self, ExerciseLog.self], inMemory: true)
}
