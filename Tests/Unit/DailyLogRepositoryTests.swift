import Foundation
import Testing

@testable import RoastMyHabits

@Suite("DailyLogRepository")
struct DailyLogRepositoryTests {
    @Test("creates logs with normalized dates")
    @MainActor
    func normalizesDates() async throws {
        let container = try TestModelContainer.make()
        let habitRepository = HabitRepository(modelContainer: container)
        let logRepository = DailyLogRepository(modelContainer: container)
        let date = Date(timeIntervalSince1970: 123_456)
        let habit = Habit(name: "Water", goal: 8, unit: "glasses")

        try await habitRepository.insert(habit)
        let log = try await logRepository.todayLog(for: habit.id, on: date)

        #expect(log.date == Calendar.current.startOfDay(for: date))
        #expect(log.currentValue == 0)
    }

    @Test("decrement never drops below zero")
    @MainActor
    func floorsAtZero() async throws {
        let container = try TestModelContainer.make()
        let habitRepository = HabitRepository(modelContainer: container)
        let logRepository = DailyLogRepository(modelContainer: container)
        let habit = Habit(name: "Read", goal: 10, unit: "pages")

        try await habitRepository.insert(habit)
        let log = try await logRepository.decrement(habitID: habit.id)

        #expect(log.currentValue == 0)
    }
}
