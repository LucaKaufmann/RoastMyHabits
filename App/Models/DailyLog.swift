import Foundation

struct DailyLog: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let habitID: UUID
    let date: Date
    var currentValue: Int

    init(
        id: UUID = UUID(),
        habitID: UUID,
        date: Date,
        currentValue: Int = 0
    ) {
        self.id = id
        self.habitID = habitID
        self.date = Calendar.current.startOfDay(for: date)
        self.currentValue = currentValue
    }
}
