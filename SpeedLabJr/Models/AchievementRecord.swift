// AchievementRecord.swift
// SpeedLabJr

import Foundation
import SwiftData

@Model
final class AchievementRecord {
    var achievementID: String
    var earnedAt: Date
    
    init(achievementID: String, earnedAt: Date = Date()) {
        self.achievementID = achievementID
        self.earnedAt = earnedAt
    }
}
