// ExerciseTutorialSheet.swift
// SpeedLabJr
//
// In-app YouTube tutorial browser for each exercise.
// Uses SFSafariViewController so the user gets full browser features,
// YouTube account, autoplay, etc. — without needing an API key.

import SwiftUI
import SafariServices

// MARK: - Safari wrapper

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled    = true
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor      = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
        vc.preferredControlTintColor  = .white
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - ExerciseTutorialSheet

struct ExerciseTutorialSheet: View {

    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss

    // Builds a focused YouTube search URL for the exercise
    private var tutorialURL: URL {
        let base    = exercise.name
        let section = exercise.section
        // Add context so results are sport-specific
        let context: String
        switch section {
        case "SPRINT DRILLS", "SPEED ENDURANCE RUNS", "PLYOMETRIC FINISHER":
            context = "track and field sprint drill"
        case "LOWER BODY STRENGTH", "CORE & STABILITY", "BALANCE & BODY CONTROL":
            context = "strength exercise form tutorial"
        case "MOBILITY FLOW", "COOL-DOWN":
            context = "flexibility stretch how to"
        default:
            context = "exercise tutorial for beginners"
        }
        let query = "\(base) \(context)"
            .lowercased()
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.youtube.com/results?search_query=\(query)")!
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header strip
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.name)
                            .font(.headline)
                        Text(exercise.prescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))

                Divider()

                // YouTube results
                SafariView(url: tutorialURL)
                    .ignoresSafeArea(edges: .bottom)
            }
            .navigationTitle("Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ExerciseTutorialSheet(exercise: WorkoutProgram.day1.sections[1].exercises[0])
}
