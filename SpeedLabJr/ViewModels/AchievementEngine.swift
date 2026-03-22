// AchievementEngine.swift
// SpeedLabJr

import Foundation
import SwiftData

struct AchievementDefinition: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let emoji: String
}

final class AchievementEngine {
    
    static let allAchievements: [AchievementDefinition] = [
        AchievementDefinition(id: "earlyBird", name: "Early Bird", description: "Log a workout before 8 AM.", emoji: "🌅"),
        AchievementDefinition(id: "nightOwl", name: "Night Owl", description: "Log a workout after 8 PM.", emoji: "🦉"),
        AchievementDefinition(id: "weekendWarrior", name: "Weekend Warrior", description: "Complete a workout on a weekend.", emoji: "🗓️"),
        AchievementDefinition(id: "perfectWeek", name: "Perfect Week", description: "Complete 4 workouts in a single week.", emoji: "💯"),
        AchievementDefinition(id: "consistencyKing", name: "Consistency King", description: "Hit your custom weekly workouts goal.", emoji: "👑"),
        AchievementDefinition(id: "recoveryMaster", name: "Recovery Master", description: "Complete a Recovery & Movement day.", emoji: "🧘‍♂️"),
        AchievementDefinition(id: "volumeJunkie", name: "Volume Junkie", description: "Log over 100 reps in a single day.", emoji: "📈"),
        AchievementDefinition(id: "heavyLifter", name: "Heavy Lifter", description: "Log a weighted exercise at 100 lbs or more.", emoji: "🏋️‍♂️"),
        AchievementDefinition(id: "speedDemon", name: "Speed Demon", description: "Log a sprint time > 25 km/h.", emoji: "⚡"),
        AchievementDefinition(id: "distanceRunner", name: "Distance Runner", description: "Log over 400m of sprinting in a day.", emoji: "🏃‍♂️"),
        AchievementDefinition(id: "coreCrusher", name: "Core Crusher", description: "Log 3 or more distinct core exercises.", emoji: "🧱"),
        AchievementDefinition(id: "theFinisher", name: "The Finisher", description: "Check off every exercise in a workout.", emoji: "🏁")
    ]
    
    @MainActor
    static func evaluate(session: WorkoutSession, context: ModelContext, allSessions: [WorkoutSession], goals: [UserGoal]) -> [AchievementDefinition] {
        var earned: [AchievementDefinition] = []
        let logs = session.exerciseLogs
        
        let cal = Calendar.current
        let hour = cal.component(.hour, from: Date())
        let weekday = cal.component(.weekday, from: Date())
        
        // 1. Early Bird
        if hour < 8 { earned.append(get("earlyBird")) }
        
        // 2. Night Owl
        if hour >= 20 { earned.append(get("nightOwl")) }
        
        // 3. Weekend Warrior (1=Sun, 7=Sat)
        if weekday == 1 || weekday == 7 { earned.append(get("weekendWarrior")) }
        
        // 4. Perfect Week & 5. Consistency King
        let currentWeek = ScheduleManager.weekNumber(for: Date())
        let sessionsThisWeek = allSessions.filter { 
            ScheduleManager.weekNumber(for: $0.date) == currentWeek && $0.status == .completed 
        }
        let countThisWeek = sessionsThisWeek.count + 1 // including this one being marked done
        
        if countThisWeek == 4 {
            earned.append(get("perfectWeek"))
        }
        
        let weeklyTarget = Int(goals.first(where: { $0.typeRaw == "weeklyWorkouts" })?.targetValue ?? 4.0)
        if countThisWeek == weeklyTarget {
            earned.append(get("consistencyKing"))
        }
        
        // 6. Recovery Master
        if session.dayNumber == 4 { earned.append(get("recoveryMaster")) }
        
        // 7. Volume Junkie
        let totalReps = logs.reduce(0) { $0 + ($1.sets * $1.reps) }
        if totalReps > 100 { earned.append(get("volumeJunkie")) }
        
        // 8. Heavy Lifter
        let maxWeight = logs.map { $0.weightLbs }.max() ?? 0
        if maxWeight >= 100 { earned.append(get("heavyLifter")) }
        
        // 9. Speed Demon
        let maxSpeedKmh = logs.compactMap { log -> Double? in
            guard log.distanceMeters > 0, log.durationSeconds > 0 else { return nil }
            return (Double(log.distanceMeters) / Double(log.durationSeconds)) * 3.6
        }.max() ?? 0
        if maxSpeedKmh >= 25.0 { earned.append(get("speedDemon")) }
        
        // 10. Distance Runner
        let totalDistance = logs.reduce(0) { $0 + $1.distanceMeters }
        if totalDistance >= 400 { earned.append(get("distanceRunner")) }
        
        // 11. Core Crusher
        let coreExercisesLogged = logs.filter { log in
            // Basic heuristic: check if the exercise name contains core-related keywords
            let n = log.exerciseName.lowercased()
            return n.contains("plank") || n.contains("crunch") || n.contains("bug") || n.contains("twist") || n.contains("chop") || n.contains("core")
        }.count
        if coreExercisesLogged >= 3 { earned.append(get("coreCrusher")) }
        
        // 12. The Finisher
        let totalPrescribed = session.workoutDay?.sections.reduce(0) { $0 + $1.exercises.filter { $0.logType != .none }.count } ?? 0
        if logs.count >= totalPrescribed && totalPrescribed > 0 {
            earned.append(get("theFinisher"))
        }
        
        // Automatically save to SwiftData
        let now = Date()
        for ach in earned {
            let record = AchievementRecord(achievementID: ach.id, earnedAt: now)
            context.insert(record)
        }
        
        return earned
    }
    
    static func get(_ id: String) -> AchievementDefinition {
        allAchievements.first(where: { $0.id == id })!
    }
}
