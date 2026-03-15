import Foundation
import OSLog
import UIKit

@MainActor
final class HapticService {
    func playIncrement() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: HapticTokens.incrementIntensity)
        Logger.haptics.debug("Played increment haptic.")
    }

    func playDecrement() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: HapticTokens.decrementIntensity)
        Logger.haptics.debug("Played decrement haptic.")
    }

    func playRoast() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        Logger.haptics.debug("Played roast haptic.")
    }

    func playGoalCompleted() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        Logger.haptics.debug("Played goal completion haptic.")
    }
}
