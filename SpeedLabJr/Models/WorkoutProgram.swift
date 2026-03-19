// WorkoutProgram.swift
// SpeedLabJr
//
// Static data defining the Speed Lab Jr. 4-day workout program.

import SwiftUI

// MARK: - Log Type

enum LogType: String, Codable {
    case setsAndReps      // strength exercises (squats, lunges, etc.)
    case setsAndTime      // timed holds (planks, stretches)
    case setsAndDistance  // sprint/drill distances
    case none             // warm-up/cool-down — no logging needed
}

// MARK: - Exercise

struct Exercise: Identifiable {
    let id: UUID = UUID()
    let name: String
    let prescription: String   // e.g. "3 x 20m", "30 sec each leg"
    let coachNote: String
    let section: String
    let logType: LogType
    let defaultSets: Int
    let defaultReps: Int       // 0 if not applicable
    let defaultSeconds: Int    // 0 if not applicable
}

// MARK: - WorkoutSection

struct WorkoutSection: Identifiable {
    let id: UUID = UUID()
    let name: String
    let durationMinutes: Int
    let exercises: [Exercise]
}

// MARK: - WorkoutDay

struct WorkoutDay: Identifiable {
    let id: Int              // 1–4
    let title: String
    let subtitle: String
    let emoji: String
    let durationMinutes: Int
    let color: Color
    let sections: [WorkoutSection]

    var allExercises: [Exercise] {
        sections.flatMap { $0.exercises }
    }

    var loggableExercises: [Exercise] {
        allExercises.filter { $0.logType != .none }
    }
}

// MARK: - Static Program Data

struct WorkoutProgram {

    static let days: [WorkoutDay] = [day1, day2, day3, day4]

    static func day(for number: Int) -> WorkoutDay? {
        days.first { $0.id == number }
    }

    // -------------------------------------------------------------------------
    // DAY 1 — Speed & Explosion
    // -------------------------------------------------------------------------
    static let day1 = WorkoutDay(
        id: 1,
        title: "Speed & Explosion",
        subtitle: "Sprint mechanics · Fast-twitch muscle · Explosive power",
        emoji: "⚡️",
        durationMinutes: 25,
        color: .orange,
        sections: [
            WorkoutSection(name: "DYNAMIC WARM-UP", durationMinutes: 5, exercises: [
                Exercise(name: "Leg Swings (front/back)",
                         prescription: "10 each leg",
                         coachNote: "Hold wall for balance",
                         section: "DYNAMIC WARM-UP",
                         logType: .none,
                         defaultSets: 1, defaultReps: 10, defaultSeconds: 0),
                Exercise(name: "Hip Circles",
                         prescription: "10 each direction",
                         coachNote: "Loosen up the hips",
                         section: "DYNAMIC WARM-UP",
                         logType: .none,
                         defaultSets: 1, defaultReps: 10, defaultSeconds: 0),
                Exercise(name: "High Knees",
                         prescription: "20m down, walk back",
                         coachNote: "Slow & controlled",
                         section: "DYNAMIC WARM-UP",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 0),
                Exercise(name: "Butt Kicks",
                         prescription: "20m down, walk back",
                         coachNote: "Light and bouncy",
                         section: "DYNAMIC WARM-UP",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 0),
            ]),
            WorkoutSection(name: "SPRINT DRILLS", durationMinutes: 12, exercises: [
                Exercise(name: "A-Skips",
                         prescription: "3 × 20m",
                         coachNote: "Drive knee up, opposite arm swings",
                         section: "SPRINT DRILLS",
                         logType: .setsAndDistance,
                         defaultSets: 3, defaultReps: 0, defaultSeconds: 0),
                Exercise(name: "B-Skips",
                         prescription: "3 × 20m",
                         coachNote: "Extend leg out at top of skip",
                         section: "SPRINT DRILLS",
                         logType: .setsAndDistance,
                         defaultSets: 3, defaultReps: 0, defaultSeconds: 0),
                Exercise(name: "Falling Starts",
                         prescription: "5 × 10m",
                         coachNote: "Lean forward until you have to run — explosive!",
                         section: "SPRINT DRILLS",
                         logType: .setsAndDistance,
                         defaultSets: 5, defaultReps: 0, defaultSeconds: 0),
                Exercise(name: "Acceleration Sprints",
                         prescription: "4 × 30m",
                         coachNote: "Walk back = full rest between each",
                         section: "SPRINT DRILLS",
                         logType: .setsAndDistance,
                         defaultSets: 4, defaultReps: 0, defaultSeconds: 0),
            ]),
            WorkoutSection(name: "POWER WORK", durationMinutes: 5, exercises: [
                Exercise(name: "Broad Jumps",
                         prescription: "3 × 5 jumps",
                         coachNote: "Stick the landing! Soft knees.",
                         section: "POWER WORK",
                         logType: .setsAndReps,
                         defaultSets: 3, defaultReps: 5, defaultSeconds: 0),
                Exercise(name: "Pogo Hops",
                         prescription: "3 × 10 reps",
                         coachNote: "Stay on toes, quick off the ground",
                         section: "POWER WORK",
                         logType: .setsAndReps,
                         defaultSets: 3, defaultReps: 10, defaultSeconds: 0),
            ]),
            WorkoutSection(name: "COOL-DOWN", durationMinutes: 3, exercises: [
                Exercise(name: "Standing Quad Stretch",
                         prescription: "30 sec each leg",
                         coachNote: "",
                         section: "COOL-DOWN",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 30),
                Exercise(name: "Hip Flexor Stretch (lunge)",
                         prescription: "30 sec each side",
                         coachNote: "Key for sprinters — don't skip!",
                         section: "COOL-DOWN",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 30),
                Exercise(name: "Hamstring Stretch (standing)",
                         prescription: "30 sec each leg",
                         coachNote: "",
                         section: "COOL-DOWN",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 30),
            ]),
        ]
    )

