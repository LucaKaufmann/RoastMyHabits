import Foundation
import SwiftData

@ModelActor
actor DailyLogRepository {
    enum RepositoryError: Equatable, LocalizedError {
        case missingHabit(UUID)

        var errorDescription: String? {
            switch self {
            case let .missingHabit(id):
                "Could not find habit \(id.uuidString)."
            }
        }
    }

    func allLogs(on date: Date = .now) throws -> [DailyLog] {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<DailyLogRecord>(
            predicate: #Predicate { record in
                record.date == normalizedDate
            }
        )
        return try modelContext.fetch(descriptor).map(\.toDomain)
    }

    func todayLog(for habitID: UUID, on date: Date = .now) throws -> DailyLog {
        let normalizedDate = Calendar.current.startOfDay(for: date)

        if let existing = try fetchLog(habitID: habitID, date: normalizedDate) {
            return existing.toDomain()
        }

        let habit = try fetchHabitRecord(id: habitID)
        let record = DailyLogRecord(
            id: UUID(),
            habitID: habitID,
            date: normalizedDate,
            currentValue: 0,
            habit: habit
        )

        modelContext.insert(record)
        return record.toDomain()
    }

    func increment(habitID: UUID, on date: Date = .now) throws -> DailyLog {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        let record = try fetchOrCreateLog(habitID: habitID, date: normalizedDate)
        record.currentValue += 1
        return record.toDomain()
    }

    func decrement(habitID: UUID, on date: Date = .now) throws -> DailyLog {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        let record = try fetchOrCreateLog(habitID: habitID, date: normalizedDate)
        record.currentValue = max(0, record.currentValue - 1)
        return record.toDomain()
    }

    private func fetchOrCreateLog(habitID: UUID, date: Date) throws -> DailyLogRecord {
        if let existing = try fetchLog(habitID: habitID, date: date) {
            return existing
        }

        let habit = try fetchHabitRecord(id: habitID)
        let record = DailyLogRecord(
            id: UUID(),
            habitID: habitID,
            date: date,
            currentValue: 0,
            habit: habit
        )

        modelContext.insert(record)
        return record
    }

    private func fetchLog(habitID: UUID, date: Date) throws -> DailyLogRecord? {
        let descriptor = FetchDescriptor<DailyLogRecord>(
            predicate: #Predicate { record in
                record.habitID == habitID && record.date == date
            }
        )
        return try modelContext.fetch(descriptor).first
    }

    private func fetchHabitRecord(id: UUID) throws -> HabitRecord {
        let descriptor = FetchDescriptor<HabitRecord>(
            predicate: #Predicate { record in
                record.id == id
            }
        )

        guard let record = try modelContext.fetch(descriptor).first else {
            throw RepositoryError.missingHabit(id)
        }

        return record
    }
}
