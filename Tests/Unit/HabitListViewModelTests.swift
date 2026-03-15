import Testing

@testable import RoastMyHabits

@Suite("HabitListViewModel")
struct HabitListViewModelTests {
    @Test("loads and updates progress")
    @MainActor
    func loadsHabitProgress() async throws {
        let container = try TestModelContainer.make()
        let habitRepository = HabitRepository(modelContainer: container)
        let logRepository = DailyLogRepository(modelContainer: container)
        let hapticService = HapticService()
        let viewModel = HabitListViewModel(
            habitRepository: habitRepository,
            dailyLogRepository: logRepository,
            hapticService: hapticService
        )

        let habit = Habit(name: "Stretch", goal: 2, unit: "sets")
        try await habitRepository.insert(habit)

        await viewModel.load()
        #expect(viewModel.habits.first?.currentValue == 0)

        await viewModel.increment(habit.id)
        #expect(viewModel.habits.first?.currentValue == 1)
    }
}