    // -------------------------------------------------------------------------
    // DAY 2 — Strength & Armor
    // -------------------------------------------------------------------------
    static let day2 = WorkoutDay(
        id: 2,
        title: "Strength & Armor",
        subtitle: "Injury prevention · Joint stability · Core power",
        emoji: "🛡️",
        durationMinutes: 25,
        color: .blue,
        sections: [
            WorkoutSection(name: "DYNAMIC WARM-UP", durationMinutes: 5, exercises: [
                Exercise(name: "Walking Lunges",
                         prescription: "10 each leg",
                         coachNote: "Slow and controlled",
                         section: "DYNAMIC WARM-UP",
                         logType: .none,
                         defaultSets: 1, defaultReps: 10, defaultSeconds: 0),
                Exercise(name: "Arm Circles",
                         prescription: "10 fwd / 10 back",
                         coachNote: "Big and small",
                         section: "DYNAMIC WARM-UP",
                         logType: .none,
                         defaultSets: 1, defaultReps: 10, defaultSeconds: 0),
                Exercise(name: "Inchworm Walk-Outs",
                         prescription: "5 reps",
                         coachNote: "Walk hands to plank, walk feet back up",
                         section: "DYNAMIC WARM-UP",
                         logType: .none,
                         defaultSets: 1, defaultReps: 5, defaultSeconds: 0),
            ]),
            WorkoutSection(name: "LOWER BODY STRENGTH", durationMinutes: 10, exercises: [
                Exercise(name: "Bodyweight Squats",
                         prescription: "3 × 12",
                         coachNote: "Chest up, knees track over toes",
                         section: "LOWER BODY STRENGTH",
                         logType: .setsAndReps,
                         defaultSets: 3, defaultReps: 12, defaultSeconds: 0),
                Exercise(name: "Reverse Lunges",
                         prescription: "3 × 8 each leg",
                         coachNote: "Step back — easier on knees than forward",
                         section: "LOWER BODY STRENGTH",
                         logType: .setsAndReps,
                         defaultSets: 3, defaultReps: 8, defaultSeconds: 0),
                Exercise(name: "Glute Bridges",
                         prescription: "3 × 15",
                         coachNote: "Squeeze at the top! Huge for sprinters",
                         section: "LOWER BODY STRENGTH",
                         logType: .setsAndReps,
                         defaultSets: 3, defaultReps: 15, defaultSeconds: 0),
                Exercise(name: "Single-Leg Balance",
                         prescription: "3 × 20 sec each",
                         coachNote: "Close your eyes for extra challenge",
                         section: "LOWER BODY STRENGTH",
                         logType: .setsAndTime,
                         defaultSets: 3, defaultReps: 0, defaultSeconds: 20),
            ]),
            WorkoutSection(name: "CORE & STABILITY", durationMinutes: 7, exercises: [
                Exercise(name: "Dead Bug",
                         prescription: "3 × 8 each side",
                         coachNote: "Lower back stays flat on ground",
                         section: "CORE & STABILITY",
                         logType: .setsAndReps,
                         defaultSets: 3, defaultReps: 8, defaultSeconds: 0),
                Exercise(name: "Plank Hold",
                         prescription: "3 × 20–30 sec",
                         coachNote: "Straight line head to heel",
                         section: "CORE & STABILITY",
                         logType: .setsAndTime,
                         defaultSets: 3, defaultReps: 0, defaultSeconds: 25),
                Exercise(name: "Side Plank",
                         prescription: "2 × 15 sec each side",
                         coachNote: "Build up time each week",
                         section: "CORE & STABILITY",
                         logType: .setsAndTime,
                         defaultSets: 2, defaultReps: 0, defaultSeconds: 15),
            ]),
            WorkoutSection(name: "COOL-DOWN", durationMinutes: 3, exercises: [
                Exercise(name: "Child's Pose",
                         prescription: "30 sec",
                         coachNote: "",
                         section: "COOL-DOWN",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 30),
                Exercise(name: "Pigeon Pose",
                         prescription: "30 sec each side",
                         coachNote: "Great for hips and glutes",
                         section: "COOL-DOWN",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 30),
                Exercise(name: "Cat-Cow Stretch",
                         prescription: "10 slow reps",
                         coachNote: "",
                         section: "COOL-DOWN",
                         logType: .none,
                         defaultSets: 1, defaultReps: 10, defaultSeconds: 0),
            ]),
        ]
    )

