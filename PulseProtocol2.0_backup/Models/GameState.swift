import Foundation

// MARK: - Game State
enum GamePhase: Equatable {
    case menu
    case instructions
    case playingPattern    // Device is vibrating
    case waitingForInput   // User's turn to tap
    case correct           // User got it right
    case gameOver          // User failed
}

// MARK: - Game Session
class GameSession: ObservableObject {
    @Published var phase: GamePhase = .menu {
        didSet {
            print("🔄 Phase changed from \(oldValue) to \(phase)")
        }
    }
    @Published var currentScore: Int = 0
    @Published var currentRound: Int = 0
    @Published var currentSequence: HapticSequence?
    @Published var userInputs: [UserInput] = []
    @Published var livesRemaining: Int = 3
    @Published var comboMultiplier: Int = 1
    
    // High Score
    @Published var highScore: Int = 0
    
    // Timing
    var patternStartTime: Date?
    var lastInputTime: Date?
    
    // Score Constants
    let basePointsPerPattern = 100
    let perfectBonusPoints = 50
    let timingPenalty = 10
    let wrongPatternPenalty = 30
    
    // MARK: - Reset Game
    func reset() {
        phase = .menu
        currentScore = 0
        currentRound = 0
        currentSequence = nil
        userInputs = []
        livesRemaining = 3
        comboMultiplier = 1
        patternStartTime = nil
        lastInputTime = nil
    }
    
    // MARK: - Start New Round
    func startNewRound() {
        currentRound += 1
        currentSequence = HapticSequence.generate(difficulty: currentRound)
        userInputs = []
        phase = .playingPattern
    }
    
    // MARK: - Score Calculation
    func calculateScore(accuracy: Double, isPerfect: Bool) {
        var points = basePointsPerPattern * comboMultiplier
        
        if isPerfect {
            points += perfectBonusPoints
            comboMultiplier += 1
            print("⭐ PERFECT! Combo: x\(comboMultiplier)")
        } else {
            comboMultiplier = 1
            points = Int(Double(points) * accuracy)
            print("✓ Good! Accuracy: \(Int(accuracy * 100))%")
        }
        
        currentScore += points
        print("💰 Score: +\(points) = \(currentScore)")
        
        // Update high score
        if currentScore > highScore {
            highScore = currentScore
            print("🏆 NEW HIGH SCORE: \(highScore)")
        }
    }
    
    // MARK: - Penalty Handling
    func applyTimingPenalty() {
        currentScore = max(0, currentScore - timingPenalty)
    }
    
    func applyWrongPatternPenalty() {
        currentScore = max(0, currentScore - wrongPatternPenalty)
        livesRemaining -= 1
        comboMultiplier = 1
        
        if livesRemaining <= 0 {
            phase = .gameOver
        }
    }
    
    // MARK: - Input Recording
    func recordInput(type: HapticType, duration: TimeInterval) {
        let timestamp = Date().timeIntervalSince1970
        let input = UserInput(type: type, timestamp: timestamp, duration: duration)
        userInputs.append(input)
        lastInputTime = Date()
    }
    
    // MARK: - Validation
    func validateCurrentInput() -> Bool {
        guard let sequence = currentSequence else { return false }
        
        let index = userInputs.count - 1
        guard index < sequence.patterns.count else { return false }
        
        let expectedPattern = sequence.patterns[index]
        let userInput = userInputs[index]
        
        return PatternMatcher.matches(
            userInput: userInput.type,
            expected: expectedPattern,
            duration: userInput.duration
        )
    }
    
    // MARK: - Check if round is complete
    func isRoundComplete() -> Bool {
        guard let sequence = currentSequence else { return false }
        return userInputs.count == sequence.patterns.count
    }
}
