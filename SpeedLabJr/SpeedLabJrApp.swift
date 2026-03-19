// SpeedLabJrApp.swift
// SpeedLabJr

import SwiftUI
import SwiftData

@main
struct SpeedLabJrApp: App {

    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: WorkoutSession.self, ExerciseLog.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Pre-generate workout sessions on first launch and on each app open
                    ScheduleManager.ensureSessionsExist(in: container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
