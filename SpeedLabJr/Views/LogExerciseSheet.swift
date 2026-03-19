// LogExerciseSheet.swift
// SpeedLabJr
//
// Bottom sheet for logging sets / reps / weight / time / distance
// for a specific exercise within a workout session.

import SwiftUI
import SwiftData

struct LogExerciseSheet: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise
    let session: WorkoutSession
    var existingLog: ExerciseLog?

    // Form state
    @State private var sets: Int = 0
    @State private var reps: Int = 0
    @State private var weightLbs: Double = 0
    @State private var durationSeconds: Int = 0
    @State private var distanceMeters: Int = 0
    @State private var notes: String = ""

    private var color: Color { session.workoutDay?.color ?? .orange }

    // MARK: - Init (pre-fill from existing log)

    init(exercise: Exercise, session: WorkoutSession, existingLog: ExerciseLog?) {
        self.exercise = exercise
        self.session  = session
        self.existingLog = existingLog

        // Pre-populate from defaults or existing log
        let log = existingLog
        _sets            = State(initialValue: log?.sets            ?? exercise.defaultSets)
        _reps            = State(initialValue: log?.reps            ?? exercise.defaultReps)
        _weightLbs       = State(initialValue: log?.weightLbs       ?? 0)
        _durationSeconds = State(initialValue: log?.durationSeconds ?? exercise.defaultSeconds)
        _distanceMeters  = State(initialValue: log?.distanceMeters  ?? 0)
        _notes           = State(initialValue: log?.notes           ?? "")
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Header section
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(color.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: logIcon)
                                .font(.title3.weight(.semibold))
                                .foregroundColor(color)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name)
                                .font(.headline)
                            Text(exercise.prescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Logging fields (conditional on logType)
                Section("Log Your Sets") {
                    StepperRow(label: "Sets", value: $sets, range: 0...20)

                    switch exercise.logType {
                    case .setsAndReps:
                        StepperRow(label: "Reps per Set", value: $reps, range: 0...100)
                        WeightField(weightLbs: $weightLbs)

                    case .setsAndTime:
                        TimeStepperRow(label: "Seconds per Set", value: $durationSeconds)

                    case .setsAndDistance:
                        DistanceStepperRow(label: "Distance (m)", value: $distanceMeters)

                    case .none:
                        EmptyView()
                    }
                }

                // Notes
                Section("Notes (optional)") {
                    TextField("How did it feel? Any observations...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.subheadline)
                }

                // Coach note reminder
                if !exercise.coachNote.isEmpty {
                    Section {
                        Label(exercise.coachNote, systemImage: "lightbulb.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } header: {
                        Text("Coach Note")
                    }
                }
            }
            .navigationTitle("Log Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .font(.headline)
                        .tint(color)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Helpers

    private var logIcon: String {
        switch exercise.logType {
        case .setsAndReps:     return "dumbbell.fill"
        case .setsAndTime:     return "timer"
        case .setsAndDistance: return "figure.run"
        case .none:            return "checkmark"
        }
    }

    // MARK: - Save

    private func save() {
        if let existing = existingLog {
            existing.sets            = sets
            existing.reps            = reps
            existing.weightLbs       = weightLbs
            existing.durationSeconds = durationSeconds
            existing.distanceMeters  = distanceMeters
            existing.notes           = notes
            existing.loggedAt        = Date()
        } else {
            let log = ExerciseLog(
                exerciseName: exercise.name,
                dayNumber: session.dayNumber,
                session: session
            )
            log.sets            = sets
            log.reps            = reps
            log.weightLbs       = weightLbs
            log.durationSeconds = durationSeconds
            log.distanceMeters  = distanceMeters
            log.notes           = notes
            context.insert(log)
        }
        try? context.save()
        dismiss()
    }
}

// MARK: - StepperRow

struct StepperRow: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Stepper("\(value)", value: $value, in: range)
                .fixedSize()
        }
    }
}

// MARK: - TimeStepperRow

struct TimeStepperRow: View {
    let label: String
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            HStack(spacing: 8) {
                Button { value = max(0, value - 5) } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                Text("\(value)s")
                    .frame(minWidth: 48, alignment: .center)
                    .font(.body.monospacedDigit())
                Button { value += 5 } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - DistanceStepperRow

struct DistanceStepperRow: View {
    let label: String
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            HStack(spacing: 8) {
                Button { value = max(0, value - 10) } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                Text("\(value)m")
                    .frame(minWidth: 52, alignment: .center)
                    .font(.body.monospacedDigit())
                Button { value += 10 } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - WeightField

struct WeightField: View {
    @Binding var weightLbs: Double
    @State private var weightText: String = ""

    var body: some View {
        HStack {
            Text("Weight (lbs, optional)")
            Spacer()
            TextField("0", text: $weightText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
                .onChange(of: weightText) { _, newValue in
                    weightLbs = Double(newValue) ?? 0
                }
        }
        .onAppear {
            if weightLbs > 0 {
                weightText = String(format: "%.1f", weightLbs)
            }
        }
    }
}

#Preview {
    let session  = WorkoutSession(date: Date(), dayNumber: 2)
    let exercise = WorkoutProgram.day2.sections[1].exercises[0]
    return LogExerciseSheet(exercise: exercise, session: session, existingLog: nil)
        .modelContainer(for: [WorkoutSession.self, ExerciseLog.self], inMemory: true)
}
