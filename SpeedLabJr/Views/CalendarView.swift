// CalendarView.swift
// SpeedLabJr
//
// Monthly calendar showing upcoming workouts with status badges.

import SwiftUI
import SwiftData

struct CalendarView: View {

    @Query(sort: \WorkoutSession.date) private var sessions: [WorkoutSession]
    @State private var displayedMonth: Date = Calendar.current.startOfDay(for: Date())
    @State private var selectedSession: WorkoutSession?

    private let calendar = Calendar.current
    private let columns  = Array(repeating: GridItem(.flexible()), count: 7)
    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // MARK: - Month math

    private var monthStart: Date {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        return calendar.date(from: comps)!
    }

    private var monthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: monthStart)
    }

    /// All calendar cells for the grid (including leading/trailing blanks).
    private var gridDates: [Date?] {
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        // Convert Sunday-based (1=Sun) to Monday-based (0=Mon)
        let leadingBlanks = (firstWeekday + 5) % 7

        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)!.count

        var dates: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in 1...daysInMonth {
            var comps = calendar.dateComponents([.year, .month], from: monthStart)
            comps.day = day
            dates.append(calendar.date(from: comps))
        }
        // Pad to complete final row
        while dates.count % 7 != 0 { dates.append(nil) }
        return dates
    }

    private func session(on date: Date) -> WorkoutSession? {
        ScheduleManager.session(on: date, from: sessions)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    monthHeader
                    dayNameRow
                    calendarGrid
                    legend
                        .padding(.top, 12)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedSession) { session in
                WorkoutDetailView(session: session)
            }
        }
    }

    // MARK: - Subviews

    private var monthHeader: some View {
        HStack {
            Button { changeMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.orange)
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Text(monthTitle)
                .font(.title3.weight(.bold))
            Spacer()
            Button { changeMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.orange)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.vertical, 12)
    }

    private var dayNameRow: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(dayNames, id: \.self) { name in
                Text(name)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 4)
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(gridDates.enumerated()), id: \.offset) { _, date in
                if let date = date {
                    CalendarDayCell(
                        date: date,
                        session: session(on: date),
                        isToday: calendar.isDateInToday(date)
                    )
                    .onTapGesture {
                        if let s = session(on: date) {
                            selectedSession = s
                        }
                    }
                } else {
                    Color.clear
                        .frame(height: 52)
                }
            }
        }
    }

    private var legend: some View {
        HStack(spacing: 16) {
            LegendItem(color: .orange,  label: "Speed")
            LegendItem(color: .blue,    label: "Strength")
            LegendItem(color: .green,   label: "Endurance")
            LegendItem(color: .purple,  label: "Recovery")
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func changeMonth(by offset: Int) {
        guard let newDate = calendar.date(
            byAdding: .month, value: offset, to: displayedMonth
        ) else { return }
        displayedMonth = newDate
    }
}

// MARK: - CalendarDayCell

struct CalendarDayCell: View {

    let date: Date
    let session: WorkoutSession?
    let isToday: Bool

    private let calendar = Calendar.current

    private var isPast: Bool { date < Calendar.current.startOfDay(for: Date()) && !isToday }
    private var isFuture: Bool { date > Date() }

    var body: some View {
        VStack(spacing: 3) {
            // Day number
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 28, height: 28)
                }
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .bold : .regular))
                    .foregroundColor(isToday ? .white : (isPast ? .secondary : .primary))
            }

            // Workout indicator
            if let session = session {
                workoutIndicator(for: session)
            } else {
                Spacer().frame(height: 18)
            }
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundFill)
        )
    }

    @ViewBuilder
    private func workoutIndicator(for session: WorkoutSession) -> some View {
        let color = session.workoutDay?.color ?? .orange

        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(badgeFill(status: session.status, color: color))
                .frame(height: 18)

            HStack(spacing: 2) {
                if session.status == .completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                } else if session.status == .skipped {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text(session.emoji)
                        .font(.system(size: 10))
                }
            }
        }
    }

    private func badgeFill(status: WorkoutStatus, color: Color) -> Color {
        switch status {
        case .completed: return .green
        case .skipped:   return .gray
        case .upcoming:  return isPast ? color.opacity(0.4) : color
        }
    }

    private var backgroundFill: Color {
        if isToday { return Color.orange.opacity(0.08) }
        return Color.clear
    }
}

// MARK: - LegendItem

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 14, height: 10)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [WorkoutSession.self, ExerciseLog.self], inMemory: true)
}
