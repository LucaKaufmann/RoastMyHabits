import Foundation
import SwiftData

@Model
final class HabitRecord {
    @Attribute(.unique) var id: UUID
    var name: String
    var goal: Int
    var unit: String
    var createdAt: Date
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \DailyLogRecord.habit)
    var dailyLogs: [DailyLogRecord]

    init(
        id: UUID,
        name: String,
        goal: Int,
        unit: String,
        createdAt: Date,
        sortOrder: Int
    ) {
        self.id = id
        self.name = name
        self.goal = goal
        self.unit = unit
        self.createdAt = createdAt
        self.sortOrder = sortOrder
        self.dailyLogs = []
    }

    func toDomain() -> Habit {
        Habit(
            id: id,
            name: name,
            goal: goal,
            unit: unit,
            createdAt: createdAt,
            sortOrder: sortOrder
        )
    }
}
