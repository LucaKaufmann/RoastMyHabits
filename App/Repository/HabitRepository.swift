import Foundation
import OSLog
import SwiftData

@ModelActor
actor HabitRepository {
    enum RepositoryError: Equatable, LocalizedError {
        case habitLimitReached

        var errorDescription: String? {
            switch self {
            case .habitLimitReached:
                "You already have five habits. Add discipline, not more tabs."
            }
        }
    }

    func fetchAll() throws -> [Habit] {
        let descriptor = FetchDescriptor<HabitRecord>(
            sortBy: [
                SortDescriptor(\.sortOrder),
                SortDescriptor(\.createdAt)
            ]
        )
        return try modelContext.fetch(descriptor).map(\.toDomain)
    }

    func insert(_ habit: Habit) throws {
        guard try count() < AppConfiguration.maxHabits else {
            Logger.habits.error("Habit insert rejected because limit was reached.")
            throw RepositoryError.habitLimitReached
        }

        let record = HabitRecord(
            id: habit.id,
            name: habit.name,
            goal: habit.goal,
            unit: habit.unit,
            createdAt: habit.createdAt,
            sortOrder: habit.sortOrder
        )

        modelContext.insert(record)
    }

    func delete(id: UUID) throws {
        guard let record = try fetchRecord(id: id) else {
            return
        }

        modelContext.delete(record)
    }

    func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<HabitRecord>())
    }

    private func fetchRecord(id: UUID) throws -> HabitRecord? {
        let descriptor = FetchDescriptor<HabitRecord>(
            predicate: #Predicate { record in
                record.id == id
            }
        )
        return try modelContext.fetch(descriptor).first
    }
}
