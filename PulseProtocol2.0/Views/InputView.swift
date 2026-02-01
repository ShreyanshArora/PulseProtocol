//
//  InputView.swift
//  PulseProtocol2.0
//
//  Created by Shreyansh on 29/01/26.
//

import SwiftUI

struct InputView: View {
    @ObservedObject var controller: GameController
    @State private var isPressed = false
    @State private var holdDuration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var pulseScale = 1.0

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SCORE")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        Text("\(controller.session.currentScore)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("ROUND")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        Text("\(controller.session.currentRound)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)

                Spacer()

                // Instructions
                VStack(spacing: 20) {
                    Text("Tap and Hold")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Match each vibration length")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))

                    // Pattern progress indicators
                    VStack(spacing: 15) {
                        Text("PATTERN PROGRESS")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))

                        HStack(spacing: 15) {
                            if let sequence = controller.session.currentSequence {
                                ForEach(0..<sequence.patterns.count, id: \.self) { index in
                                    PatternIndicator(
                                        index: index,
                                        expectedPattern: sequence.patterns[index],
                                        userInputs: controller.session.userInputs,
                                        isCurrent: index == controller.session.userInputs.count
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "4FACFE").opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 30)
                }

                Spacer()

                // Large Tap Area
                VStack(spacing: 20) {
                    Text(isPressed ? "HOLDING..." : "TAP & HOLD HERE")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(isPressed ? Color(hex: "4FACFE") : .white)

                    ZStack {
                        // Background pulse
                        Circle()
                            .fill(Color(hex: "4FACFE").opacity(isPressed ? 0.3 : 0.15))
                            .frame(width: 200, height: 200)
                            .scaleEffect(pulseScale)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: pulseScale
                            )

                        // Main circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isPressed ?
                                        [Color(hex: "4FACFE").opacity(0.8), Color(hex: "00F2FE").opacity(0.8)] :
                                        [Color(hex: "4FACFE").opacity(0.4), Color(hex: "00F2FE").opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 180, height: 180)
                            .overlay(
                                Circle()
                                    .stroke(
                                        isPressed ? Color(hex: "4FACFE") : Color(hex: "4FACFE").opacity(0.5),
                                        lineWidth: isPressed ? 4 : 2
                                    )
                            )

                        // Content
                        VStack(spacing: 12) {
                            if isPressed {
                                Text(String(format: "%.2fs", holdDuration))
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)

                                Text(durationLabel)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(durationColor)
                            } else {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.8))

                                Text("Press & Hold")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .shadow(color: Color(hex: "4FACFE").opacity(isPressed ? 0.5 : 0.3), radius: 20)

                    // Timing guide
                    HStack(spacing: 30) {
                        VStack(spacing: 4) {
                            Text("SHORT")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "FFD700"))
                            Text("< 0.2s")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }

                        VStack(spacing: 4) {
                            Text("MEDIUM")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "FFA500"))
                            Text("0.2 – 0.45s")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }

                        VStack(spacing: 4) {
                            Text("LONG")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "FF6B6B"))
                            Text("> 0.45s")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(.top, 10)

                    // Scoring guide
                    HStack(spacing: 20) {
                        ScoreLabel(icon: "checkmark.circle.fill", text: "Correct: +10", color: .green)
                        ScoreLabel(icon: "xmark.circle.fill",     text: "Wrong: -5",   color: .red)
                    }
                    .padding(.top, 5)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            pulseScale = 1.1
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed && controller.session.phase == .waitingForInput {
                        isPressed = true
                        holdDuration = 0

                        // Fire onTapDown with .short as placeholder — actual type decided on release
                        controller.onTapDown(type: .short)

                        // Start live duration counter
                        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                            holdDuration += 0.01
                        }
                    }
                }
                .onEnded { _ in
                    if isPressed {
                        isPressed = false
                        timer?.invalidate()
                        timer = nil

                        // Determine final type from how long they actually held
                        let finalType = determineHapticType(duration: holdDuration)
                        controller.onTapUp(type: finalType)

                        // Reset counter after a beat
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            holdDuration = 0
                        }
                    }
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }

    // Determine haptic type from hold duration
    private func determineHapticType(duration: TimeInterval) -> HapticType {
        if duration < 0.2 {
            return .short
        } else if duration < 0.45 {
            return .medium
        } else {
            return .long
        }
    }

    private var durationLabel: String {
        if holdDuration < 0.2      { return "SHORT" }
        else if holdDuration < 0.45 { return "MEDIUM" }
        else                        { return "LONG" }
    }

    private var durationColor: Color {
        if holdDuration < 0.2      { return Color(hex: "FFD700") }
        else if holdDuration < 0.45 { return Color(hex: "FFA500") }
        else                        { return Color(hex: "FF6B6B") }
    }
}

// ============================================================
// MARK: - Pattern Indicator
// ============================================================
struct PatternIndicator: View {
    let index: Int
    let expectedPattern: HapticType
    let userInputs: [UserInput]
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 50, height: 50)

                if index < userInputs.count {
                    // Already tapped — show green check or red X
                    let userInput = userInputs[index]
                    let isCorrect = userInput.type == expectedPattern

                    Circle()
                        .fill(isCorrect ? Color(hex: "4FACFE") : Color(hex: "FF6B6B"))
                        .frame(width: 40, height: 40)

                    Image(systemName: isCorrect ? "checkmark" : "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else if isCurrent {
                    // This is the one they need to tap next
                    Circle()
                        .fill(Color(hex: "4FACFE").opacity(0.5))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "4FACFE"), lineWidth: 3)
                        )
                } else {
                    // Future — not yet
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                }
            }

            Text(expectedPattern.rawValue.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.7))

            Text(String(format: "%.2fs", expectedPattern.targetPressDuration))
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

#Preview {
    InputView(controller: GameController())
}
