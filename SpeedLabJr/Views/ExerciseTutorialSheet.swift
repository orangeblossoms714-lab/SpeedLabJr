// ExerciseTutorialSheet.swift
// SpeedLabJr
//
// In-app Video player for AI generated exercise tutorials.

import SwiftUI
import AVKit

// MARK: - ExerciseTutorialSheet

struct ExerciseTutorialSheet: View {

    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    
    // Auto-playing looping video player
    @State private var player: AVPlayer?

    private func setupPlayer() {
        let filename = exercise.name.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "+", with: "and")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "---", with: "-")
            .replacingOccurrences(of: "--", with: "-")
        
        if let url = Bundle.main.url(forResource: filename, withExtension: "mp4") {
            let p = AVPlayer(url: url)
            p.actionAtItemEnd = .none // loop
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: p.currentItem, queue: .main) { _ in
                p.seek(to: .zero)
                p.play()
            }
            player = p
            p.play()
        } else {
            print("Video not found: \(filename).mp4")
        }
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

                // Embedded Video Player
                if let player = player {
                    VideoPlayer(player: player)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    VStack {
                        Spacer()
                        Image(systemName: "video.slash")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Video tutorial not available.")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                setupPlayer()
            }
            .onDisappear {
                player?.pause()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ExerciseTutorialSheet(exercise: WorkoutProgram.day1.sections[1].exercises[0])
}
