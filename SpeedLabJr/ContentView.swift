// ContentView.swift
// SpeedLabJr

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            TodayView()
                .tabItem {
                    Label("Today", systemImage: "bolt.fill")
                }

            WeeklySummaryView()
                .tabItem {
                    Label("This Week", systemImage: "star.circle.fill")
                }

            ProgressChartsView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WorkoutSession.self, ExerciseLog.self, UserGoal.self],
                        inMemory: true)
}
