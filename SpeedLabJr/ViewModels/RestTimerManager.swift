// RestTimerManager.swift
// SpeedLabJr

import Foundation
import Combine

@Observable
final class RestTimerManager {
    var isActive: Bool = false
    var remainingSeconds: Int = 0
    var totalSeconds: Int = 0
    
    // We don't use @ObservationIgnored timer because we can just use a Combine cancellable
    // or Swift async Task. Let's use a Task.
    private var timerTask: Task<Void, Error>?
    
    func start(seconds: Int) {
        stop()
        totalSeconds = seconds
        remainingSeconds = seconds
        isActive = true
        
        timerTask = Task { @MainActor in
            while remainingSeconds > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if !Task.isCancelled {
                    remainingSeconds -= 1
                    if remainingSeconds <= 0 {
                        isActive = false
                        break
                    }
                }
            }
        }
    }
    
    func addTime(seconds: Int) {
        if isActive {
            remainingSeconds += seconds
            totalSeconds += seconds
        }
    }
    
    func stop() {
        timerTask?.cancel()
        timerTask = nil
        isActive = false
        remainingSeconds = 0
    }
    
    func skip() {
        stop()
    }
    
    var timeString: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }
}
