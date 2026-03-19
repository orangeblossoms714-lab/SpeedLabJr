// WorkoutSession.swift
// SpeedLabJr
//
// SwiftData model for a single workout session instance.

import Foundation
import SwiftData

// MARK: - WorkoutStatus

enum WorkoutStatus: String, Codable, CaseIterable {
    case upcoming  = "upcoming"
    case completed = "completed"
    case skipped   = "skipped"

    var label: String {
        switch self {
        case .upcoming:  return "Upcoming"
        case .completed: return "Done ✓"
        case .skipped:   return "Skipped"
        }
    }

    var icon: String {
        switch self {
        case .upcoming:  return "circle"
        case .completed: return "checkmark.circle.fill"
        case .skipped:   return "xmark.circle.fill"
        }
    }
}

// MARK: - WorkoutSession

@Model
final class WorkoutSession {

    var id: UUID
    var date: Date
    var dayNumber: Int        // 1–4
    var statusRaw: String     // backed by WorkoutStatus
    var notes: String
    var completedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \ExerciseLog.session)
    var exerciseLogs: [ExerciseLog] = []

    init(date: Date, dayNumber: Int) {
        self.id = UUID()
        self.date = date
        self.dayNumber = dayNumber
        self.statusRaw = WorkoutStatus.upcoming.rawValue
        self.notes = ""
        self.completedAt = nil
    }

    // MARK: Computed helpers

    var status: WorkoutStatus {
        get { WorkoutStatus(rawValue: statusRaw) ?? .upcoming }
        set { statusRaw = newValue.rawValue }
    }

    var workoutDay: WorkoutDay? {
        WorkoutProgram.day(for: dayNumber)
    }

    var title: String {
        workoutDay?.title ?? "Workout Day \(dayNumber)"
    }

    var emoji: String {
        workoutDay?.emoji ?? "🏃"
    }

    var durationMinutes: Int {
        workoutDay?.durationMinutes ?? 0
    }

    /// Convenience: calendar day at start of day (for grouping)
    var calendarDate: Date {
        Calendar.current.startOfDay(for: date)
    }

    /// Log for a specific exercise, if it exists
    func log(for exerciseName: String) -> ExerciseLog? {
        exerciseLogs.first { $0.exerciseName == exerciseName }
    }
}
