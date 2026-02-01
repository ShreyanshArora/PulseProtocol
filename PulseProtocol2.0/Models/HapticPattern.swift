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

    // Duration the device vibrates for this pattern
    var duration: TimeInterval {
        switch self {
        case .short:  return 0.15   // ~150 ms burst
        case .medium: return 0.4    // ~400 ms burst
        case .long:   return 0.8    // ~800 ms burst
        }
    }

    // How long the USER should hold the button (target press duration)
    // Slightly longer than haptic duration so it feels natural
    var targetPressDuration: TimeInterval {
        switch self {
        case .short:  return 0.18
        case .medium: return 0.45
        case .long:   return 0.85
        }
    }

    // Acceptable window around the target press duration (±tolerance)
    // These are generous so the game is actually playable
    var tolerance: TimeInterval {
        switch self {
        case .short:  return 0.15   // 0.03 – 0.33 s accepted
        case .medium: return 0.22   // 0.23 – 0.67 s accepted
        case .long:   return 0.30   // 0.55 – 1.15 s accepted
        }
    }

    var intensity: CGFloat {
        switch self {
        case .short:  return 0.5
        case .medium: return 0.7
        case .long:   return 1.0
        }
    }
}

// MARK: - Pattern Sequence
struct HapticSequence {
    let patterns: [HapticType]
    let difficulty: Int

    /// Round 1 → 3 patterns, Round 2 → 4, … Round 23 → 25 (capped)
    static func generate(difficulty: Int) -> HapticSequence {
        let length = min(difficulty + 2, 25)
        let patterns = (0..<length).map { _ in HapticType.allCases.randomElement()! }
        return HapticSequence(patterns: patterns, difficulty: difficulty)
    }

    var totalDuration: TimeInterval {
        patterns.reduce(0.0) { $0 + $1.duration + 0.35 }
    }
}

// MARK: - User Input
struct UserInput {
    let type: HapticType
    let timestamp: TimeInterval
    let duration: TimeInterval   // how long the user actually held
}

// MARK: - Pattern Matching
struct PatternMatcher {

    /// Returns true when the user pressed the correct button AND held it
    /// within the acceptable tolerance window.
    static func matches(userInput: HapticType,
                        expected: HapticType,
                        duration: TimeInterval) -> Bool {
        guard userInput == expected else { return false }

        let target    = expected.targetPressDuration
        let tolerance = expected.tolerance
        return abs(duration - target) <= tolerance
    }

    /// 0.0 – 1.0 accuracy for scoring tweaks (not used in current simple +10/-5 model)
    static func accuracy(userDuration: TimeInterval, expected: HapticType) -> Double {
        let diff    = abs(userDuration - expected.targetPressDuration)
        let maxDiff = expected.tolerance
        guard maxDiff > 0 else { return 1.0 }
        return max(0.0, 1.0 - (diff / maxDiff))
    }
}
