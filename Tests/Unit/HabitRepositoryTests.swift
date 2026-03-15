import Testing

@testable import RoastMyHabits

@Suite("HabitRepository")
struct HabitRepositoryTests {
    @Test("enforces the five habit cap")
    @MainActor
    func enforcesHabitLimit() async throws {
        let repository = HabitRepository(modelContainer: try TestModelContainer.make())

        for index in 0..<AppConfiguration.maxHabits {
            try await repository.insert(
                Habit(name: "Habit \(index)", goal: 1, unit: "times", sortOrder: index)
            )
        }

        do {
            try await repository.insert(Habit(name: "Too many", goal: 1, unit: "times", sortOrder: 99))
            Issue.record("Expected the repository to reject the sixth habit.")
        } catch let error as HabitRepository.RepositoryError {
            #expect(error == .habitLimitReached)
        }
    }

    @Test("returns habits in sort order")
    @MainActor
    func fetchesSortedHabits() async throws {
        let repository = HabitRepository(modelContainer: try TestModelContainer.make())
        try await repository.insert(Habit(name: "Second", goal: 1, unit: "pages", sortOrder: 1))
        try await repository.insert(Habit(name: "First", goal: 1, unit: "pages", sortOrder: 0))

        let habits = try await repository.fetchAll()

        #expect(habits.map(\.name) == ["First", "Second"])
    }
}
