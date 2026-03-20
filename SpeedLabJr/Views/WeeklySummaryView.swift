// WeeklySummaryView.swift
// SpeedLabJr
//
// Weekly progress celebration screen — shows completion ring, streak,
// personal bests set this week, and a tiered encouragement message.

import SwiftUI
import SwiftData

struct WeeklySummaryView: View {

    @Query(sort: \WorkoutSession.date)  private var sessions: [WorkoutSession]
    @Query(sort: \ExerciseLog.loggedAt) private var allLogs: [ExerciseLog]

    @State private var ringProgress: Double = 0  // animated 0→actual

    private let calendar = Calendar.current

    // MARK: - Current week data

    private var weekStart: Date { ScheduleManager.mostRecentMonday(from: Date()) }
    private var weekEnd: Date   { calendar.date(byAdding: .day, value: 7, to: weekStart)! }
    private var weekNumber: Int { ScheduleManager.weekNumber(for: Date()) }

    private var thisWeekSessions: [WorkoutSession] {
        sessions.filter { $0.date >= weekStart && $0.date < weekEnd }
    }
    private var completedCount: Int { thisWeekSessions.filter { $0.status == .completed }.count }
    private var skippedCount:   Int { thisWeekSessions.filter { $0.status == .skipped  }.count }
    private var totalCount:     Int { thisWeekSessions.count }
    private var completionRate: Double {
        totalCount == 0 ? 0 : Double(completedCount) / Double(totalCount)
    }

    // MARK: - Streak (consecutive weeks with ≥3 completions)

    private var streakWeeks: Int {
        let stats = ScheduleManager.weeklyStats(from: sessions)
        var streak = 0
        for week in stats.reversed() {
            if week.completed >= 3 { streak += 1 } else { break }
        }
        return streak
    }

    // MARK: - PRs set this week

    private var thisWeekLogs: [ExerciseLog] {
        allLogs.filter { $0.loggedAt >= weekStart && $0.loggedAt < weekEnd }
    }

    struct PRItem: Identifiable {
        let id = UUID()
        let exerciseName: String
        let value: Double
        let label: String
        let emoji: String
    }

    private var newPRs: [PRItem] {
        var prs: [PRItem] = []
        let exerciseNames = Set(thisWeekLogs.map { $0.exerciseName })
        for name in exerciseNames {
            let allForExercise  = allLogs.filter { $0.exerciseName == name }
            let thisWeekForEx   = thisWeekLogs.filter { $0.exerciseName == name }
            guard let weekBest  = thisWeekForEx.max(by: { $0.chartValue < $1.chartValue }),
                  let allTimeBest = allForExercise.max(by: { $0.chartValue < $1.chartValue }),
                  weekBest.chartValue >= allTimeBest.chartValue,
                  weekBest.chartValue > 0
            else { continue }
            prs.append(PRItem(
                exerciseName: name,
                value: weekBest.chartValue,
                label: weekBest.chartLabel,
                emoji: prEmoji(for: name)
            ))
        }
        return prs
    }

    private func prEmoji(for exerciseName: String) -> String {
        if exerciseName.lowercased().contains("plank")  { return "🏋️" }
        if exerciseName.lowercased().contains("sprint") { return "⚡️" }
        if exerciseName.lowercased().contains("squat")  { return "🦵" }
        if exerciseName.lowercased().contains("jump")   { return "🦘" }
        if exerciseName.lowercased().contains("lunge")  { return "🏃" }
        return "🏆"
    }

    // MARK: - Encouragement tier

    private struct EncouragementTier {
        let headline: String
        let body: String
        let emoji: String
        let color: Color
    }

