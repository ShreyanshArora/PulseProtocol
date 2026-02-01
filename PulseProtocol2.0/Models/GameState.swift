//
//  GameState.swift
//  PulseProtocol2.0
//
//  Created by Shreyansh on 22/12/25.
//

import Foundation

// MARK: - Game Phase
enum GamePhase: Equatable {
    case menu
    case instructions
    case playingPattern    // Device is vibrating the sequence
    case waitingForInput   // User's turn to tap & hold
    case correct           // User completed the round correctly
    case gameOver          // User tapped wrong → restart
}

// MARK: - Score Popup (floating +10 / -5 label)
struct ScorePopup: Identifiable {
    let id   = UUID()
    let text: String          // "+10" or "-5"
    let isPositive: Bool
}

// MARK: - Game Session
class GameSession: ObservableObject {

    @Published var phase: GamePhase = .menu {
        didSet {
            print("🔄 Phase: \(oldValue) → \(phase)")
        }
    }

    @Published var currentScore   : Int = 0
    @Published var highScore      : Int = 0
    @Published var currentRound   : Int = 0
    @Published var currentSequence: HapticSequence?
    @Published var userInputs     : [UserInput] = []

    /// Popup that floats up when score changes
    @Published var activePopup: ScorePopup? = nil

    // Timing helpers
    var patternStartTime: Date?
    var lastInputTime   : Date?

    // MARK: - Constants
    static let maxRound       = 25
    static let pointsCorrect  =  10
    static let pointsWrong    =  -5

    // MARK: - Reset
    func reset() {
        phase             = .menu
        currentScore      = 0
        currentRound      = 0
        currentSequence   = nil
        userInputs        = []
        patternStartTime  = nil
        lastInputTime     = nil
        activePopup       = nil
    }

    // MARK: - Start New Round
    func startNewRound() {
        currentRound     += 1
        currentSequence   = HapticSequence.generate(difficulty: currentRound)
        userInputs        = []
        phase             = .playingPattern
        print("🎵 Round \(currentRound): \(currentSequence!.patterns.map { $0.rawValue })")
    }

    // MARK: - Record & Validate a single tap
    func recordInput(type: HapticType, duration: TimeInterval) {
        let input = UserInput(type: type,
                              timestamp: Date().timeIntervalSince1970,
                              duration: duration)
        userInputs.append(input)
        lastInputTime = Date()
    }

    /// Checks the LAST recorded input against what was expected
    func validateLastInput() -> Bool {
        guard let seq   = currentSequence else { return false }
        let index = userInputs.count - 1
        guard index >= 0, index < seq.patterns.count else { return false }

        let expected = seq.patterns[index]
        let input    = userInputs[index]

        return PatternMatcher.matches(userInput: input.type,
                                      expected:  expected,
                                      duration:  input.duration)
    }

    func isRoundComplete() -> Bool {
        guard let seq = currentSequence else { return false }
        return userInputs.count == seq.patterns.count
    }

    // MARK: - Score helpers
    func applyCorrect() {
        currentScore = max(0, currentScore + GameSession.pointsCorrect)
        if currentScore > highScore { highScore = currentScore }
        showPopup(GameSession.pointsCorrect)
    }

    func applyWrong() {
        currentScore = max(0, currentScore + GameSession.pointsWrong)
        showPopup(GameSession.pointsWrong)
        phase = .gameOver
    }

    private func showPopup(_ delta: Int) {
        let text = delta >= 0 ? "+\(delta)" : "\(delta)"
        activePopup = ScorePopup(text: text, isPositive: delta >= 0)
        // Auto-dismiss after 0.9 s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.activePopup = nil
        }
    }
}
