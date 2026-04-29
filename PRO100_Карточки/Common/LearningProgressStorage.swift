//
//  LearningProgressStorage.swift
//  PRO100_Карточки
//


import Foundation

// MARK: - LearningProgressStorage
enum LearningProgressStorage {
    private static let sessionsKey = "learning_sessions_completed"

    static func recordSessionCompleted() {
        let n = UserDefaults.standard.integer(forKey: sessionsKey) + 1
        UserDefaults.standard.set(n, forKey: sessionsKey)
    }

    static func displayPercent() -> Int {
        let n = UserDefaults.standard.integer(forKey: sessionsKey)
        return min(100, n * 10)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: sessionsKey)
    }
}
