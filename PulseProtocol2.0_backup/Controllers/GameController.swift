import Foundation
import Combine

// MARK: - Game Controller
class GameController: ObservableObject {
    @Published var session = GameSession()
    private let hapticEngine = HapticEngine.shared
    private let storage = UserDefaultsManager.shared
    
    private var tapStartTime: Date?
    
    init() {
        // Load high score
        session.highScore = storage.getHighScore()
    }
    
    // MARK: - Game Flow
    func startGame() {
        print("🎮 Starting game...")
        session.reset()
        session.highScore = storage.getHighScore()
        print("📊 High score loaded: \(session.highScore)")
        startNewRound()
    }
    
    func startNewRound() {
        print("🔄 Starting round \(session.currentRound + 1)")
        session.startNewRound()
        
        // Play the pattern sequence
        guard let sequence = session.currentSequence else {
            print("❌ No sequence generated!")
            return
        }
        
        print("🎵 Pattern generated: \(sequence.patterns.map { $0.rawValue })")
        session.patternStartTime = Date()
        
        // Trigger UI update
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
        
        hapticEngine.playSequence(sequence) { [weak self] in
            print("✅ Pattern playback complete, waiting for input")
            DispatchQueue.main.async {
                self?.session.phase = .waitingForInput
                self?.session.patternStartTime = Date()
                self?.objectWillChange.send()
            }
        }
    }
    
    // MARK: - User Input Handling
    func onTapDown(type: HapticType) {
        guard session.phase == .waitingForInput else {
            print("⚠️ Tap ignored - wrong phase: \(session.phase)")
            return
        }
        tapStartTime = Date()
        print("👆 Tap DOWN: \(type.rawValue)")
        
        // Provide immediate haptic feedback
        hapticEngine.playPattern(type)
    }
    
    func onTapUp(type: HapticType) {
        guard session.phase == .waitingForInput,
              let startTime = tapStartTime else {
            print("⚠️ Tap UP ignored - wrong phase or no start time")
            return
        }
        
        let duration = Date().timeIntervalSince(startTime)
        print("👆 Tap UP: \(type.rawValue), duration: \(String(format: "%.2f", duration))s")
        
        session.recordInput(type: type, duration: duration)
        
        let inputIndex = session.userInputs.count - 1
        if let sequence = session.currentSequence, inputIndex < sequence.patterns.count {
            let expected = sequence.patterns[inputIndex]
            print("🎯 Expected: \(expected.rawValue) (\(String(format: "%.2f", expected.duration))s)")
            print("👤 Got: \(type.rawValue) (\(String(format: "%.2f", duration))s)")
        }
        
        // Validate input
        if session.validateCurrentInput() {
            print("✅ Input CORRECT!")
            // Correct input
            checkIfRoundComplete()
        } else {
            print("❌ Input WRONG!")
            // Wrong input - Game Over
            handleWrongInput()
        }
        
        tapStartTime = nil
    }
    
    // MARK: - Round Completion
    private func checkIfRoundComplete() {
        if session.isRoundComplete() {
            // Calculate score
            calculateRoundScore()
            
            // Show success feedback
            hapticEngine.playSuccess()
            session.phase = .correct
            
            // Start next round after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.startNewRound()
            }
        }
    }
    
    private func calculateRoundScore() {
        guard let sequence = session.currentSequence else { return }
        
        var totalAccuracy = 0.0
        var isPerfect = true
        
        for (index, input) in session.userInputs.enumerated() {
            let expected = sequence.patterns[index]
            let accuracy = PatternMatcher.accuracy(
                userDuration: input.duration,
                expected: expected
            )
            totalAccuracy += accuracy
            
            if accuracy < 0.9 {
                isPerfect = false
            }
        }
        
        let avgAccuracy = totalAccuracy / Double(sequence.patterns.count)
        session.calculateScore(accuracy: avgAccuracy, isPerfect: isPerfect)
        
        // Save high score
        if session.currentScore > session.highScore {
            storage.saveHighScore(session.currentScore)
        }
    }
    
    // MARK: - Error Handling
    private func handleWrongInput() {
        hapticEngine.playError()
        session.applyWrongPatternPenalty()
        
        if session.phase == .gameOver {
            // Save final score
            if session.currentScore > session.highScore {
                storage.saveHighScore(session.currentScore)
                session.highScore = session.currentScore
            }
        }
    }
    
    // MARK: - Timing Penalties
    func checkTimingPenalty() {
        guard session.phase == .waitingForInput,
              let lastInput = session.lastInputTime else { return }
        
        let timeSinceLastInput = Date().timeIntervalSince(lastInput)
        
        // If user takes more than 2 seconds, apply penalty
        if timeSinceLastInput > 2.0 {
            session.applyTimingPenalty()
            hapticEngine.playWarning()
        }
    }
    
    // MARK: - Restart
    func restartGame() {
        startGame()
    }
    
    func returnToMenu() {
        session.reset()
        session.phase = .menu
    }
}
