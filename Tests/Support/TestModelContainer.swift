import SwiftData

@MainActor
enum TestModelContainer {
    static func make() throws -> ModelContainer {
        let schema = Schema([
            HabitRecord.self,
            DailyLogRecord.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: configuration)
    }
}