    private var encouragement: EncouragementTier {
        switch completedCount {
        case 4:
            return EncouragementTier(
                headline: "Perfect Week!",
                body: "You hit every single workout this week. That's elite-level consistency — your future self will thank you.",
                emoji: "🎉",
                color: .green
            )
        case 3:
            return EncouragementTier(
                headline: "Solid Week!",
                body: "3 out of 4 — that's a great week. One skip doesn't define you. Keep the momentum going.",
                emoji: "💪",
                color: .orange
            )
        case 2:
            return EncouragementTier(
                headline: "Getting There!",
                body: "Two workouts in the bank. Speed is built over many weeks — show up a little more next week and you'll feel the difference.",
                emoji: "🌱",
                color: .yellow
            )
        case 1:
            return EncouragementTier(
                headline: "You Showed Up!",
                body: "One workout is infinitely better than zero. Every champion has tough weeks. Come back stronger.",
                emoji: "🌟",
                color: .blue
            )
        default:
            return EncouragementTier(
                headline: "Rest Week",
                body: "Sometimes the body needs a full reset. Hydrate, sleep well, and come back fresh. You've got this.",
                emoji: "😴",
                color: .purple
            )
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    weekHeader
                    completionRingCard
                    encouragementCard
                    statsRow
                    if !newPRs.isEmpty { personalBestsCard }
                    phaseCard
                    tipsCard
                }
                .padding()
                .padding(.bottom, 24)
            }
            .navigationTitle("This Week")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                ringProgress = completionRate
            }
        }
        .onChange(of: completedCount) { _, _ in
            withAnimation(.easeOut(duration: 0.6)) {
                ringProgress = completionRate
            }
        }
    }

    // MARK: - Subviews

    private var weekHeader: some View {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        let range = "\(fmt.string(from: weekStart)) – \(fmt.string(from: calendar.date(byAdding: .day, value: 6, to: weekStart)!))"
        return VStack(alignment: .leading, spacing: 2) {
            Text("WEEK \(weekNumber)")
                .font(.caption.weight(.bold))
                .foregroundColor(.secondary)
                .tracking(1.5)
            Text(range)
                .font(.title3.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var completionRingCard: some View {
        HStack(spacing: 24) {
            // Animated ring
            ZStack {
                Circle()
                    .stroke(Color(.systemFill), lineWidth: 14)
                    .frame(width: 110, height: 110)

                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        AngularGradient(
                            colors: [encouragement.color, encouragement.color.opacity(0.6)],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(completedCount)/\(totalCount)")
                        .font(.title2.weight(.bold))
                    Text("done")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(thisWeekSessions.sorted { $0.date < $1.date }) { session in
                    HStack(spacing: 8) {
                        Image(systemName: session.status.icon)
                            .foregroundColor(statusColor(session.status))
                            .font(.subheadline)
                            .frame(width: 20)
                        Text("Day \(session.dayNumber) — \(session.title)")
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
                if thisWeekSessions.isEmpty {
                    Text("No workouts scheduled yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var encouragementCard: some View {
        let tier = encouragement
        return HStack(alignment: .top, spacing: 14) {
            Text(tier.emoji)
                .font(.system(size: 40))
            VStack(alignment: .leading, spacing: 4) {
                Text(tier.headline)
                    .font(.headline)
                    .foregroundColor(tier.color)
                Text(tier.body)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tier.color.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(tier.color.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            MiniStatCard(value: "\(streakWeeks)", label: "Week Streak", icon: "flame.fill", color: .orange)
            MiniStatCard(value: "\(skippedCount)", label: "Skipped", icon: "xmark.circle", color: .gray)
            MiniStatCard(value: "\(newPRs.count)", label: "New PRs", icon: "trophy.fill", color: .yellow)
        }
    }

    @ViewBuilder
    private var personalBestsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Personal Bests This Week", systemImage: "trophy.fill")
                .font(.headline)
                .foregroundColor(.yellow)

            ForEach(newPRs) { pr in
                HStack {
                    Text(pr.emoji)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(pr.exerciseName)
                            .font(.subheadline.weight(.medium))
                        Text("\(Int(pr.value)) \(pr.label.lowercased())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("NEW PR 🎯")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.yellow.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var phaseCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title3)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("Training Phase")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)
                Text(WorkoutProgram.phase(for: weekNumber))
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var tipsCard: some View {
        let tips = weeklyTips(for: weekNumber)
        return VStack(alignment: .leading, spacing: 10) {
            Label("Coach's Tip This Week", systemImage: "person.fill.checkmark")
                .font(.subheadline.weight(.bold))
                .foregroundColor(.orange)
            Text(tips)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Helpers

    private func statusColor(_ status: WorkoutStatus) -> Color {
        switch status {
        case .completed: return .green
        case .skipped:   return .gray
        case .upcoming:  return .orange
        }
    }

    private func weeklyTips(for week: Int) -> String {
        let tips = [
            "Focus on your form this week — slow down the A-Skips and really drive that knee.",
            "Add 1–2 reps to your squats and lunges compared to last week. Small gains compound fast.",
            "On your sprint days, focus on your arm drive — your legs will follow where your arms lead.",
            "Rest is training too. Make sure you're sleeping 8–10 hours to let your muscles repair.",
            "Try closing your eyes during the single-leg balance today — you'll feel the difference.",
            "Acceleration Sprints: lean forward like you're about to fall, then explode. Trust the lean.",
            "Your plank time should be creeping up by now. Add 5 seconds each session.",
            "Stay hydrated — even mild dehydration slows your sprint times by measurable amounts.",
        ]
        return tips[(week - 1) % tips.count]
    }
}

// MARK: - MiniStatCard

struct MiniStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
            Text(value)
                .font(.title3.weight(.bold))
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    WeeklySummaryView()
        .modelContainer(for: [WorkoutSession.self, ExerciseLog.self], inMemory: true)
}
