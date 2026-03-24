// ExerciseTutorialSheet.swift
// SpeedLabJr
//
// In-app visual and text tutorials for exercises.

import SwiftUI

// MARK: - ExerciseTutorialSheet

struct ExerciseTutorialSheet: View {

    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header strip
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: "figure.run")
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

                ScrollView {
                    let tutorial = TutorialDatabase.tutorial(for: exercise.name)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        if !tutorial.images.isEmpty {
                            TabView {
                                ForEach(tutorial.images, id: \.self) { imgName in
                                    Image(imgName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 280)
                                        .padding()
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .always))
                            .frame(height: 280)
                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                                .frame(height: 180)
                                .overlay(
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.largeTitle)
                                            .foregroundStyle(.tertiary)
                                        Text("Visual sequence coming soon")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Execution")
                                .font(.headline)
                            
                            // Handling instructions and bold focus cleanly
                            let blocks = tutorial.instructions.components(separatedBy: "\n\n")
                            ForEach(blocks, id: \.self) { block in
                                if block.isEmpty {
                                    EmptyView()
                                } else if block.hasPrefix("**Focus:**") {
                                    Text(block.replacingOccurrences(of: "**Focus:** ", with: "🎯 Focus: "))
                                        .font(.subheadline).bold()
                                        .foregroundColor(.orange)
                                        .padding(.top, 4)
                                } else {
                                    Text(block)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineSpacing(4)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
