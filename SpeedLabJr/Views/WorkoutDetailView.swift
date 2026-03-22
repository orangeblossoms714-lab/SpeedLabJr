// WorkoutDetailView.swift
// SpeedLabJr
//
// Full workout view: all sections & exercises, with inline logging,
// and the ability to mark the session as done or skipped.

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var session: WorkoutSession

    @State private var logTargetExercise: Exercise?
    @State private var showSkipAlert = false
    @State private var showUndoAlert  = false
    @State private var expandedSections: Set<String> = []
    
    // Gamification & Timers
    @State private var restTimer = RestTimerManager()
    @State private var showConfetti = false

    private var workoutDay: WorkoutDay? { session.workoutDay }
    private var color: Color { workoutDay?.color ?? .orange }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerBanner
                    statusBar
                    Divider()
                    sectionsContent
                }
            }
            .overlay(
                ConfettiView(isFiring: showConfetti)
            )
            .safeAreaInset(edge: .bottom) {
                if restTimer.isActive {
                    restTimerBanner
                }
            }
            .navigationTitle("Day \(session.dayNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(item: $logTargetExercise) { exercise in
                LogExerciseSheet(
                    exercise: exercise,
                    session: session,
                    existingLog: session.log(for: exercise.name)
                )
            }
            .alert("Skip this workout?", isPresented: $showSkipAlert) {
                Button("Skip", role: .destructive) {
                    session.status = .skipped
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You can always un-skip later.")
            }
            .alert("Mark workout as upcoming?", isPresented: $showUndoAlert) {
                Button("Reset to Upcoming") {
                    session.status = .upcoming
                    session.completedAt = nil
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    // MARK: - Header

    private var headerBanner: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [color, color.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 140)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.emoji + "  " + session.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                Text(workoutDay?.subtitle ?? "")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                HStack(spacing: 12) {
                    Label("\(session.durationMinutes) min", systemImage: "clock")
                    Label(session.date.formatted(date: .abbreviated, time: .omitted),
                          systemImage: "calendar")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 2)
            }
            .padding(20)
        }
    }

    private var statusBar: some View {
        HStack(spacing: 0) {
            // Status pill
            HStack(spacing: 6) {
                Image(systemName: session.status.icon)
                Text(session.status.label)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(statusColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Spacer()

            // Action buttons
            if session.status == .upcoming {
                Button {
                    markDone()
                } label: {
                    Label("Done", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .clipShape(Capsule())
                }
                .padding(.trailing, 12)

                Button {
                    showSkipAlert = true
                } label: {
                    Label("Skip", systemImage: "forward.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
                .padding(.trailing, 12)
            } else {
                Button {
                    showUndoAlert = true
                } label: {
                    Text("Undo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.trailing, 16)
            }
        }
        .background(Color(.systemBackground))
    }

    private var statusColor: Color {
        switch session.status {
        case .upcoming:  return .orange
        case .completed: return .green
        case .skipped:   return .gray
        }
    }

    // MARK: - Sections

    private var sectionsContent: some View {
        VStack(spacing: 0) {
            ForEach(workoutDay?.sections ?? []) { section in
                SectionBlock(
                    section: section,
                    session: session,
                    color: color,
                    onLog: { exercise in
                        logTargetExercise = exercise
                    },
                    onRest: { seconds in
                        restTimer.start(seconds: seconds)
                    }
                )
                Divider()
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Close") { dismiss() }
        }
    }

    // MARK: - Actions

    private func markDone() {
        session.status = .completed
        session.completedAt = Date()
        
        // Trigger confetti gamification
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            showConfetti = false
            dismiss()
        }
    }
    
    // MARK: - Rest Timer Banner
    
    private var restTimerBanner: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Resting...")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)
                Text(restTimer.timeString)
                    .font(.title2.monospacedDigit().weight(.black))
            }
            Spacer()
            
            Button("+15s") {
                withAnimation { restTimer.addTime(seconds: 15) }
            }
            .font(.subheadline.weight(.bold))
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
            
            Button("Skip") {
                withAnimation { restTimer.skip() }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.red)
            .clipShape(Capsule())
        }
        .padding()
        .background(Color(.systemBackground).shadow(color: .black.opacity(0.1), radius: 10, y: -5))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - SectionBlock

struct SectionBlock: View {

    let section: WorkoutSection
    let session: WorkoutSession
    let color: Color
    let onLog: (Exercise) -> Void
    let onRest: (Int) -> Void

    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 0) {
            // Section header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(section.name)
                            .font(.caption.weight(.bold))
                            .foregroundColor(color)
                            .tracking(1.2)
                        Text("\(section.durationMinutes) min")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
            }
            .buttonStyle(.plain)

            // Exercises
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(section.exercises) { exercise in
                        ExerciseRow(
                            exercise: exercise,
                            log: session.log(for: exercise.name),
                            color: color,
                            onLog: { onLog(exercise) },
                            onRest: { onRest(60) } // Default 60s rest
                        )
                        if exercise.id != section.exercises.last?.id {
                            Divider().padding(.leading, 56)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ExerciseRow

struct ExerciseRow: View {

    let exercise: Exercise
    let log: ExerciseLog?
    let color: Color
    let onLog: () -> Void
    let onRest: () -> Void

    @State private var showTutorial = false

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 36, height: 36)
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            // Name + prescription
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.subheadline.weight(.medium))
                if !exercise.coachNote.isEmpty {
                    Text(exercise.coachNote)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                // Tutorial link
                Button {
                    showTutorial = true
                } label: {
                    Label("Watch tutorial", systemImage: "play.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.borderless)
            }

            Spacer()

            // Right side: prescription or logged value
            VStack(alignment: .trailing, spacing: 2) {
                if let log = log {
                    Text(log.summary)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.green)
                } else {
                    Text(exercise.prescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if exercise.logType != .none {
                    HStack(spacing: 8) {
                        Button(action: onRest) {
                            Image(systemName: "timer")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(color.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.borderless)

                        Button(action: onLog) {
                            Text(log == nil ? "Log" : "Edit")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(log == nil ? color : Color.green)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .sheet(isPresented: $showTutorial) {
            ExerciseTutorialSheet(exercise: exercise)
        }
    }

    private var iconName: String {
        switch exercise.logType {
        case .setsAndReps:     return "dumbbell.fill"
        case .setsAndTime:     return "timer"
        case .setsAndDistance: return "figure.run"
        case .none:            return "figure.flexibility"
        }
    }

    private var iconBackground: Color {
        if log != nil { return Color.green.opacity(0.15) }
        switch exercise.logType {
        case .none: return Color(.tertiarySystemBackground)
        default:    return color.opacity(0.12)
        }
    }

    private var iconColor: Color {
        if log != nil { return .green }
        switch exercise.logType {
        case .none: return .secondary
        default:    return color
        }
    }
}

#Preview {
    let session = WorkoutSession(date: Date(), dayNumber: 1)
    return WorkoutDetailView(session: session)
        .modelContainer(for: [WorkoutSession.self, ExerciseLog.self], inMemory: true)
}
