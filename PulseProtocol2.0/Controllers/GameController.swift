import Foundation
import Combine

// MARK: - Game Controller
class GameController: ObservableObject {
    @Published var session = GameSession()

    private let hapticEngine = HapticEngine.shared
    private let storage      = UserDefaultsManager.shared

    /// Records when the finger went DOWN on a button (single source of truth)
    private var tapStartTime: Date?

    init() {
        session.highScore = storage.getHighScore()
    }

    // MARK: - Game Flow

    func startGame() {
        print("🎮 startGame()")
        session.reset()
        session.highScore = storage.getHighScore()
        startNewRound()
    }

    func startNewRound() {
        session.startNewRound()

        guard let sequence = session.currentSequence else { return }

        // Play the haptic sequence, then switch to input phase
        hapticEngine.playSequence(sequence) { [weak self] in
            DispatchQueue.main.async {
                self?.session.phase            = .waitingForInput
                self?.session.patternStartTime = Date()
                self?.objectWillChange.send()
            }
        }

        // Force UI refresh so the "playingPattern" view appears immediately
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }

    // MARK: - Tap Handling (called by TapButton)

    func onTapDown(type: HapticType) {
        guard session.phase == .waitingForInput else { return }
        tapStartTime = Date()
        hapticEngine.playPattern(type)   // immediate feedback vibration
    }

    func onTapUp(type: HapticType) {
        guard session.phase == .waitingForInput,
              let start = tapStartTime else { return }

        let held = Date().timeIntervalSince(start)
        tapStartTime = nil

        print("👆 \(type.rawValue) held \(String(format: "%.3f", held))s")

        // Record the input
        session.recordInput(type: type, duration: held)

        // Validate
        if session.validateLastInput() {
            print("✅ correct")
            session.applyCorrect()

            if session.isRoundComplete() {
                // Whole round done correctly
                session.phase = .correct
                hapticEngine.playSuccess()

                if session.currentRound >= GameSession.maxRound {
                    // 🏆 Beat the game
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                        self?.session.phase = .gameOver   // reuse gameOver screen; score will show
                        self?.persistHighScore()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        self?.startNewRound()
                    }
                }
            }
            // else: more taps needed in this round, stay in waitingForInput
        } else {
            print("❌ wrong")
            hapticEngine.playError()
            session.applyWrong()       // sets phase = .gameOver
            persistHighScore()
        }
    }

    // MARK: - Persist

    private func persistHighScore() {
        if session.currentScore > storage.getHighScore() {
            storage.saveHighScore(session.currentScore)
        }
        session.highScore = storage.getHighScore()
    }

    // MARK: - Navigation helpers

    func restartGame() { startGame() }

    func returnToMenu() {
        session.reset()
        session.phase = .menu
    }
}
