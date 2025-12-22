//
//  UserDefaultManager.swift
//  PulseProtocol2.0
//
//  Created by Shreyansh on 22/12/25.
//

import Foundation

// MARK: - Persistent Storage Manager
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    private let highScoreKey = "PulseProtocol_HighScore"
    private let gamesPlayedKey = "PulseProtocol_GamesPlayed"
    private let totalPatternsKey = "PulseProtocol_TotalPatterns"
    
    private init() {}
    
    // MARK: - High Score
    func saveHighScore(_ score: Int) {
        let current = getHighScore()
        if score > current {
            defaults.set(score, forKey: highScoreKey)
        }
    }
    
    func getHighScore() -> Int {
        return defaults.integer(forKey: highScoreKey)
    }
    
    // MARK: - Stats
    func incrementGamesPlayed() {
        let current = defaults.integer(forKey: gamesPlayedKey)
        defaults.set(current + 1, forKey: gamesPlayedKey)
    }
    
    func getGamesPlayed() -> Int {
        return defaults.integer(forKey: gamesPlayedKey)
    }
    
    func addPatternsCompleted(_ count: Int) {
        let current = defaults.integer(forKey: totalPatternsKey)
        defaults.set(current + count, forKey: totalPatternsKey)
    }
    
    func getTotalPatterns() -> Int {
        return defaults.integer(forKey: totalPatternsKey)
    }
    
    // MARK: - Reset
    func resetAllData() {
        defaults.removeObject(forKey: highScoreKey)
        defaults.removeObject(forKey: gamesPlayedKey)
        defaults.removeObject(forKey: totalPatternsKey)
    }
}
