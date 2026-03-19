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

            ProgressChartsView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WorkoutSession.self, ExerciseLog.self],
                        inMemory: true)
}
