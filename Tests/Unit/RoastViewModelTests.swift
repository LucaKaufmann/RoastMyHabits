import Testing

@testable import RoastMyHabits

@Suite("RoastViewModel")
struct RoastViewModelTests {
    @Test("generates a local roast from habit data")
    @MainActor
    func generatesRoastText() async throws {
        let container = try TestModelContainer.make()
        let habitRepository = HabitRepository(modelContainer: container)
        let logRepository = DailyLogRepository(modelContainer: container)
        let hapticService = HapticService()
        let generator = RoastGenerator()
        let viewModel = RoastViewModel(
            habitRepository: habitRepository,
            dailyLogRepository: logRepository,
            roastGenerator: generator,
            hapticService: hapticService
        )

        let habit = Habit(name: "Walk", goal: 5, unit: "miles")
        try await habitRepository.insert(habit)
        _ = try await logRepository.increment(habitID: habit.id)

        await viewModel.judgeMe(persona: .genZBestie)

        #expect(viewModel.isPresenting)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.roastText.contains("Walk"))
    }
}
