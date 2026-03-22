// UserGoal.swift
// SpeedLabJr

import Foundation
import SwiftData

@Model
final class UserGoal {
    var id: UUID
    var typeRaw: String // "weeklyWorkouts" or "exerciseTarget"
    var exerciseName: String?
    var targetValue: Double

    init(typeRaw: String, targetValue: Double, exerciseName: String? = nil) {
        self.id = UUID()
        self.typeRaw = typeRaw
        self.targetValue = targetValue
        self.exerciseName = exerciseName
    }
}
