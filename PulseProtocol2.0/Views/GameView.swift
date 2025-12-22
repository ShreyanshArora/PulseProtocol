import SwiftUI

struct GameView: View {
    @StateObject private var controller = GameController()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Content based on game phase
            VStack(spacing: 40) {
                
                // Debug indicator
                Text("Phase: \(phaseDescription)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                
                Group {
                    if controller.session.phase == .menu {
                        menuView
                    } else if controller.session.phase == .playingPattern {
                        listeningView
                    } else if controller.session.phase == .waitingForInput {
                        inputView
                    } else if controller.session.phase == .correct {
                        correctView
                    } else if controller.session.phase == .gameOver {
                        gameOverView
                    } else {
                        instructionsView
                    }
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("GameView appeared, phase: \(controller.session.phase)")
        }
    }
    
    private var phaseDescription: String {
        switch controller.session.phase {
        case .menu: return "menu"
        case .playingPattern: return "playingPattern"
        case .waitingForInput: return "waitingForInput"
        case .correct: return "correct"
        case .gameOver: return "gameOver"
        case .instructions: return "instructions"
        }
    }
    
    // MARK: - Menu View
    private var menuView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Title
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
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )
            
            Spacer()
            
            // Start Button
            Button(action: {
                print("Start button tapped") // Debug
                controller.startGame()
                print("Game phase: \(controller.session.phase)") // Debug
            }) {
                Text("START GAME")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
            }
            .padding(.horizontal)
            
            // Back to Main Menu
            Button(action: {
                dismiss()
            }) {
                Text("BACK")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 10)
            
            Spacer()
        }
    }
    
    // MARK: - Listening View
    private var listeningView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Pulsing Circle
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 150, height: 150)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .scaleEffect(1.5)
                        .opacity(0)
                        .animation(
                            Animation.easeOut(duration: 1.0)
                                .repeatForever(autoreverses: false),
                            value: controller.session.phase
                        )
                )
            
            Text("Feel the Pattern...")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    // MARK: - Input View
    private var inputView: some View {
        VStack(spacing: 30) {
            // Score Header
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
            
            Spacer()
            
            // Lives
            HStack(spacing: 15) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index < controller.session.livesRemaining ? Color.white : Color.white.opacity(0.2))
                        .frame(width: 12, height: 12)
                }
            }
            
            Text("Repeat the Pattern")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            // Pattern Progress
            HStack(spacing: 8) {
                if let sequence = controller.session.currentSequence {
                    ForEach(0..<sequence.patterns.count, id: \.self) { index in
                        Circle()
                            .fill(index < controller.session.userInputs.count ? Color.green : Color.white.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(.bottom, 40)
            
            Spacer()
            
            // Input Buttons
            HStack(spacing: 20) {
                // Short Tap
                TapButton(type: .short, label: "SHORT", controller: controller)
                
                // Medium Tap
                TapButton(type: .medium, label: "MED", controller: controller)
                
                // Long Tap
                TapButton(type: .long, label: "LONG", controller: controller)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Correct View
    private var correctView: some View {
        VStack {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Perfect!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    // MARK: - Game Over View
    private var gameOverView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Game Over")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                Text("FINAL SCORE")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("\(controller.session.currentScore)")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                if controller.session.currentScore == controller.session.highScore && controller.session.currentScore > 0 {
                    Text("🏆 NEW HIGH SCORE!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.yellow)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )
            
            Text("Round: \(controller.session.currentRound)")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            // Buttons
            VStack(spacing: 15) {
                Button(action: {
                    print("🔄 Restarting game...")
                    controller.restartGame()
                }) {
                    Text("PLAY AGAIN")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                }
                
                Button(action: {
                    print("🏠 Returning to menu...")
                    controller.returnToMenu()
                }) {
                    Text("MENU")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Instructions View
    private var instructionsView: some View {
        VStack {
            Text("Instructions")
                .font(.title)
            // Add instructions here
        }
    }
}

// MARK: - Tap Button Component
struct TapButton: View {
    let type: HapticType
    let label: String
    let controller: GameController
    
    @State private var isPressed = false
    @State private var pressStartTime: Date?
    
    var body: some View {
        Text(label)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isPressed ? 0.6 : 1.0))
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            pressStartTime = Date()
                            controller.onTapDown(type: type)
                            print("🔵 Button \(label) pressed")
                        }
                    }
                    .onEnded { _ in
                        if isPressed {
                            isPressed = false
                            controller.onTapUp(type: type)
                            print("🔴 Button \(label) released")
                        }
                    }
            )
    }
}

#Preview {
    GameView()
}
