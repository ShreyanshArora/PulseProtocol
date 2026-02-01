import Foundation
import UIKit

// MARK: - Haptic Pattern Types
enum HapticType: String, CaseIterable {
    case short
    case medium
    case long

    // How long the device vibrates
    var duration: TimeInterval {
        switch self {
        case .short:  return 0.15
        case .medium: return 0.4
        case .long:   return 0.8
        }
    }

    // Target hold duration the user should match
    var targetPressDuration: TimeInterval {
        switch self {
        case .short:  return 0.2
        case .medium: return 0.45
        case .long:   return 0.85
        }
    }

    // ± window around target that counts as correct
    // Generous enough for real fingers on a real phone
    var tolerance: TimeInterval {
        switch self {
        case .short:  return 0.15   // accepts 0.05 – 0.35 s
        case .medium: return 0.22   // accepts 0.23 – 0.67 s
        case .long:   return 0.30   // accepts 0.55 – 1.15 s
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
    let patterns   : [HapticType]
    let difficulty : Int

    // Round 1 → 3 patterns, Round 2 → 4, … capped at 25
    static func generate(difficulty: Int) -> HapticSequence {
        let length   = min(difficulty + 2, 25)
        let patterns = (0..<length).map { _ in HapticType.allCases.randomElement()! }
        return HapticSequence(patterns: patterns, difficulty: difficulty)
    }

    var totalDuration: TimeInterval {
        patterns.reduce(0.0) { $0 + $1.duration + 0.35 }
    }
}

// MARK: - User Input
struct UserInput {
    let type      : HapticType
    let timestamp : TimeInterval
    let duration  : TimeInterval
}

// MARK: - Pattern Matching
struct PatternMatcher {

    static func matches(userInput: HapticType,
                        expected:  HapticType,
                        duration:  TimeInterval) -> Bool {
        // Must be the correct button
        guard userInput == expected else { return false }
        // Must be held for roughly the right duration
        let target    = expected.targetPressDuration
        let tolerance = expected.tolerance
        return abs(duration - target) <= tolerance
    }

    static func accuracy(userDuration: TimeInterval, expected: HapticType) -> Double {
        let diff    = abs(userDuration - expected.targetPressDuration)
        let maxDiff = expected.tolerance
        guard maxDiff > 0 else { return 1.0 }
        return max(0.0, 1.0 - (diff / maxDiff))
    }
}