    // -------------------------------------------------------------------------
    // DAY 3 — Speed Endurance
    // -------------------------------------------------------------------------
    static let day3 = WorkoutDay(
        id: 3,
        title: "Speed Endurance",
        subtitle: "Running longer at speed · Race conditioning · Rhythm",
        emoji: "🏃",
        durationMinutes: 30,
        color: .green,
        sections: [
            WorkoutSection(name: "DYNAMIC WARM-UP", durationMinutes: 5, exercises: [
                Exercise(name: "Easy Jog",
                         prescription: "200m (1 lap)",
                         coachNote: "Very easy — just get the blood moving",
                         section: "DYNAMIC WARM-UP",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 0),
                Exercise(name: "High Knees",
                         prescription: "20m × 2",
                         coachNote: "",
                         section: "DYNAMIC WARM-UP",
                         logType: .none,
                         defaultSets: 2, defaultReps: 0, defaultSeconds: 0),
                Exercise(name: "Carioca (grapevine)",
                         prescription: "20m each direction",
                         coachNote: "Fun lateral movement drill",
                         section: "DYNAMIC WARM-UP",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 0),
            ]),
            WorkoutSection(name: "SPEED ENDURANCE RUNS", durationMinutes: 18, exercises: [
                Exercise(name: "Flying 20s",
                         prescription: "4 × 20m",
                         coachNote: "Build speed for 20m, explode through 20m. Walk back.",
                         section: "SPEED ENDURANCE RUNS",
                         logType: .setsAndDistance,
                         defaultSets: 4, defaultReps: 0, defaultSeconds: 0),
                Exercise(name: "60m Repeats",
                         prescription: "4 × 60m",
                         coachNote: "~80% effort. Walk back = full rest. Form over speed.",
                         section: "SPEED ENDURANCE RUNS",
                         logType: .setsAndDistance,
                         defaultSets: 4, defaultReps: 0, defaultSeconds: 0),
                Exercise(name: "Stride-Outs",
                         prescription: "3 × 80m",
                         coachNote: "Smooth and tall. Like floating. Not a race.",
                         section: "SPEED ENDURANCE RUNS",
                         logType: .setsAndDistance,
                         defaultSets: 3, defaultReps: 0, defaultSeconds: 0),
            ]),
            WorkoutSection(name: "PLYOMETRIC FINISHER", durationMinutes: 4, exercises: [
                Exercise(name: "Bounding",
                         prescription: "3 × 20m",
                         coachNote: "Exaggerate each stride, drive the arms",
                         section: "PLYOMETRIC FINISHER",
                         logType: .setsAndDistance,
                         defaultSets: 3, defaultReps: 0, defaultSeconds: 0),
                Exercise(name: "Lateral Hops over line",
                         prescription: "3 × 10 each side",
                         coachNote: "Quick off the ground",
                         section: "PLYOMETRIC FINISHER",
                         logType: .setsAndReps,
                         defaultSets: 3, defaultReps: 10, defaultSeconds: 0),
            ]),
            WorkoutSection(name: "COOL-DOWN", durationMinutes: 3, exercises: [
                Exercise(name: "Easy Walk",
                         prescription: "100m",
                         coachNote: "",
                         section: "COOL-DOWN",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 0),
                Exercise(name: "Seated Hamstring Stretch",
                         prescription: "30 sec each leg",
                         coachNote: "",
                         section: "COOL-DOWN",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 30),
                Exercise(name: "Standing Calf Stretch",
                         prescription: "30 sec each leg",
                         coachNote: "Lean into wall",
                         section: "COOL-DOWN",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 30),
            ]),
        ]
    )

