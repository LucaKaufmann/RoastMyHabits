import OSLog
import SwiftData
import SwiftUI

@main
struct RoastMyHabitsApp: App {
    private let dependencies: AppDependencies?

    init() {
        self.dependencies = Self.makeDependencies()
    }

    var body: some Scene {
        WindowGroup {
            if let dependencies {
                ContentView(dependencies: dependencies)
            } else {
                BootstrapFailureView()
            }
        }
    }

    @MainActor
    private static func makeDependencies() -> AppDependencies? {
        do {
            let schema = Schema([
                HabitRecord.self,
                DailyLogRecord.self
            ])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: configuration)
            return AppDependencies(modelContainer: container)
        } catch {
            Logger.app.fault("Failed to bootstrap SwiftData container: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
}
