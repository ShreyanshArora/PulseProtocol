import SwiftUI

// MARK: - Game View
struct GameView: View {
    @StateObject private var controller = GameController()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // ── Background ──
            LinearGradient(
                colors: [Color.black.opacity(0.15), Color.black.opacity(0.45)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            // ── Phase-based content ──
            VStack(spacing: 40) {
                switch controller.session.phase {
                case .menu:           menuView
                case .playingPattern: listeningView
                case .waitingForInput: inputView
                case .correct:        correctView
                case .gameOver:       gameOverView
                case .instructions:   instructionsView
                }
            }
            .padding()

            // ── Score popup overlay (floats on top of everything) ──
            if let popup = controller.session.activePopup {
                ScorePopupView(popup: popup)
                    .transition(.asymmetric(
                        insertion:  .move(edge: .bottom).combined(with: .opacity),
                        removal:    .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .navigationBarBackButtonHidden(true)
        .animation(.easeOut(duration: 0.3), value: controller.session.activePopup?.id)
    }

    // ──────────────────────────────────────────
    // MARK: - Menu
    // ──────────────────────────────────────────
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

            // High Score card
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

            Button(action: { controller.startGame() }) {
                Text("START GAME")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            }
            .padding(.horizontal)

            Button(action: { dismiss() }) {
                Text("BACK")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 10)

            Spacer()
        }
    }

    // ──────────────────────────────────────────
    // MARK: - Listening (pattern playing)
    // ──────────────────────────────────────────
    private var listeningView: some View {
        VStack(spacing: 40) {
            Spacer()

            PulsingCircle()

            Text("Feel the Pattern…")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.white)

            // Show how many taps are coming
            if let seq = controller.session.currentSequence {
                Text("\(seq.patterns.count) taps")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()
        }
    }

    // ──────────────────────────────────────────
    // MARK: - Input
    // ──────────────────────────────────────────
    private var inputView: some View {
        VStack(spacing: 24) {
            // Score & Round header
            HStack {
                VStack(alignment: .leading) {
                    Text("SCORE")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(controller.session.currentScore)")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("ROUND")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(controller.session.currentRound)")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)

            Spacer(minLength: 8)

            Text("Repeat the Pattern")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white)

            // ── Pattern guide pills ──
            PatternGuide(sequence:  controller.session.currentSequence,
                         answered: controller.session.userInputs.count)

            Spacer(minLength: 8)

            // ── Tap Buttons ──
            HStack(spacing: 14) {
                TapButton(type: .short,  label: "SHORT", controller: controller)
                TapButton(type: .medium, label: "MED",   controller: controller)
                TapButton(type: .long,   label: "LONG",  controller: controller)
            }
            .padding(.horizontal)

            // Duration hint
            Text("Tap & hold for the right duration")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.4))

            Spacer(minLength: 16)
        }
    }

    // ──────────────────────────────────────────
    // MARK: - Correct
    // ──────────────────────────────────────────
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

    // ──────────────────────────────────────────
    // MARK: - Game Over
    // ──────────────────────────────────────────
    private var gameOverView: some View {
        VStack(spacing: 30) {
            Spacer()

            let wonTheGame = controller.session.currentRound >= GameSession.maxRound

            Text(wonTheGame ? "🏆 You Beat It!" : "Game Over")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            VStack(spacing: 12) {
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

    // ──────────────────────────────────────────
    // MARK: - Instructions (placeholder)
    // ──────────────────────────────────────────
    private var instructionsView: some View {
        VStack {
            Text("Instructions")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}

// ============================================================
// MARK: - Pulsing Circle (listening animation)
// ============================================================
struct PulsingCircle: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 140, height: 140)

            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 140, height: 140)
                .scaleEffect(pulse ? 1.6 : 1.0)
                .opacity(pulse ? 0.0 : 0.8)
                .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: pulse)
        }
        .onAppear { pulse = true }
    }
}

// ============================================================
// MARK: - Pattern Guide (pills showing the sequence)
// ============================================================
struct PatternGuide: View {
    let sequence : HapticSequence?
    let answered : Int          // how many the user has already tapped

    var body: some View {
        guard let seq = sequence else { return AnyView(EmptyView()) }

        return AnyView(
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<seq.patterns.count, id: \.self) { i in
                        let pat   = seq.patterns[i]
                        let done  = i < answered
                        let next  = i == answered   // the one the user needs to tap now

                        Text(pat.rawValue.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(done ? .black : (next ? .black : .white))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(done  ? Color.green
                                        : next  ? Color.white
                                                : Color.white.opacity(0.15))
                            )
                            .overlay(
                                next ? RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2) : nil
                            )
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 36)
        )
    }
}

// ============================================================
// MARK: - Tap Button
// ============================================================
struct TapButton: View {
    let type       : HapticType
    let label      : String
    let controller : GameController

    @State private var isPressed = false

    var body: some View {
        Text(label)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isPressed ? 0.55 : 1.0))
            )
            .scaleEffect(isPressed ? 0.93 : 1.0)
            .animation(.easeOut(duration: 0.1), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        controller.onTapDown(type: type)
                    }
                    .onEnded { _ in
                        guard isPressed else { return }
                        isPressed = false
                        controller.onTapUp(type: type)
                    }
            )
    }
}

// ============================================================
// MARK: - Score Popup (+10 / -5 floating label)
// ============================================================
struct ScorePopupView: View {
    let popup: ScorePopup
    @State private var offset: CGFloat = 0
    @State private var opacity: Double  = 1.0

    var body: some View {
        Text(popup.text)
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundColor(popup.isPositive ? .green : .red)
            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 2)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    offset  = -120
                    opacity =  0.0
                }
            }
    }
}

// ============================================================
#Preview {
    GameView()
}