    // -------------------------------------------------------------------------
    // DAY 4 — Recovery & Movement
    // -------------------------------------------------------------------------
    static let day4 = WorkoutDay(
        id: 4,
        title: "Recovery & Movement",
        subtitle: "Active recovery · Flexibility · Body awareness",
        emoji: "🧘",
        durationMinutes: 20,
        color: .purple,
        sections: [
            WorkoutSection(name: "LIGHT MOVEMENT", durationMinutes: 5, exercises: [
                Exercise(name: "Easy Jog or Brisk Walk",
                         prescription: "3–5 min",
                         coachNote: "This is NOT a workout. Just move.",
                         section: "LIGHT MOVEMENT",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 0),
            ]),
            WorkoutSection(name: "MOBILITY FLOW", durationMinutes: 10, exercises: [
                Exercise(name: "World's Greatest Stretch",
                         prescription: "5 each side",
                         coachNote: "Lunge + rotate + reach — look it up!",
                         section: "MOBILITY FLOW",
                         logType: .none,
                         defaultSets: 1, defaultReps: 5, defaultSeconds: 0),
                Exercise(name: "90/90 Hip Stretch",
                         prescription: "1 min each side",
                         coachNote: "Sit on ground, both legs at 90 degrees",
                         section: "MOBILITY FLOW",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 60),
                Exercise(name: "Hip Flexor Lunge + Reach",
                         prescription: "45 sec each side",
                         coachNote: "Arm reaches up and away",
                         section: "MOBILITY FLOW",
                         logType: .none,
                         defaultSets: 1, defaultReps: 0, defaultSeconds: 45),
                Exercise(name: "Thread the Needle",
                         prescription: "8 each side",
                         coachNote: "On all fours, thread one arm under body",
                         section: "MOBILITY FLOW",
                         logType: .none,
                         defaultSets: 1, defaultReps: 8, defaultSeconds: 0),
                Exercise(name: "Ankle Circles",
                         prescription: "10 each direction per ankle",
                         coachNote: "Easy but important for sprinters",
                         section: "MOBILITY FLOW",
                         logType: .none,
                         defaultSets: 1, defaultReps: 10, defaultSeconds: 0),
            ]),
            WorkoutSection(name: "BALANCE & BODY CONTROL", durationMinutes: 5, exercises: [
                Exercise(name: "Single-Leg RDL (bodyweight)",
                         prescription: "3 × 8 each leg",
                         coachNote: "Slow — builds ankle and hamstring stability",
                         section: "BALANCE & BODY CONTROL",
                         logType: .setsAndReps,
                         defaultSets: 3, defaultReps: 8, defaultSeconds: 0),
                Exercise(name: "Heel-to-Toe Walk (tightrope)",
                         prescription: "2 × 20 steps",
                         coachNote: "Focus on core control",
                         section: "BALANCE & BODY CONTROL",
                         logType: .setsAndReps,
                         defaultSets: 2, defaultReps: 20, defaultSeconds: 0),
            ]),
        ]
    )

    // MARK: - Weekly Schedule (day of week → workout day number)
    // weekday: 2 = Mon, 4 = Wed, 5 = Thu, 7 = Sat
    static let weeklySchedule: [Int: Int] = [
        2: 1,  // Monday    → Day 1
        4: 2,  // Wednesday → Day 2
        5: 3,  // Thursday  → Day 3
        7: 4,  // Saturday  → Day 4
    ]

    static func workoutDayNumber(for date: Date) -> Int? {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weeklySchedule[weekday]
    }

    // MARK: - Program Phase (based on weeks since start)
    static func phase(for weekNumber: Int) -> String {
        switch weekNumber {
        case 1...2:  return "Foundation — Learn the movements. Focus on form."
        case 3...4:  return "Build — Add intensity. Accelerations at 85–90%."
        case 5...6:  return "Push — Increase sprint distances. Hold planks longer."
        default:     return "Elite — You should feel faster! Consider joining a club."
        }
    }
}
