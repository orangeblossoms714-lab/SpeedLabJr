// ExerciseLog.swift
// SpeedLabJr
//
// SwiftData model for a logged exercise within a workout session.

import Foundation
import SwiftData

@Model
final class ExerciseLog {

    var id: UUID
    var exerciseName: String
    var dayNumber: Int        // 1–4 (denormalized for easy querying)
    var sets: Int
    var reps: Int             // per set; 0 if not applicable
    var weightLbs: Double     // 0 if bodyweight only
    var durationSeconds: Int  // per set; 0 if not applicable
    var distanceMeters: Int   // 0 if not applicable
    var notes: String
    var loggedAt: Date

    var session: WorkoutSession?

    init(exerciseName: String, dayNumber: Int, session: WorkoutSession) {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.dayNumber = dayNumber
        self.session = session
        self.sets = 0
        self.reps = 0
        self.weightLbs = 0
        self.durationSeconds = 0
        self.distanceMeters = 0
        self.notes = ""
        self.loggedAt = Date()
    }

    // MARK: - Computed display helpers

    var summary: String {
        var parts: [String] = []
        if sets > 0 { parts.append("\(sets) sets") }
        if reps > 0 { parts.append("\(reps) reps") }
        if weightLbs > 0 { parts.append(String(format: "%.1f lbs", weightLbs)) }
        if durationSeconds > 0 { parts.append("\(durationSeconds)s") }
        if distanceMeters > 0 { parts.append("\(distanceMeters)m") }
        return parts.isEmpty ? "Logged" : parts.joined(separator: " · ")
    }

    /// Primary numeric value used for charting progress
    var chartValue: Double {
        if reps > 0 { return Double(reps) }
        if durationSeconds > 0 { return Double(durationSeconds) }
        if distanceMeters > 0 { return Double(distanceMeters) }
        if sets > 0 { return Double(sets) }
        return 0
    }

    var chartLabel: String {
        if reps > 0 { return "Reps" }
        if durationSeconds > 0 { return "Seconds" }
        if distanceMeters > 0 { return "Meters" }
        return "Sets"
    }
}
