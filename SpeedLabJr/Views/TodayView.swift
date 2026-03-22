// TodayView.swift
// SpeedLabJr
//
// Hero "Today" screen showing today's workout or the next upcoming one.

import SwiftUI
import SwiftData

struct TodayView: View {

    @Query(sort: \WorkoutSession.date) private var sessions: [WorkoutSession]
    @Query private var goals: [UserGoal]
    @Query(sort: \AchievementRecord.earnedAt, order: .reverse) private var recentAchievements: [AchievementRecord]
    
    @State private var showWorkout = false
    @State private var showSkipConfirm = false
    @State private var showMarkDoneConfirm = false

    private var todaySession: WorkoutSession? {
        ScheduleManager.todaySession(from: sessions)
    }

    private var nextSession: WorkoutSession? {
        ScheduleManager.nextSession(from: sessions)
    }

    private var displaySession: WorkoutSession? {
        todaySession ?? nextSession
    }

    private var isToday: Bool {
        guard let s = displaySession else { return false }
        return Calendar.current.isDateInToday(s.date)
    }
    
    private var thisWeeksAchievements: [AchievementRecord] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return recentAchievements.filter { $0.earnedAt >= oneWeekAgo }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    dateHeader
                    if let session = displaySession {
                        heroCard(session: session)
                        if session.status == .upcoming {
                            actionButtons(session: session)
                        }
                        exercisePreview(session: session)
                        if isToday {
                            programPhaseCard
                        }
                        thisWeekTrophies
                    } else {
                        emptyState
                    }
                }
                .padding()
            }
            .navigationTitle("Speed Lab Jr.")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showWorkout) {
                if let session = displaySession {
                    WorkoutDetailView(session: session)
                }
            }
            .confirmationDialog("Skip this workout?", isPresented: $showSkipConfirm, titleVisibility: .visible) {
                Button("Skip Workout", role: .destructive) {
                    displaySession?.status = .skipped
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    // MARK: - Subviews

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(isToday ? "TODAY" : "NEXT WORKOUT")
                .font(.caption.weight(.bold))
                .foregroundColor(.secondary)
                .tracking(1.5)
            Text(displaySession?.date.formatted(date: .complete, time: .omitted) ?? Date().formatted(date: .complete, time: .omitted))
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func heroCard(session: WorkoutSession) -> some View {
        let color = session.workoutDay?.color ?? .orange

        ZStack(alignment: .bottomLeading) {
            // Background gradient
            LinearGradient(
                colors: [color, color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(maxWidth: .infinity)
            .frame(height: 180)

            // Status banner
            if session.status != .upcoming {
                statusBanner(status: session.status)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("DAY \(session.dayNumber)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(1.5)
                    Spacer()
                    Text("\(session.durationMinutes) min")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                Text(session.emoji + " " + session.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                Text(session.workoutDay?.subtitle ?? "")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(20)
        }
        .onTapGesture { showWorkout = true }
    }

    @ViewBuilder
    private func statusBanner(status: WorkoutStatus) -> some View {
        HStack {
            Spacer()
            Label(status.label, systemImage: status.icon)
                .font(.caption.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    status == .completed ? Color.green.opacity(0.85) : Color.gray.opacity(0.85)
                )
                .clipShape(Capsule())
                .padding(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }

    @ViewBuilder
    private func actionButtons(session: WorkoutSession) -> some View {
        HStack(spacing: 12) {
            // Start / View Workout
            Button {
                showWorkout = true
            } label: {
                Label(isToday ? "Start Workout" : "View Workout", systemImage: "play.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(session.workoutDay?.color ?? .orange)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // Skip
            if isToday {
                Button {
                    showSkipConfirm = true
                } label: {
                    Label("Skip", systemImage: "forward.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 90, height: 50)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    @ViewBuilder
    private func exercisePreview(session: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EXERCISES")
                .font(.caption.weight(.bold))
                .foregroundColor(.secondary)
                .tracking(1.5)

            ForEach(session.workoutDay?.sections ?? []) { section in
                VStack(alignment: .leading, spacing: 6) {
                    Text(section.name)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.orange)

                    ForEach(section.exercises) { exercise in
                        HStack {
                            Image(systemName: exercise.logType == .none ? "circle" : "dumbbell")
                                .font(.caption)
                                .foregroundColor(exercise.logType == .none ? .secondary : (session.workoutDay?.color ?? .orange))
                                .frame(width: 18)
                            Text(exercise.name)
                                .font(.subheadline)
                            Spacer()
                            Text(exercise.prescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var programPhaseCard: some View {
        let week = ScheduleManager.weekNumber(for: Date())
        let streak = ScheduleManager.currentStreak(from: sessions, goals: goals)
        
        return HStack(spacing: 12) {
            Image(systemName: "flag.fill")
                .font(.title3)
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Week \(week)")
                    .font(.subheadline.weight(.bold))
                Text(WorkoutProgram.phase(for: week))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            if streak > 0 {
                HStack(spacing: 4) {
                    Text("🔥")
                    Text("\(streak) Week\(streak == 1 ? "" : "s")")
                        .font(.footnote.weight(.bold))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder
    private var thisWeekTrophies: some View {
        let weekly = thisWeeksAchievements
        if !weekly.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("THIS WEEK'S TROPHIES")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(weekly) { record in
                            let def = AchievementEngine.get(record.achievementID)
                            VStack(spacing: 6) {
                                Text(def.emoji)
                                    .font(.system(size: 32))
                                    .frame(width: 60, height: 60)
                                    .background(Color.yellow.opacity(0.2))
                                    .clipShape(Circle())
                                
                                Text(def.name)
                                    .font(.caption2.weight(.bold))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(width: 70)
                            }
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundColor(.green)
            Text("All caught up!")
                .font(.title2.weight(.bold))
            Text("No upcoming workouts found. Your schedule will appear here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [WorkoutSession.self, ExerciseLog.self], inMemory: true)
}
