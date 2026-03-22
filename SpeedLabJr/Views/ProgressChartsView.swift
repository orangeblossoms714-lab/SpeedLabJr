// ProgressChartsView.swift
// SpeedLabJr
//
// Charts showing workout completion rates and exercise-specific progress over time.

import SwiftUI
import SwiftData
import Charts

struct ProgressChartsView: View {

    @Query(sort: \WorkoutSession.date)  private var sessions: [WorkoutSession]
    @Query(sort: \ExerciseLog.loggedAt) private var allLogs: [ExerciseLog]
    @Query private var allGoals: [UserGoal]

    @State private var selectedDay: Int = 0  // 0 = all days
    @State private var selectedExercise: String = ""

    // MARK: - Computed data

    private var weeklyStats: [ScheduleManager.WeeklyStats] {
        ScheduleManager.weeklyStats(from: sessions)
    }
    
    private var weeklyTarget: Double {
        allGoals.first(where: { $0.typeRaw == "weeklyWorkouts" })?.targetValue ?? 4.0
    }
    
    private var exerciseTarget: Double? {
        allGoals.first(where: { $0.typeRaw == "exerciseTarget" && $0.exerciseName == selectedExercise })?.targetValue
    }

    private var completedSessions: [WorkoutSession] {
        sessions.filter { $0.status == .completed }
    }

    /// All exercises that have at least one log entry (filterable by day)
    private var loggedExercises: [String] {
        let relevant = selectedDay == 0
            ? allLogs
            : allLogs.filter { $0.dayNumber == selectedDay }
        let names = relevant.map { $0.exerciseName }
        return Array(Set(names)).sorted()
    }

    private var logsForSelectedExercise: [ExerciseLog] {
        allLogs.filter { $0.exerciseName == selectedExercise }
               .sorted { $0.loggedAt < $1.loggedAt }
    }

