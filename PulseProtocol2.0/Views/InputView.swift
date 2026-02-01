//
//  InputView.swift
//  PulseProtocol2.0
//

import SwiftUI

struct InputView: View {

    @ObservedObject var controller: GameController

    @State private var isPressed = false
    @State private var holdDuration: TimeInterval = 0
    @State private var timer: Timer?

    // GAME FEEL
    @State private var streak = 0
    @State private var feedbackText = ""
    @State private var feedbackColor: Color = .white
    @State private var showFeedback = false

    var body: some View {
        ZStack {

            // FULL SCREEN BACKGROUND
            LinearGradient(
                colors: [Color(hex: "0A0E27"), Color(hex: "1A1F3A")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {

                // HEADER
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SCORE")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        Text("\(controller.session.currentScore)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("ROUND")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        Text("\(controller.session.currentRound)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)

                // STREAK
                if streak > 1 {
                    Text("🔥 \(streak) STREAK")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)
                        .transition(.scale)
                }

                Spacer()

                // CENTER FEEDBACK
                if showFeedback {
                    Text(feedbackText)
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundColor(feedbackColor)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // TAP AREA
                ZStack {

                    // GLOW
                    Circle()
                        .stroke(feedbackColor.opacity(isPressed ? 0.9 : 0.3),
                                lineWidth: isPressed ? 10 : 3)
                        .frame(width: 220, height: 220)
                        .blur(radius: isPressed ? 12 : 0)
                        .animation(.easeOut(duration: 0.2), value: isPressed)

                    // BASE
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isPressed
                                    ? [Color(hex: "4FACFE"), Color(hex: "00F2FE")]
                                    : [Color(hex: "4FACFE").opacity(0.4),
                                       Color(hex: "00F2FE").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 190, height: 190)

                    VStack(spacing: 10) {
                        if isPressed {
                            Text(String(format: "%.2fs", holdDuration))
                                .font(.system(size: 34, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)

                            Text("MATCH TIMING")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                        } else {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 42))
                                .foregroundColor(.white.opacity(0.85))

                            Text("PRESS & HOLD")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }

        // FEEDBACK DRIVER
        .onChange(of: controller.session.activePopup?.id) { _ in
            guard let popup = controller.session.activePopup else { return }

            if popup.isPositive {
                streak += 1

                if popup.text.contains("10") {
                    feedbackText = "PERFECT"
                    feedbackColor = .green
                } else if popup.text.contains("8") {
                    feedbackText = "GREAT"
                    feedbackColor = .blue
                } else {
                    feedbackText = "GOOD"
                    feedbackColor = .yellow
                }
            } else {
                streak = 0
                feedbackText = "MISS"
                feedbackColor = .red
            }

            showFeedback = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showFeedback = false
            }
        }

        // TOUCH HANDLING
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed && controller.session.phase == .waitingForInput {
                        isPressed = true
                        holdDuration = 0

                        let index = controller.session.userInputs.count
                        let expected = controller.session.currentSequence!.patterns[index]

                        controller.onTapDown(type: expected)

                        timer = Timer.scheduledTimer(withTimeInterval: 0.01,
                                                     repeats: true) { _ in
                            holdDuration += 0.01
                        }
                    }
                }
                .onEnded { _ in
                    if isPressed {
                        isPressed = false
                        timer?.invalidate()
                        timer = nil

                        let index = controller.session.userInputs.count
                        let expected = controller.session.currentSequence!.patterns[index]

                        controller.onTapUp(type: expected)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            holdDuration = 0
                        }
                    }
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

#Preview {
    InputView(controller: GameController())
}
