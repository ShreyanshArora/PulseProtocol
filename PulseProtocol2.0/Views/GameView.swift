import SwiftUI

// MARK: - Game View
struct GameView: View {
    @StateObject private var controller = GameController()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.black.opacity(0.15), Color.black.opacity(0.45)],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()

            // Phase-based content
            VStack(spacing: 40) {
                switch controller.session.phase {
                case .menu:            menuView
                case .playingPattern:  listeningView
                case .waitingForInput: InputView(controller: controller)
                case .correct:         correctView
                case .gameOver:        gameOverView
                case .instructions:    instructionsView
                }
            }
            .padding()

            // Score popup floats on top of everything
            if let popup = controller.session.activePopup {
                ScorePopupView(popup: popup)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal:   .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .navigationBarBackButtonHidden(true)
        .animation(.easeOut(duration: 0.3), value: controller.session.activePopup?.id)
    }

    // ─────────────────────────────────────
    // MARK: - Menu
    // ─────────────────────────────────────
    private var menuView: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("PulseProtocol")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Feel the Rhythm")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            // High Score
            VStack(spacing: 10) {
                Text("HIGH SCORE")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                Text("\(controller.session.highScore)")
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.1)))

            Spacer()

            // Start
            Button(action: { controller.startGame() }) {
                Text("START GAME")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            }
            .padding(.horizontal)

            // Back
            Button(action: { dismiss() }) {
                Text("BACK")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 10)

            Spacer()
        }
    }

    // ─────────────────────────────────────
    // MARK: - Listening (pattern playing)
    // ─────────────────────────────────────
    private var listeningView: some View {
        VStack(spacing: 40) {
            Spacer()

            PulsingCircle()

            Text("Feel the Pattern…")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.white)

            if let seq = controller.session.currentSequence {
                Text("\(seq.patterns.count) taps coming")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.45))
            }

            Spacer()
        }
    }



    // ─────────────────────────────────────
    // MARK: - Correct
    // ─────────────────────────────────────
    private var correctView: some View {
        VStack {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Round \(controller.session.currentRound) Complete!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()
        }
    }

    // ─────────────────────────────────────
    // MARK: - Game Over
    // ─────────────────────────────────────
    private var gameOverView: some View {
        VStack(spacing: 30) {
            Spacer()

            let wonTheGame = controller.session.currentRound >= GameSession.maxRound

            Text(wonTheGame ? "🏆 You Beat It!" : "Game Over")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            VStack(spacing: 15) {
                Text("FINAL SCORE")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))

                Text("\(controller.session.currentScore)")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                if controller.session.currentScore == controller.session.highScore
                    && controller.session.currentScore > 0 {
                    Text("🏆 NEW HIGH SCORE!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.yellow)
                }
            }
            .padding(30)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.1)))

            Text("Reached Round \(controller.session.currentRound)")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            VStack(spacing: 15) {
                Button(action: { controller.restartGame() }) {
                    Text("PLAY AGAIN")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                }

                Button(action: { controller.returnToMenu() }) {
                    Text("MENU")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: 2))
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    // ─────────────────────────────────────
    // MARK: - Instructions
    // ─────────────────────────────────────
    private var instructionsView: some View {
        VStack {
            Text("Instructions")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}

// ═══════════════════════════════════════════
// MARK: - Pulsing Circle
// ═══════════════════════════════════════════
struct PulsingCircle: View {
    @State private var animating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 140, height: 140)

            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 140, height: 140)
                .scaleEffect(animating ? 1.7 : 1.0)
                .opacity(animating ? 0.0 : 0.7)
                .animation(
                    .easeOut(duration: 1.2).repeatForever(autoreverses: false),
                    value: animating
                )
        }
        .onAppear { animating = true }
    }
}

// ═══════════════════════════════════════════
// MARK: - Score Popup (+10 / -5)
// ═══════════════════════════════════════════
struct ScorePopupView: View {
    let popup  : ScorePopup
    @State private var offset  : CGFloat = 0
    @State private var opacity : Double  = 1.0

    var body: some View {
        Text(popup.text)
            .font(.system(size: 38, weight: .bold, design: .rounded))
            .foregroundColor(popup.isPositive ? .green : .red)
            .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 2)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.9)) {
                    offset  = -130
                    opacity =  0.0
                }
            }
    }
}

// ═══════════════════════════════════════════
#Preview {
    GameView()
}
