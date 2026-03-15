import OSLog

extension Logger {
    static let app = Logger(subsystem: AppConfiguration.subsystem, category: "app")
    static let habits = Logger(subsystem: AppConfiguration.subsystem, category: "habits")
    static let roast = Logger(subsystem: AppConfiguration.subsystem, category: "roast")
    static let haptics = Logger(subsystem: AppConfiguration.subsystem, category: "haptics")
}
