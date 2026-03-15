import Foundation

struct HabitSnapshot: Equatable, Sendable {
    let name: String
    let currentValue: Int
    let goal: Int
    let unit: String
}
