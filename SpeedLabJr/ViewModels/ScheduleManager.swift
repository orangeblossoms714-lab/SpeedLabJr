// ScheduleManager.swift
// SpeedLabJr
//
// Generates and manages the recurring 4-day weekly workout schedule.
// Stores the program start date in UserDefaults and pre-populates
// WorkoutSession records in SwiftData for the coming year.

import Foundation
import SwiftData

final class ScheduleManager {

    // MARK: - Constants

    static let startDateKey = "speedlab_start_date"
    static let weeksAhead   = 52   // generate a full year of sessions

    // MARK: - Start Date

    /// Returns the stored start date (nearest past Monday), or today's Monday if not set.
    static var programStartDate: Date {
        get {
            if let saved = UserDefaults.standard.object(forKey: startDateKey) as? Date {
                return saved
            }
            let monday = Self.mostRecentMonday(from: Date())
            UserDefaults.standard.set(monday, forKey: startDateKey)
            return monday
        }
        set {
            let monday = Self.mostRecentMonday(from: newValue)
            UserDefaults.standard.set(monday, forKey: startDateKey)
        }
    }

    /// Returns the most recent Monday on or before the given date.
    static func mostRecentMonday(from date: Date) -> Date {
        var cal = Calendar.current
        cal.firstWeekday = 2   // Monday
        let components = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: components) ?? date
    }

    // MARK: - Week Number

    /// 1-based week number since program start.
    static func weekNumber(for date: Date) -> Int {
        let start = Self.programStartDate
        let days  = Calendar.current.dateComponents([.day], from: start, to: date).day ?? 0
        return max(1, (days / 7) + 1)
    }

    // MARK: - Session Generation

    /// Ensures WorkoutSession records exist for all workout days in the coming year.
    /// Safe to call multiple times — skips dates that already have a session.
    @MainActor
    static func ensureSessionsExist(in context: ModelContext) {
        let startDate = programStartDate
        let calendar  = Calendar.current

        // Fetch all existing session dates to avoid duplicates
        let descriptor = FetchDescriptor<WorkoutSession>()
        let existing   = (try? context.fetch(descriptor)) ?? []
        let existingDates = Set(existing.map { $0.calendarDate })

        // Generate sessions for weeksAhead weeks
        for weekOffset in 0..<weeksAhead {
            guard let weekStart = calendar.date(
                byAdding: .weekOfYear, value: weekOffset, to: startDate
            ) else { continue }

            for (weekday, dayNumber) in WorkoutProgram.weeklySchedule {
                // weekday: 2=Mon, 4=Wed, 5=Thu, 7=Sat
                // Compute the actual date for this weekday in this week
                guard let sessionDate = dateForWeekday(weekday, inWeekOf: weekStart, calendar: calendar)
                else { continue }

                let startOfDay = calendar.startOfDay(for: sessionDate)

                // Skip if already in DB
                if existingDates.contains(startOfDay) { continue }

                let session = WorkoutSession(date: startOfDay, dayNumber: dayNumber)
                context.insert(session)
            }
        }

        try? context.save()
    }

    /// Returns the date for a given weekday (2=Mon…7=Sat) in the same week as `weekStart`.
    private static func dateForWeekday(_ weekday: Int, inWeekOf weekStart: Date, calendar: Calendar) -> Date? {
        // weekStart is always a Monday (weekday=2)
        // offset from Monday: Mon=0, Tue=1, Wed=2, Thu=3, Fri=4, Sat=5, Sun=6
        let offsets: [Int: Int] = [2: 0, 3: 1, 4: 2, 5: 3, 6: 4, 7: 5, 1: 6]
        guard let offset = offsets[weekday] else { return nil }
        return calendar.date(byAdding: .day, value: offset, to: weekStart)
    }

    // MARK: - Convenience Queries

    /// Sessions for a specific calendar month.
    static func sessions(in month: Date, from all: [WorkoutSession]) -> [WorkoutSession] {
        let cal = Calendar.current
        return all.filter {
            cal.isDate($0.date, equalTo: month, toGranularity: .month)
        }
    }

    /// Session for a specific calendar date (if any).
    static func session(on date: Date, from all: [WorkoutSession]) -> WorkoutSession? {
        let cal = Calendar.current
        return all.first { cal.isDate($0.date, inSameDayAs: date) }
    }

    /// Today's session (if any).
    static func todaySession(from all: [WorkoutSession]) -> WorkoutSession? {
        session(on: Date(), from: all)
    }

    /// Next upcoming session on or after today.
    static func nextSession(from all: [WorkoutSession]) -> WorkoutSession? {
        let today = Calendar.current.startOfDay(for: Date())
        return all
            .filter { $0.calendarDate >= today && $0.status == .upcoming }
            .sorted { $0.date < $1.date }
            .first
    }

    // MARK: - Stats

    struct WeeklyStats {
        let weekNumber: Int
        let startDate: Date
        let completed: Int
        let skipped: Int
        let total: Int
    }

    static func weeklyStats(from all: [WorkoutSession]) -> [WeeklyStats] {
        let start = programStartDate
        let cal   = Calendar.current
        var stats: [WeeklyStats] = []

        for week in 0..<weeksAhead {
            guard let weekStart = cal.date(byAdding: .weekOfYear, value: week, to: start) else { continue }
            guard let weekEnd   = cal.date(byAdding: .weekOfYear, value: 1, to: weekStart) else { continue }

            // Only include weeks that have any sessions
            let weekSessions = all.filter { $0.date >= weekStart && $0.date < weekEnd }
            guard !weekSessions.isEmpty else { continue }

            // Don't include future weeks beyond today
            if weekStart > Date() { break }

            stats.append(WeeklyStats(
                weekNumber: week + 1,
                startDate: weekStart,
                completed: weekSessions.filter { $0.status == .completed }.count,
                skipped: weekSessions.filter { $0.status == .skipped }.count,
                total: weekSessions.count
            ))
        }

        return stats
    }

    // MARK: - Gamification (Streaks)

    /// Calculates the current weekly consistency streak based on the target weekly goal.
    static func currentStreak(from all: [WorkoutSession], goals: [UserGoal]) -> Int {
        let weeklyTarget = Int(goals.first(where: { $0.typeRaw == "weeklyWorkouts" })?.targetValue ?? 4.0)
        
        let stats = weeklyStats(from: all).sorted { $0.weekNumber > $1.weekNumber }
        let currentWeek = weekNumber(for: Date())
        
        var streak = 0
        for w in stats {
            if w.completed >= weeklyTarget {
                streak += 1
            } else if w.weekNumber == currentWeek {
                // If it's the current week and not met yet, it doesn't break the streak (week isn't over!)
                continue
            } else {
                // A past week was missed. Streak broken!
                break
            }
        }
        return streak
    }
}
