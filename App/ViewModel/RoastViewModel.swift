import Foundation
import Observation

@MainActor
@Observable
final class RoastViewModel {
    private let habitRepository: HabitRepository
    private let dailyLogRepository: DailyLogRepository
    private let roastGenerator: RoastGenerator
    private let hapticService: HapticService

    var activePersona: Persona = .disappointedParent
    var roastText = ""
    var error: String?
    var isGenerating = false
    var isPresenting = false

    init(
        habitRepository: HabitRepository,
        dailyLogRepository: DailyLogRepository,
        roastGenerator: RoastGenerator,
        hapticService: HapticService
    ) {
        self.habitRepository = habitRepository
        self.dailyLogRepository = dailyLogRepository
        self.roastGenerator = roastGenerator
        self.hapticService = hapticService
    }

    func judgeMe(persona: Persona) async {
        isPresenting = true
        isGenerating = true
        activePersona = persona
        roastText = ""
        error = nil

        do {
            async let habits = habitRepository.fetchAll()
            async let logs = dailyLogRepository.allLogs()
            let snapshots = try await makeSnapshots(habits: habits, logs: logs)
            roastText = try await roastGenerator.generate(persona: persona, habitData: snapshots)
            hapticService.playRoast()
        } catch {
            roastText = "Even the AI is disappointed. Try again."
            self.error = error.localizedDescription
        }

        isGenerating = false
    }

    func dismiss() {
        isPresenting = false
        roastText = ""
        error = nil
    }

    private func makeSnapshots(
        habits: [Habit],
        logs: [DailyLog]
    ) -> [HabitSnapshot] {
        let progressLookup = Dictionary(uniqueKeysWithValues: logs.map { ($0.habitID, $0.currentValue) })
        return habits.map { habit in
            HabitSnapshot(
                name: habit.name,
                currentValue: progressLookup[habit.id, default: 0],
                goal: habit.goal,
                unit: habit.unit
            )
        }
    }
}
