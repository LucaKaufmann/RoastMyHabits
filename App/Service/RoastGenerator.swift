import Foundation
import OSLog

actor RoastGenerator {
    enum GenerationError: Equatable, LocalizedError {
        case noHabitData

        var errorDescription: String? {
            switch self {
            case .noHabitData:
                "There is no habit data to judge."
            }
        }
    }

    func generate(persona: Persona, habitData: [HabitSnapshot]) async throws -> String {
        guard habitData.isEmpty == false else {
            throw GenerationError.noHabitData
        }

        let prompt = buildPrompt(persona: persona, habitData: habitData)
        Logger.roast.debug("Generated roast prompt with \(habitData.count) habits.")
        Logger.roast.trace("\(prompt, privacy: .private)")

        try await Task.sleep(for: .milliseconds(250))
        return makeLocalRoast(persona: persona, habitData: habitData)
    }

    private func buildPrompt(persona: Persona, habitData: [HabitSnapshot]) -> String {
        let dataBlock = habitData
            .map { "- \($0.name): \($0.currentValue)/\($0.goal) \($0.unit)" }
            .joined(separator: "\n")

        return """
        <system>
        \(persona.systemPrompt)
        </system>
        <user>
        Here are my habits for today:
        \(dataBlock)

        Judge me.
        </user>
        """
    }

    private func makeLocalRoast(persona: Persona, habitData: [HabitSnapshot]) -> String {
        let totalGoal = habitData.reduce(0) { $0 + $1.goal }
        let totalProgress = habitData.reduce(0) { $0 + $1.currentValue }
        let completion = totalGoal == 0 ? 0 : Int((Double(totalProgress) / Double(totalGoal)) * 100)
        let weakest = habitData.min { lhs, rhs in
            completionRatio(for: lhs) < completionRatio(for: rhs)
        }
        let strongest = habitData.max { lhs, rhs in
            completionRatio(for: lhs) < completionRatio(for: rhs)
        }

        switch persona {
        case .disappointedParent:
            return """
            You are sitting at \(completion)% overall, which is somehow both effort and a cry for help. \(habitLine(for: weakest)) Meanwhile \(habitLine(for: strongest)), so clearly you do know how numbers work. Sigh.
            """
        case .hustleBro:
            return """
            CHAMP, you are operating at \(completion)% completion and calling it a strategy. \(habitLine(for: weakest)) \(habitLine(for: strongest)) Either lock in or accept that your calendar is running a hostile takeover on your ambitions.
            """
        case .genZBestie:
            return """
            Bestie, the scoreboard says \(completion)% and the vibe says "we tried a little." \(habitLine(for: weakest)) But \(habitLine(for: strongest)), so you did not fully flop. Honestly? Half slay, half jump scare.
            """
        }
    }

    private func completionRatio(for snapshot: HabitSnapshot) -> Double {
        guard snapshot.goal > 0 else {
            return 0
        }

        return Double(snapshot.currentValue) / Double(snapshot.goal)
    }

    private func habitLine(for snapshot: HabitSnapshot?) -> String {
        guard let snapshot else {
            return "There is nothing here to roast, which is its own problem."
        }

        return "\(snapshot.name) is sitting at \(snapshot.currentValue)/\(snapshot.goal) \(snapshot.unit)."
    }
}
