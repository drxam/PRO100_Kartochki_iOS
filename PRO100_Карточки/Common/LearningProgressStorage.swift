//
//  LearningProgressStorage.swift
//  PRO100_Карточки
//
//  Локальный «прогресс обучения» в профиле: число полностью завершённых сессий (прошли все карточки набора).
//  На бэкенде отдельной метрики пока нет — шкала ориентировочная: 10 завершённых сессий ≈ 100%.
//

import Foundation

enum LearningProgressStorage {
    private static let sessionsKey = "learning_sessions_completed"

    static func recordSessionCompleted() {
        let n = UserDefaults.standard.integer(forKey: sessionsKey) + 1
        UserDefaults.standard.set(n, forKey: sessionsKey)
    }

    /// 0…100 для отображения в профиле.
    static func displayPercent() -> Int {
        let n = UserDefaults.standard.integer(forKey: sessionsKey)
        return min(100, n * 10)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: sessionsKey)
    }
}
