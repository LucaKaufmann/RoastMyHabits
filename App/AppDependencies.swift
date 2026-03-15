import SwiftData

@MainActor
struct AppDependencies {
    let habitRepository: HabitRepository
    let dailyLogRepository: DailyLogRepository
    let hapticService: HapticService
    let roastGenerator: RoastGenerator

    init(modelContainer: ModelContainer) {
        self.habitRepository = HabitRepository(modelContainer: modelContainer)
        self.dailyLogRepository = DailyLogRepository(modelContainer: modelContainer)
        self.hapticService = HapticService()
        self.roastGenerator = RoastGenerator()
    }
}
