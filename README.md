# Speed Lab Jr. — iOS App

A native iPhone app for the **Speed Lab Jr.** youth track & field training program (Age 13, 3–4 days/week).

Built with **SwiftUI + SwiftData**, targeting **iOS 17+**.

---

## Features

| Feature | Description |
|---|---|
| 📅 **Calendar** | Monthly view showing every scheduled workout with colour-coded status badges |
| ⚡️ **Today** | Hero screen showing today's workout (or next upcoming), with instant Start / Skip controls |
| ✅ **Mark Done** | One-tap to mark a workout complete; undo any time |
| 🚫 **Skip** | Flag a workout as skipped (injury, schedule conflict) with a swipe-safe confirmation |
| 📝 **Log Exercises** | Per-exercise logging of sets, reps, weight, duration, or distance |
| 📈 **Progress Charts** | Line & bar charts showing completion rate by week and exercise progress over time (personal bests highlighted) |
| 🏆 **Personal Bests** | Automatic PB detection per exercise |
| 📖 **Full Program** | All 4 workout days pre-loaded with every exercise, prescription, and coach note |

---

## The Program

| Day | Focus | Duration |
|---|---|---|
| Day 1 (Mon) | ⚡️ Speed & Explosion | 25 min |
| Day 2 (Wed) | 🛡️ Strength & Armor | 25 min |
| Day 3 (Thu) | 🏃 Speed Endurance | 30 min |
| Day 4 (Sat) | 🧘 Recovery & Movement | 20 min |

Weekly schedule: **Mon · Wed · Thu · Sat** (rest days: Tue, Fri, Sun).

---

## Getting Started

### Prerequisites

- **macOS** with **Xcode 15.4+** installed
- **[XcodeGen](https://github.com/yonaskolb/XcodeGen)** (generates the `.xcodeproj` from `project.yml`)

```bash
# Install XcodeGen via Homebrew
brew install xcodegen
```

### Setup

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/SpeedLabJr.git
cd SpeedLabJr

# 2. Generate the Xcode project
xcodegen generate

# 3. Open in Xcode
open SpeedLabJr.xcodeproj
```

4. Select a simulator or your connected iPhone and hit **⌘R** to run.

> **Note:** The first launch generates 52 weeks of workout sessions automatically.

---

## Project Structure

```
SpeedLabJr/
├── project.yml                         # XcodeGen configuration
├── SpeedLabJr/
│   ├── SpeedLabJrApp.swift             # App entry point + SwiftData container
│   ├── ContentView.swift               # Tab bar (Calendar / Today / Progress)
│   ├── Models/
│   │   ├── WorkoutProgram.swift        # All static workout data (exercises, prescriptions)
│   │   ├── WorkoutSession.swift        # SwiftData model — one workout instance
│   │   └── ExerciseLog.swift           # SwiftData model — logged exercise entry
│   ├── Views/
│   │   ├── CalendarView.swift          # Monthly calendar grid
│   │   ├── TodayView.swift             # Today / next workout hero screen
│   │   ├── WorkoutDetailView.swift     # Full workout with exercises + mark done/skip
│   │   ├── LogExerciseSheet.swift      # Bottom sheet for logging sets/reps/time
│   │   └── ProgressChartsView.swift    # Weekly completion + exercise progress charts
│   └── ViewModels/
│       └── ScheduleManager.swift       # Schedule generation & statistics
└── README.md
```

---

## Tech Stack

| Technology | Usage |
|---|---|
| SwiftUI | All UI |
| SwiftData | Local persistence (workout sessions, exercise logs) |
| Swift Charts | Progress graphs (iOS 16+ Charts framework) |
| UserDefaults | Program start date preference |

---

## Adding More Features (ideas)

- **Apple Health integration** — write workouts to HealthKit
- **Notifications** — reminder push notifications on workout days
- **Widget** — home screen widget showing today's workout
- **Confetti animation** — celebrate when a workout is marked done
- **Export** — share progress as a PDF or CSV
- **Coach mode** — custom exercises / edit prescriptions

---

## License

MIT — feel free to adapt for your own training programs.
