// LogExerciseSheet.swift
// SpeedLabJr
//
// Bottom sheet for logging sets / reps / weight / time / distance
// for a specific exercise within a workout session.
// Sprint exercises also accept an optional time for animal speed comparisons.

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
    @State private var sprintTimeSeconds: Int = 0   // optional time for distance exercises
    @State private var notes: String = ""

    // Post-save animal celebration
    @State private var animalResult: AnimalSpeedComparison.CelebrationResult?
    @State private var showAnimalCard = false

    private var color: Color { session.workoutDay?.color ?? .orange }
    private var isSprint: Bool { exercise.logType == .setsAndDistance }

    // MARK: - Init (pre-fill from existing log)

    init(exercise: Exercise, session: WorkoutSession, existingLog: ExerciseLog?) {
        self.exercise = exercise
        self.session  = session
        self.existingLog = existingLog

        let log = existingLog
        _sets             = State(initialValue: log?.sets            ?? exercise.defaultSets)
        _reps             = State(initialValue: log?.reps            ?? exercise.defaultReps)
        _weightLbs        = State(initialValue: log?.weightLbs       ?? 0)
        _durationSeconds  = State(initialValue: log?.durationSeconds ?? exercise.defaultSeconds)
        _distanceMeters   = State(initialValue: log?.distanceMeters  ?? 0)
        _sprintTimeSeconds = State(initialValue: 0)
        _notes            = State(initialValue: log?.notes           ?? "")
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Header
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

                // Logging fields
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

                // Optional sprint time — only for distance exercises
                if isSprint {
                    Section {
                        TimeStepperRow(label: "Your time (seconds, optional)", value: $sprintTimeSeconds)
                        if sprintTimeSeconds > 0 && distanceMeters > 0 {
                            let kmh = (Double(distanceMeters) / Double(sprintTimeSeconds)) * 3.6
                            Label(String(format: "≈ %.1f km/h", kmh), systemImage: "speedometer")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    } header: {
                        Text("Speed (optional)")
                    } footer: {
                        Text("Log your time to unlock your animal speed comparison 🐾")
                            .font(.caption)
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
        .sheet(isPresented: $showAnimalCard) {
            if let result = animalResult {
                AnimalCelebrationCard(result: result)
            }
        }
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
        // For sprint exercises, store the sprint time in durationSeconds
        let effectiveDuration = isSprint ? sprintTimeSeconds : durationSeconds

        if let existing = existingLog {
            existing.sets            = sets
            existing.reps            = reps
            existing.weightLbs       = weightLbs
            existing.durationSeconds = effectiveDuration
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
            log.durationSeconds = effectiveDuration
            log.distanceMeters  = distanceMeters
            log.notes           = notes
            context.insert(log)
        }
        try? context.save()

        // Trigger animal celebration if sprint time was logged
        if isSprint && sprintTimeSeconds > 0 && distanceMeters > 0 {
            animalResult = AnimalSpeedComparison.celebrationMessage(
                distanceMeters: distanceMeters,
                timeSeconds: sprintTimeSeconds
            )
            showAnimalCard = animalResult != nil
        } else {
            dismiss()
        }
    }
}

// MARK: - AnimalCelebrationCard

struct AnimalCelebrationCard: View {
    let result: AnimalSpeedComparison.CelebrationResult
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            // Big emoji + celebration
            VStack(spacing: 16) {
                Text(result.animal.emoji)
                    .font(.system(size: 100))
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            scale   = 1.0
                            opacity = 1.0
                        }
                    }

                Text(result.headline)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(String(format: "Your speed: %.1f km/h", result.speedKmh))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(.top, 48)
            .padding(.bottom, 24)

            // Fun fact card
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Fun fact about the \(result.animal.name)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.secondary)
                    Text(result.funFact)
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Keep Going! 🚀")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
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
                .buttonStyle(.borderless)
                Text("\(value)s")
                    .frame(minWidth: 48, alignment: .center)
                    .font(.body.monospacedDigit())
                Button { value += 5 } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
                .buttonStyle(.borderless)
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
                .buttonStyle(.borderless)
                Text("\(value)m")
                    .frame(minWidth: 52, alignment: .center)
                    .font(.body.monospacedDigit())
                Button { value += 10 } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

// MARK: - WeightField

struct WeightField: View {
    @Binding var weightLbs: Double

    // Use a local text buffer; sync bidirectionally with the binding
    @State private var weightText: String = ""
    @State private var didAppear = false

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
            guard !didAppear else { return }
            didAppear = true
            if weightLbs > 0 {
                weightText = String(format: "%.1f", weightLbs)
            }
        }
        .onChange(of: weightLbs) { _, newValue in
            // Sync back if the binding changes externally and our text is stale
            let parsed = Double(weightText) ?? 0
            if abs(parsed - newValue) > 0.01 {
                weightText = newValue > 0 ? String(format: "%.1f", newValue) : ""
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
