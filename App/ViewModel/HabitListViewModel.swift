import Foundation
import Observation

@MainActor
@Observable
final class HabitListViewModel {
    struct HabitProgress: Identifiable, Equatable {
        let habit: Habit
        let currentValue: Int

        var id: UUID { habit.id }
        var goal: Int { habit.goal }
        var progress: Double {
            guard goal > 0 else {
                return 0
            }

            return min(Double(currentValue) / Double(goal), 1.0)
        }
    }

    private let habitRepository: HabitRepository
    private let dailyLogRepository: DailyLogRepository
    private let hapticService: HapticService

    var habits: [HabitProgress] = []
    var error: String?
    var isLoading = false

    init(
        habitRepository: HabitRepository,
        dailyLogRepository: DailyLogRepository,
        hapticService: HapticService
    ) {
        self.habitRepository = habitRepository
        self.dailyLogRepository = dailyLogRepository
        self.hapticService = hapticService
    }

    func load() async {
        await refresh()
    }

    func increment(_ habitID: UUID) async {
        do {
            let updatedLog = try await dailyLogRepository.increment(habitID: habitID)
            await refresh()
            if let progress = habits.first(where: { $0.id == habitID }), updatedLog.currentValue >= progress.goal {
                hapticService.playGoalCompleted()
            } else {
                hapticService.playIncrement()
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func decrement(_ habitID: UUID) async {
        do {
            _ = try await dailyLogRepository.decrement(habitID: habitID)
            await refresh()
            hapticService.playDecrement()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deleteHabit(_ habitID: UUID) async {
        do {
            try await habitRepository.delete(id: habitID)
            await refresh()
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let habits = habitRepository.fetchAll()
            async let logs = dailyLogRepository.allLogs()

            let (allHabits, allLogs) = try await (habits, logs)
            let logLookup = Dictionary(uniqueKeysWithValues: allLogs.map { ($0.habitID, $0.currentValue) })
            self.habits = allHabits.map { habit in
                HabitProgress(
                    habit: habit,
                    currentValue: logLookup[habit.id, default: 0]
                )
            }
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