    private var overallCompletionRate: Double {
        let past = sessions.filter { $0.calendarDate <= Calendar.current.startOfDay(for: Date()) }
        guard !past.isEmpty else { return 0 }
        return Double(past.filter { $0.status == .completed }.count) / Double(past.count) * 100
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    summaryCards
                    weeklyCompletionChart
                    exercisePickerSection
                    if !selectedExercise.isEmpty && !logsForSelectedExercise.isEmpty {
                        exerciseProgressChart
                    } else if !selectedExercise.isEmpty {
                        noDataCard
                    }
                }
                .padding()
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if selectedExercise.isEmpty, let first = loggedExercises.first {
                selectedExercise = first
            }
        }
        .onChange(of: loggedExercises) { _, newVal in
            if !newVal.contains(selectedExercise), let first = newVal.first {
                selectedExercise = first
            }
        }
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                value: "\(completedSessions.count)",
                label: "Done",
                icon: "checkmark.circle.fill",
                color: .green
            )
            StatCard(
                value: String(format: "%.0f%%", overallCompletionRate),
                label: "Rate",
                icon: "chart.line.uptrend.xyaxis",
                color: .orange
            )
            StatCard(
                value: "\(ScheduleManager.weekNumber(for: Date()))",
                label: "Week",
                icon: "flag.fill",
                color: .blue
            )
        }
    }

    // MARK: - Weekly Completion Chart

    private var weeklyCompletionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Weekly Completion", subtitle: "Workouts done per week")

            if weeklyStats.isEmpty {
                placeholderChart(message: "Complete some workouts to see weekly stats")
            } else {
                Chart {
                    ForEach(weeklyStats, id: \.weekNumber) { week in
                        BarMark(
                            x: .value("Week", "Wk \(week.weekNumber)"),
                            y: .value("Completed", week.completed)
                        )
                        .foregroundStyle(Color.green.gradient)
                        .cornerRadius(4)

                        BarMark(
                            x: .value("Week", "Wk \(week.weekNumber)"),
                            y: .value("Skipped", week.skipped)
                        )
                        .foregroundStyle(Color.gray.opacity(0.4).gradient)
                        .cornerRadius(4)
                    }

                    // Target line
                    RuleMark(y: .value("Target", weeklyTarget))
                        .foregroundStyle(Color.orange.opacity(0.6))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                        .annotation(position: .trailing) {
                            Text("Goal")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                }
                .chartYScale(domain: 0...5)
                .chartLegend(position: .bottom, alignment: .leading) {
                    HStack(spacing: 12) {
                        legendDot(color: .green, label: "Completed")
                        legendDot(color: .gray.opacity(0.5), label: "Skipped")
                    }
                    .font(.caption)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Exercise Picker

    private var exercisePickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Exercise Progress", subtitle: "Track your strength & sprint gains")

            // Day filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    DayFilterChip(label: "All", dayNumber: 0, selected: $selectedDay)
                    DayFilterChip(label: "⚡️ Day 1", dayNumber: 1, selected: $selectedDay)
                    DayFilterChip(label: "🛡️ Day 2", dayNumber: 2, selected: $selectedDay)
                    DayFilterChip(label: "🏃 Day 3", dayNumber: 3, selected: $selectedDay)
                    DayFilterChip(label: "🧘 Day 4", dayNumber: 4, selected: $selectedDay)
                }
                .padding(.horizontal, 2)
            }

            if loggedExercises.isEmpty {
                Text("No logged exercises yet. Log some exercises during your workouts!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                // Exercise picker
                Menu {
                    ForEach(loggedExercises, id: \.self) { name in
                        Button(name) { selectedExercise = name }
                    }
                } label: {
                    HStack {
                        Text(selectedExercise.isEmpty ? "Select an exercise" : selectedExercise)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Exercise Progress Chart

    private var exerciseProgressChart: some View {
        let logs  = logsForSelectedExercise
        let label = logs.first?.chartLabel ?? "Value"

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: selectedExercise,
                subtitle: "\(logs.count) session\(logs.count == 1 ? "" : "s") logged"
            )

            Chart {
                ForEach(logs, id: \.id) { log in
                    LineMark(
                        x: .value("Date", log.loggedAt),
                        y: .value(label, log.chartValue)
                    )
                    .foregroundStyle(Color.orange.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))

                    PointMark(
                        x: .value("Date", log.loggedAt),
                        y: .value(label, log.chartValue)
                    )
                    .foregroundStyle(Color.orange)
                    .symbolSize(60)

                    AreaMark(
                        x: .value("Date", log.loggedAt),
                        yStart: .value("Base", 0),
                        yEnd: .value(label, log.chartValue)
                    )
                    .foregroundStyle(Color.orange.opacity(0.12).gradient)
                }
                
                if let target = exerciseTarget {
                    RuleMark(y: .value("Goal", target))
                        .foregroundStyle(Color.blue.opacity(0.8))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Target")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxisLabel(label)
            .frame(height: 200)

            // Personal best callout
            if let best = logs.max(by: { $0.chartValue < $1.chartValue }) {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Personal Best")
                            .font(.caption.weight(.bold))
                        Text("\(Int(best.chartValue)) \(label.lowercased()) on \(best.loggedAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private var noDataCard: some View {
        placeholderChart(message: "No logs yet for \(selectedExercise). Log this exercise during a workout!")
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func placeholderChart(message: String) -> some View {
        HStack {
            Image(systemName: "chart.xyaxis.line")
                .foregroundColor(.secondary.opacity(0.4))
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
        }
    }
}

// MARK: - StatCard

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title2.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - SectionHeader

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - DayFilterChip

struct DayFilterChip: View {
    let label: String
    let dayNumber: Int
    @Binding var selected: Int

    var body: some View {
        Button {
            selected = dayNumber
        } label: {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundColor(selected == dayNumber ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(selected == dayNumber ? Color.orange : Color(.tertiarySystemBackground))
                .clipShape(Capsule())
        }
    }
}

#Preview {
    ProgressChartsView()
        .modelContainer(for: [WorkoutSession.self, ExerciseLog.self, UserGoal.self], inMemory: true)
}
