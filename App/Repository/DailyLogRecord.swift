import Foundation
import SwiftData

@Model
final class DailyLogRecord {
    @Attribute(.unique) var id: UUID
    var habitID: UUID
    var date: Date
    var currentValue: Int
    var habit: HabitRecord?

    init(
        id: UUID,
        habitID: UUID,
        date: Date,
        currentValue: Int,
        habit: HabitRecord?
    ) {
        self.id = id
        self.habitID = habitID
        self.date = date
        self.currentValue = currentValue
        self.habit = habit
    }

    func toDomain() -> DailyLog {
        DailyLog(
            id: id,
            habitID: habitID,
            date: date,
            currentValue: currentValue
        )
    }
}
