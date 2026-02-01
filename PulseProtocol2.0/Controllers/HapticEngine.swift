//
//  HapticEngine.swift
//  PulseProtocol2.0
//
//  Created by Shreyansh on 22/12/25.
//

import UIKit
import CoreHaptics

// MARK: - Haptic Engine Controller
class HapticEngine {
    static let shared = HapticEngine()

    private var engine          : CHHapticEngine?
    private var impactGenerator : UIImpactFeedbackGenerator?

    private init() { setupHaptics() }

    // MARK: - Setup
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("⚠️ Device doesn't support haptics")
            return
        }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            impactGenerator = UIImpactFeedbackGenerator(style: .medium)
            impactGenerator?.prepare()
        } catch {
            print("⚠️ Haptic engine start failed: \(error)")
        }
    }

    // MARK: - Play a single pattern vibration
    func playPattern(_ type: HapticType) {
        guard let engine = engine else {
            impactGenerator?.impactOccurred(intensity: type.intensity)
            return
        }
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity,
                                                   value: Float(type.intensity))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness,
                                                   value: type == .short ? 0.9 : 0.4)
            let event = CHHapticEvent(eventType: .hapticContinuous,
                                      parameters: [intensity, sharpness],
                                      relativeTime: 0,
                                      duration: type.duration)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player  = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("⚠️ playPattern failed: \(error)")
            impactGenerator?.impactOccurred(intensity: type.intensity)
        }
    }

    // MARK: - Play full sequence then call completion
    func playSequence(_ sequence: HapticSequence, completion: @escaping () -> Void) {
        var delay: TimeInterval = 0.3   // short lead-in pause

        for pattern in sequence.patterns {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.playPattern(pattern)
            }
            delay += pattern.duration + 0.35   // pattern length + gap
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.2) {
            completion()
        }
    }

    // MARK: - Feedback
    func playSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    func playError() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    func playWarning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func stop() { engine?.stop() }
}
