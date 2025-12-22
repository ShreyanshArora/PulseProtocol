//
//  HapticPattern.swift
//  PulseProtocol2.0
//
//  Created by Shreyansh on 22/12/25.
//

import Foundation
import UIKit

// MARK: - Haptic Pattern Types
enum HapticType: String, CaseIterable {
    case short
    case medium
    case long
    
    var duration: TimeInterval {
        switch self {
        case .short: return 0.1
        case .medium: return 0.3
        case .long: return 0.6
        }
    }
    
    var intensity: CGFloat {
        switch self {
        case .short: return 0.5
        case .medium: return 0.7
        case .long: return 1.0
        }
    }
    
    // Tolerance for user input matching (in seconds)
    var tolerance: TimeInterval {
        switch self {
        case .short: return 0.08
        case .medium: return 0.12
        case .long: return 0.15
        }
    }
}

// MARK: - Pattern Sequence
struct HapticSequence {
    let patterns: [HapticType]
    let difficulty: Int
    
    // Generate random pattern based on difficulty
    static func generate(difficulty: Int) -> HapticSequence {
        let length = min(3 + difficulty, 10) // Start with 3, max 10
        let patterns = (0..<length).map { _ in HapticType.allCases.randomElement()! }
        return HapticSequence(patterns: patterns, difficulty: difficulty)
    }
    
    // Total duration of the sequence
    var totalDuration: TimeInterval {
        patterns.reduce(0) { $0 + $1.duration + 0.2 } // 0.2s gap between patterns
    }
}

// MARK: - User Input
struct UserInput {
    let type: HapticType
    let timestamp: TimeInterval
    let duration: TimeInterval
}

// MARK: - Pattern Matching
struct PatternMatcher {
    
    // Compare user input with expected pattern
    static func matches(userInput: HapticType, expected: HapticType, duration: TimeInterval) -> Bool {
        // Check if type matches
        guard userInput == expected else { return false }
        
        // Check if duration is within tolerance
        let expectedDuration = expected.duration
        let tolerance = expected.tolerance
        
        return abs(duration - expectedDuration) <= tolerance
    }
    
    // Calculate timing accuracy (0.0 to 1.0)
    static func accuracy(userDuration: TimeInterval, expected: HapticType) -> Double {
        let diff = abs(userDuration - expected.duration)
        let maxDiff = expected.tolerance
        return max(0, 1.0 - (diff / maxDiff))
    }
}
