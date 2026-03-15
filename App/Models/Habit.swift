import Foundation

struct Habit: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var goal: Int
    var unit: String
    var createdAt: Date
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        goal: Int,
        unit: String,
        createdAt: Date = .now,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.goal = goal
        self.unit = unit
        self.createdAt = createdAt
        self.sortOrder = sortOrder
    }
}
